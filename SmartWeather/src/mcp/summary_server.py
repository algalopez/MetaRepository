"""
MCP Server for Weather Summary using ChatGPT
Generates personality-based weather summaries
"""
import logging
import os
from datetime import datetime, timedelta
from mcp.server import Server
from mcp.types import Tool, TextContent
import mcp.server.stdio


summary_server = Server("summary-server")


# Core summary logic - single source of truth
def _generate_summary(weather_description: str, personality: str) -> str:
    """Generate a personality-based weather summary using ChatGPT"""
    try:
        from openai import OpenAI
        from src.config import configuration
        
        # Load config to get ChatGPT token
        app_config = configuration.load(configuration.APP_CONFIG)
        api_key = app_config.get('chatgpt', {}).get('token')
        
        if not api_key or api_key == 'asd':
            logging.warning("No valid ChatGPT API key configured, using fallback")
            return _generate_fallback_summary(weather_description, personality)
        
        # Create OpenAI client
        client = OpenAI(api_key=api_key)
        
        # Create personality prompt
        personality_prompts = {
            "grumpy": "You are a grumpy old guy who complains about everything. Respond to this weather in a cranky, skeptical way. Keep it short - 2-3 sentences max.",
            "scout": "You are an enthusiastic girl scout who loves nature and is always positive. Respond to this weather with excitement and optimism. Keep it short - 2-3 sentences max."
        }
        
        system_prompt = personality_prompts.get(personality, personality_prompts["grumpy"])
        
        # Call ChatGPT using new API
        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": f"Here's the weather: {weather_description}"}
            ],
            max_tokens=150,
            temperature=0.7
        )
        
        summary = response.choices[0].message.content.strip()
        logging.info(f"Generated ChatGPT summary for {personality} personality")
        return summary
        
    except ImportError:
        logging.error("OpenAI library not installed")
        return _generate_fallback_summary(weather_description, personality)
    except Exception as e:
        logging.error(f"Error calling ChatGPT: {e}")
        return _generate_fallback_summary(weather_description, personality)


def _generate_fallback_summary(weather_description: str, personality: str) -> str:
    """Generate a simple fallback summary without ChatGPT"""
    if personality == "grumpy":
        return f"Hmph! {weather_description}. Typical weather, nothing to get excited about. Back in my day, we didn't complain about the weather, we just dealt with it!"
    else:  # scout
        return f"Wow! {weather_description}! What a wonderful day to be outside and enjoy nature! This weather is perfect for all kinds of outdoor adventures!"


# MCP Protocol handlers
@summary_server.list_tools()
async def list_tools() -> list[Tool]:
    return [
        Tool(
            name="get_weather_summary",
            description="Generate a personality-based weather summary using ChatGPT",
            inputSchema={
                "type": "object",
                "properties": {
                    "weather_description": {
                        "type": "string",
                        "description": "The formatted weather description"
                    },
                    "personality": {
                        "type": "string",
                        "description": "The personality type (grumpy or scout)"
                    }
                },
                "required": ["weather_description", "personality"]
            }
        )
    ]


@summary_server.call_tool()
async def call_tool(name: str, arguments: dict) -> list[TextContent]:
    """MCP protocol handler - calls the core logic"""
    if name == "get_weather_summary":
        weather_desc = arguments.get("weather_description", "")
        personality = arguments.get("personality", "grumpy")
        
        result = _generate_summary(weather_desc, personality)
        return [TextContent(type="text", text=result)]
    else:
        raise ValueError(f"Unknown tool: {name}")


# Direct call interface (bypasses MCP protocol for simplicity)
def get_summary_direct(weather_description: str, personality: str) -> str:
    """Direct synchronous call to summary logic"""
    return _generate_summary(weather_description, personality)


async def main():
    """Run the summary MCP server"""
    async with mcp.server.stdio.stdio_server() as (read_stream, write_stream):
        await summary_server.run(
            read_stream,
            write_stream,
            summary_server.create_initialization_options()
        )


if __name__ == "__main__":
    import asyncio
    asyncio.run(main())




