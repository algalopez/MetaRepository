import logging
import functools
import RebeccaError


def encode(message, book_text, alphabet, nth):
    """Encode a message using the "Rebecca" algorithm

    Arguments:
        message (String): Plain message to decode comosed of valid letters
        book_text (String): Book page used for decoding
        alphabet (String): Valid letters
        nth (Integer): Frequency of letters to remove

    Returns:
        String: Encoded message

    Exceptions:
        EncryptionError: Encoding was not possible

    """
    logging.info("Starting encryption")

    secuence_of_functions = list()
    secuence_of_functions.append(functools.partial(map_to_alphabet, alphabet=alphabet))
    secuence_of_functions.append(functools.partial(process_to_index_list, message=message))
    secuence_of_functions.append(functools.partial(remove_every_nth_letter, nth=nth))
    secuence_of_functions.append(functools.partial(remove_illegal_characters, alphabet=alphabet))
    secuence_of_functions.append(functools.partial(transform_to_upper_case))
    encoding_function = compose(*secuence_of_functions)

    encoded_text = encoding_function(book_text)

    logging.info("Encoded text : %s", encoded_text)
    return encoded_text


def compose(*functions):
    return functools.reduce(lambda f, g: lambda x: f(g(x)), functions, lambda x: x)


def transform_to_upper_case(text):
    return text.upper()


def remove_illegal_characters(text, alphabet):
    logging.debug("Removing illegal characters")
    filtered_text = ''.join(filter(lambda x: x in alphabet, text))
    return filtered_text


def remove_every_nth_letter(text, nth):
    logging.debug("Removing every nth letter")
    filtered_text = ''
    for i in range(len(text)):
        if (i + 1) % nth != 0:
            filtered_text = filtered_text + text[i]
    return filtered_text


def process_to_index_list(text, message):
    index_list = list()
    start = 0
    for letter in message:
        index = text[start::].find(letter)
        if index != -1:
            index_list.append(index)
            start = start + index + 1
        else:
            raise RebeccaError.EncryptionError('Error encoding message')
    return index_list


def map_to_alphabet(index_list, alphabet):
    encoded_list = map(lambda elem: alphabet[elem % len(alphabet)], index_list)
    encoded_string = functools.reduce(lambda a, b: a+b, encoded_list)
    return encoded_string
