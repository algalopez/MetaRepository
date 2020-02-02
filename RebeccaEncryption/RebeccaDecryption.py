import logging
import functools
import RebeccaEncryption


class Node:

    def __init__(self, message, book, partial, alphabet=None):
        self.message = message
        self.book = book
        self.partial = partial
        if alphabet is not None:
            self.nexts = self.get_all_valid_positions(alphabet)

    def __str__(self) -> str:
        return "(m: {}, p: {}, n: {})".format(self.message, self.partial, self.nexts)

    def get_all_valid_positions(self, alphabet, acc=None, iteration=0):
        if acc is None:
            acc = list()

        # Finnish
        if not self.message:
            return acc

        letter_index = alphabet.find(self.message[0])

        # Finnish
        if len(self.book) <= letter_index + (len(alphabet) * iteration):
            return acc

        # Accept
        if self.book[letter_index + (len(alphabet) * iteration)] not in self.book[:letter_index + (len(alphabet) * iteration)]:
            acc.append(letter_index + (len(alphabet) * iteration))

        # Iterate
        return self.get_all_valid_positions(alphabet, acc, iteration + 1)


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

    next_node = Node(message, prepared_book, "", alphabet)
    logging.debug("nn: %s", str(next_node))
    decoded_text = decode_backtrack(next_node, list(), list(), alphabet)
    logging.info("Decoded texts: %s", decoded_text)
    return decoded_text


def decode_backtrack(node: Node, results, queue, alphabet):
    logging.debug("BT - node: %s, results: %s, next_nodes_len: %d", str(node), results, len(queue))

    if not node:
        if not queue:
            return results
        else:
            return decode_backtrack(queue[0], results, queue[1:], alphabet)

    if not node.message:
        results.append(node.partial)
        return decode_backtrack(None, results, queue, alphabet)

    if node.nexts:
        next_node = Node(node.message[1:],
                         node.book[node.nexts[0] + 1:],
                         node.partial + node.book[node.nexts[0]],
                         alphabet)
        queue.append(next_node)
        node.nexts = node.nexts[1:]
        return decode_backtrack(node, results, queue, alphabet)

    return decode_backtrack(None, results, queue, alphabet)
