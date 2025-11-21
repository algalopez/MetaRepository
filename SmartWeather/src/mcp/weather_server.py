"""
MCP Server for Weather Information
Provides weather-related tools that can be used by the LLM
Uses Open-Meteo API for real weather data
"""
import logging
import json
import requests
from datetime import datetime
from mcp.server import Server
from mcp.types import Tool, TextContent
import mcp.server.stdio


weather_server = Server("weather-server")


def _geocode_city(city: str) -> dict:
    """Convert city name to coordinates using Open-Meteo Geocoding API"""
    try:
        url = "https://geocoding-api.open-meteo.com/v1/search"
        params = {
            "name": city,
            "count": 1,
            "language": "en",
            "format": "json"
        }
        response = requests.get(url, params=params, timeout=10)
        response.raise_for_status()
        data = response.json()
        
        if data.get("results") and len(data["results"]) > 0:
            result = data["results"][0]
            return {
                "name": result.get("name"),
                "country": result.get("country"),
                "latitude": result.get("latitude"),
                "longitude": result.get("longitude")
            }
        else:
            return None
    except Exception as e:
        logging.error(f"Geocoding error for {city}: {e}")
        return None


def _get_weather_from_api(latitude: float, longitude: float) -> dict:
    """Fetch weather data from Open-Meteo API"""
    try:
        url = "https://api.open-meteo.com/v1/forecast"
        params = {
            "latitude": latitude,
            "longitude": longitude,
            "current": "temperature_2m,relative_humidity_2m,weather_code",
            "temperature_unit": "celsius"
        }
        response = requests.get(url, params=params, timeout=10)
        response.raise_for_status()
        data = response.json()
        
        current = data.get("current", {})
        return {
            "temperature": current.get("temperature_2m"),
            "humidity": current.get("relative_humidity_2m"),
            "weather_code": current.get("weather_code")
        }
    except Exception as e:
        logging.error(f"Weather API error: {e}")
        return None


def _weather_code_to_condition(code: int) -> str:
    """Convert WMO weather code to readable condition"""
    # WMO Weather interpretation codes
    if code == 0:
        return "Clear sky"
    elif code in [1, 2, 3]:
        return "Partly cloudy"
    elif code in [45, 48]:
        return "Foggy"
    elif code in [51, 53, 55]:
        return "Drizzle"
    elif code in [61, 63, 65]:
        return "Rain"
    elif code in [71, 73, 75]:
        return "Snow"
    elif code in [80, 81, 82]:
        return "Rain showers"
    elif code in [95, 96, 99]:
        return "Thunderstorm"
    else:
        return "Unknown"


# Core weather logic - single source of truth
def _get_weather_data(city: str) -> dict:
    """Internal function to get weather data from Open-Meteo API"""
    # Step 1: Geocode the city
    location = _geocode_city(city)
    if not location:
        return {
            "city": city.title(),
            "temperature": None,
            "condition": "City not found",
            "humidity": None,
            "error": True
        }
    
    # Step 2: Get weather data
    weather = _get_weather_from_api(location["latitude"], location["longitude"])
    if not weather:
        return {
            "city": location["name"],
            "country": location.get("country"),
            "temperature": None,
            "condition": "Weather data unavailable",
            "humidity": None,
            "error": True
        }
    
    # Step 3: Format the response
    condition = _weather_code_to_condition(weather.get("weather_code", 0))
    return {
        "city": location["name"],
        "country": location.get("country"),
        "temperature": weather["temperature"],
        "condition": condition,
        "humidity": weather["humidity"],
        "error": False
    }


# MCP Protocol handlers
@weather_server.list_tools()
async def list_tools() -> list[Tool]:
    return [
        Tool(
            name="get_weather",
            description="Get current weather information for a city. Returns temperature, weather condition, and humidity.",
            inputSchema={
                "type": "object",
                "properties": {
                    "city": {
                        "type": "string",
                        "description": "The city name to get weather for"
                    }
                },
                "required": ["city"]
            }
        )
    ]


@weather_server.call_tool()
async def call_tool(name: str, arguments: dict) -> list[TextContent]:
    """MCP protocol handler - calls the core logic"""
    if name == "get_weather":
        city = arguments.get("city", "")
        data = _get_weather_data(city)
        
        if data.get("error"):
            result = f"Unable to get weather for {city}: {data['condition']}"
        else:
            result = f"Weather in {data['city']}"
            if data.get("country"):
                result += f", {data['country']}"
            result += f":\n"
            result += f"Temperature: {data['temperature']}°C\n"
            result += f"Condition: {data['condition']}\n"
            result += f"Humidity: {data['humidity']}%"
        
        return [TextContent(type="text", text=result)]
    else:
        raise ValueError(f"Unknown tool: {name}")


# Direct call interface (bypasses MCP protocol for simplicity)
def get_weather_direct(city: str) -> str:
    """Direct synchronous call to weather logic"""
    data = _get_weather_data(city)
    
    if data.get("error"):
        result = f"Unable to get weather for {city}: {data['condition']}"
    else:
        result = f"Weather in {data['city']}"
        if data.get("country"):
            result += f", {data['country']}"
        result += f":\n"
        result += f"Temperature: {data['temperature']}°C\n"
        result += f"Condition: {data['condition']}\n"
        result += f"Humidity: {data['humidity']}%"
    
    return result


async def main():
    """Run the weather MCP server"""
    async with mcp.server.stdio.stdio_server() as (read_stream, write_stream):
        await weather_server.run(
            read_stream,
            write_stream,
            weather_server.create_initialization_options()
        )


if __name__ == "__main__":
    import asyncio
    asyncio.run(main())
