import logging
import functools
import RebeccaEncryption


def decode(message, book, alphabet, nth):
    """Decode a message using the "Rebecca" algorithm

    Arguments:
        message (String): Plain message to decode comosed of valid letters
        book (String): Book page used for decoding
        alphabet (String): Valid letters
        nth (Integer): Frequency of letters to remove

    Returns:
        List<String>: Decoded messages
    """
    logging.info("Starting decryption")

    secuence_of_functions = list()
    secuence_of_functions.append(functools.partial(RebeccaEncryption.remove_every_nth_letter, nth=nth))
    secuence_of_functions.append(functools.partial(RebeccaEncryption.remove_illegal_characters, alphabet=alphabet))
    secuence_of_functions.append(functools.partial(RebeccaEncryption.transform_to_upper_case))
    encoding_function = RebeccaEncryption.compose(*secuence_of_functions)
    prepared_book = encoding_function(book)

    decoded_text = decode_backtrack(message, prepared_book, alphabet, list(), '', list())
    logging.info("Decoded texts: %s", decoded_text)
    return decoded_text


def decode_backtrack(message, book, alphabet, result, partial, nexts):
    logging.debug("BT - message: %s, result: %s, partial: %s, nexts: %s", message, result, partial, nexts)

    # Reject
    if not book:
        return

    # Accept
    if not message:
        result.append(partial)
        return

    # Iterate
    if not nexts:
        valid_positions = get_all_valid_positions(message[0], book, alphabet, list(), 0)
        return decode_backtrack(message, book, alphabet, result, partial, valid_positions)

    if len(book) > nexts[0] + 1 and len(message) >= 1:
        decode_backtrack(message[1:], book[nexts[0] + 1:], alphabet, result, partial + book[nexts[0]], list())

    if len(nexts) > 1:
        return decode_backtrack(message, book, alphabet, result, partial, nexts[1:])

    return result


def get_all_valid_positions(letter, book, alphabet, acc, iteration=0):
    letter_index = alphabet.find(letter)

    # Reject
    if len(book) <= letter_index + (len(alphabet) * iteration):
        return acc

    # Accept
    if book[letter_index + (len(alphabet) * iteration)] not in book[:letter_index + (len(alphabet) * iteration)]:
        acc.append(letter_index + (len(alphabet) * iteration))

    # Iterate
    return get_all_valid_positions(letter, book, alphabet, acc, iteration + 1)
