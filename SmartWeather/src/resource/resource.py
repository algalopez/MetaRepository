from flask import Blueprint, render_template, request, jsonify

resource = Blueprint('resource', __name__)

# Import model_initialized from app module
model_initialized = False


def set_model_initialized(status):
    """Update model initialization status"""
    global model_initialized
    model_initialized = status


@resource.route('/')
def index():
    return render_template('index.html')


@resource.route('/status', methods=['GET'])
def status():
    """Endpoint to check if the LLM model is ready"""
    from src.llm.llm_service import get_llm_service
    llm = get_llm_service()
    global model_initialized
    if llm.model_name is not None:
        model_initialized = True
    
    # MCP servers available
    mcp_tools = ['get_weather', 'get_weather_summary']
    
    return jsonify({
        'model_initialized': model_initialized,
        'tools_available': mcp_tools
    })



@resource.route('/submit', methods=['POST'])
def submit():
    import logging
    from src.llm.llm_service import get_llm_service
    
    data = request.get_json()
    personality = data.get('personality')
    city = data.get('city')
    
    try:
        llm = get_llm_service()
        
        # Step 1: Ask LLM to get weather (LLM uses weather MCP)
        logging.info(f"Step 1: Asking LLM to get weather for {city}")
        weather_info = llm.ask_llm_for_weather(city)
        logging.info(f"Weather info: {weather_info}")
        
        # Step 2: Ask LLM to create summary (LLM generates personality response)
        logging.info(f"Step 2: Asking LLM to create {personality} summary")
        summary = llm.ask_llm_for_summary(weather_info, personality)
        logging.info(f"Summary: {summary}")
        
        # Return the summary
        global model_initialized
        return jsonify({
            'message': summary,
            'model_status': 'ready'
        })
        
    except Exception as e:
        logging.error(f"Error processing request: {e}")
        return jsonify({
            'message': f"Sorry, there was an error processing your request: {str(e)}",
            'model_status': 'error'
        }), 500

