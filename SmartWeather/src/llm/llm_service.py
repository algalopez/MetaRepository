"""
LLM Service using Ollama with MCP tools integration
"""
import logging
import ollama
from src.mcp.weather_server import get_weather_direct
from src.mcp.summary_server import get_summary_direct
import json


class LLMService:
    """Service for handling LLM interactions with MCP tools"""

    def __init__(self):
        self.model_name = None
        self.tools = []
        self._setup_tools()

    def _setup_tools(self):
        """Setup MCP tools for the LLM"""
        self.tools = [
            {
                "type": "function",
                "function": {
                    "name": "get_weather",
                    "description": "Get current weather information for a city",
                    "parameters": {
                        "type": "object",
                        "properties": {
                            "city": {
                                "type": "string",
                                "description": "The city name to get weather for"
                            }
                        },
                        "required": ["city"]
                    }
                }
            }
        ]

    def initialize_model(self, model_name="mistral:7b-instruct"):
        """Initialize the Ollama model (pulls if needed)"""
        try:
            logging.info(f"Initializing Ollama model: {model_name}")
            
            # Check if Ollama is running and pull model if needed
            try:
                ollama.pull(model_name)
                logging.info(f"Ollama model {model_name} ready")
            except Exception as pull_error:
                logging.warning(f"Could not pull model (may already exist): {pull_error}")
            
            # Test the model
            test_response = ollama.chat(
                model=model_name,
                messages=[{"role": "user", "content": "Hello"}]
            )
            
            if test_response:
                self.model_name = model_name
                logging.info("Ollama model initialized successfully")
                return True
            else:
                logging.error("Ollama model test failed")
                return False
                
        except Exception as e:
            logging.error(f"Error initializing Ollama: {e}")
            return False

    def get_weather(self, city: str) -> str:
        """Get weather using MCP server logic"""
        try:
            return get_weather_direct(city)
        except Exception as e:
            logging.error(f"Error getting weather: {e}")
            return f"Unable to get weather for {city}"

    def get_summary(self, weather_info: str, personality: str) -> str:
        """Get summary using MCP server logic"""
        try:
            return get_summary_direct(weather_info, personality)
        except Exception as e:
            logging.error(f"Error generating summary: {e}")
            return f"Unable to generate summary"

    def ask_llm_for_weather(self, city: str) -> str:
        """Ask LLM to get weather information using MCP tool"""
        
        if not self.model_name:
            # Fallback if model not loaded
            return get_weather_direct(city)
        
        try:
            messages = [
                {
                    "role": "user",
                    "content": f"What's the weather in {city}?"
                }
            ]

            logging.info(f"Asking Ollama with tools to get weather for {city}")

            # Use Ollama chat with tools
            response = ollama.chat(
                model=self.model_name,
                messages=messages,
                tools=self.tools
            )

            logging.info(f"Ollama response: {response}")

            # Check if the LLM decided to use a tool
            if response and 'message' in response:
                message = response['message']

                # Check for tool calls
                tool_calls = message.get('tool_calls', [])
                if tool_calls:
                    for tool_call in tool_calls:
                        function = tool_call.get('function', {})
                        function_name = function.get('name')
                        function_args = function.get('arguments', {})

                        logging.info(
                            f"LLM decided to call tool: {function_name} with args: {function_args}")

                        # Execute the MCP tool
                        if function_name == "get_weather":
                            tool_city = function_args.get('city', city)
                            weather_info = get_weather_direct(tool_city)
                            logging.info(f"MCP tool executed, weather retrieved: {weather_info}")
                            return weather_info

                # If no tool call, check for text content
                content = message.get('content')
                if content:
                    logging.warning(
                        f"LLM responded with text instead of tool call: {content}")

            # Fallback: call MCP directly
            logging.warning("LLM didn't use tool, calling MCP directly")
            return get_weather_direct(city)

        except Exception as e:
            logging.error(f"Error in ask_llm_for_weather: {e}")
            logging.error(f"Exception details: {type(e).__name__}: {str(e)}")
            # Fallback to direct MCP call
            return get_weather_direct(city)

    def ask_llm_for_summary(self, weather_info: str, personality: str) -> str:
        """Ask LLM to create a personality-based summary"""

        try:
            system_prompt = self._create_system_prompt(personality)

            prompt = f"""{system_prompt}

Here is the weather information: {weather_info}

Task: Give a short weather report (2-3 sentences) in your character's voice about this weather.
Stay completely in character. Be creative and authentic to your personality.

Your response:"""

            logging.info(f"Asking Ollama to generate {personality} summary")
            
            response = ollama.chat(
                model=self.model_name,
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": f"Here is the weather information: {weather_info}\n\nGive a short weather report (2-3 sentences) in your character's voice."}
                ]
            )

            result = response['message']['content'].strip()
            logging.info(f"Generated response: {result}")
            return result

        except Exception as e:
            logging.error(f"Error in ask_llm_for_summary: {e}")
            return get_summary_direct(weather_info, personality)

    def _create_system_prompt(self, personality: str) -> str:
        """Create a system prompt based on personality"""
        personalities = {
            "grumpy": """You are a grumpy, depressed old man who sees the worst in everything.
You are highly pessimistic, cynical, often gloomy and with and impending feeling of doom.
You give accurate information but with a bitter, hopeless attitude.
You frequently complain about life, the weather, the city, or young people, emphasizing how everything is deteriorating.
Keep your responses short, grim, and to the point—no optimism, no long explanations.""",

            "scout": """You are a cheerful, enthusiastic flower girl scout who sees the bright side of everything.
You are optimistic, friendly, and full of energy.
You give accurate information with warmth and encouragement, often adding little cheerful remarks or cute observations.
You love nature, flowers, and helping people, and you often sprinkle your responses with positivity.
Keep your responses short, light-hearted, and full of charm—make people smile with your words.""",
            
            "nerd": """You are an overly enthusiastic tech nerd who lives and breathes technology.
You speak with excitement about code, systems, and gadgets, often going into unnecessary technical detail.
You give accurate information but tend to over-explain, using tech jargon, acronyms, and analogies from computing.
You sometimes make awkward jokes or puns about programming or hardware.
Keep your responses concise but packed with geeky enthusiasm—show your passion for all things tech."""
        }
        return personalities.get(personality, personalities["grumpy"])


_llm_service = None


def get_llm_service() -> LLMService:
    """Get or create the global LLM service instance"""
    global _llm_service
    if _llm_service is None:
        _llm_service = LLMService()
    return _llm_service
