import logging
import functools

def compose(functions):
    return functools.reduce(lambda f, g: lambda x: f(g(x)), map(lambda x: x.get('function'), functions), lambda x: x)

add_2_function = lambda element: element + 2
add_10_function = lambda element:  element + 10
div_2_function = lambda element: element / 2

def apply(version, data):
    sample_functions = list()
    sample_functions.append({'version':1, 'priority':1, 'function':add_2_function})
    sample_functions.append({'version':2, 'priority':1, 'function':add_10_function})
    sample_functions.append({'version':3, 'priority':10, 'function':add_10_function})
    sample_functions.append({'version':3, 'priority':5, 'function':div_2_function})

    functions_to_apply = filter(lambda x: version >= x.get("version"), sample_functions)
    ordered_functions_to_apply = sorted(functions_to_apply, key=lambda k: k['priority'], reverse=True) 
    return compose(ordered_functions_to_apply)(data)

logging.basicConfig(level=logging.INFO, format="%(asctime)s: %(levelname)-8s > %(message)s", datefmt="%I:%M:%S")
if __name__ == '__main__':
    logging.info("Applying v%s to %s = %s", 1, 0, apply(1, 0))
    logging.info("Applying v%s to %s = %s", 2, 0, apply(2, 0))
    logging.info("Applying v%s to %s = %s", 3, 0, apply(3, 0))

