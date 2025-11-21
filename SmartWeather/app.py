from flask import Flask, render_template, request, jsonify
from flask_cors import CORS
from src.config import configuration
from src.resource import resource
import logging
import threading
import subprocess
import time


# Global LLM service instance
llm_service = None
model_initialized = False


def ensure_ollama_running():
    """Ensure Ollama service is running"""
    try:
        import requests
        # Check if Ollama is already running
        response = requests.get("http://localhost:11434", timeout=2)
        if response.status_code == 200:
            logging.info("Ollama service is already running")
            return True
    except:
        pass
    
    # Start Ollama service
    try:
        logging.info("Starting Ollama service...")
        subprocess.Popen(
            ["ollama", "serve"],
            stdout=open('/tmp/ollama.log', 'w'),
            stderr=subprocess.STDOUT
        )
        # Wait for service to be ready
        time.sleep(3)
        
        # Verify it's running
        response = requests.get("http://localhost:11434", timeout=2)
        if response.status_code == 200:
            logging.info("Ollama service started successfully")
            return True
    except Exception as e:
        logging.error(f"Failed to start Ollama: {e}")
    
    return False


def initialize_llm_in_background():
    """Initialize the LLM model in a background thread"""
    global model_initialized
    logging.info("Starting LLM initialization in background...")
    
    # Ensure Ollama is running first
    if not ensure_ollama_running():
        logging.error("Cannot initialize LLM: Ollama service not available")
        return
    
    from src.llm.llm_service import get_llm_service
    from src.resource.resource import set_model_initialized
    
    llm = get_llm_service()
    success = llm.initialize_model()
    model_initialized = success
    
    # Update the resource module's status too
    set_model_initialized(success)
    
    if success:
        logging.info("LLM model ready!")
    else:
        logging.warning(
            "LLM model initialization failed, using fallback responses")


def add_resources_endpoints(flask_app):
    logging.info(f"Adding resources")
    flask_app.register_blueprint(resource.resource)


def set_logger_format():
    logging.basicConfig(
        level=logging.INFO, format="%(asctime)s: %(levelname)-8s > %(message)s", datefmt="%I:%M:%S")


def start():
    set_logger_format()
    app_config = configuration.load(configuration.APP_CONFIG)
    flask_app = Flask(__name__)
    CORS(flask_app)
    flask_app.config['SEND_FILE_MAX_AGE_DEFAULT'] = 0
    add_resources_endpoints(flask_app)

    # Initialize LLM in background thread to avoid blocking startup
    llm_thread = threading.Thread(
        target=initialize_llm_in_background, daemon=True)
    llm_thread.start()

    flask_app.run(host='0.0.0.0', port=app_config.get('port'), debug=True)


if __name__ == '__main__':
    start()
