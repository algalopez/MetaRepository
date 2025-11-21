"""Simple registry for storing application configuration"""

_registry = {}


def register(name, value):
    """Register a configuration value"""
    _registry[name] = value


def get(name, default=None):
    """Get a configuration value"""
    return _registry.get(name, default)


def clear():
    """Clear all registered values"""
    _registry.clear()
