import unittest
import logging
import RebeccaDecryption


class MyTestCase(unittest.TestCase):

    def test_get_valid_positions(self):
        self.assertEqual([0], RebeccaDecryption.Node('A', '123', list()).get_all_valid_positions('ABCDEF'))
        self.assertEqual([6], RebeccaDecryption.Node('A', '123456789', list()).get_all_valid_positions('ABCDEF', iteration=1))
        self.assertEqual([0, 6], RebeccaDecryption.Node('A', '123456789', list()).get_all_valid_positions('ABCDEF'))
        self.assertEqual([0, 6, 12], RebeccaDecryption.Node('A', '1234567890ABCDFGHI', list()).get_all_valid_positions('ABCDEF'))

    def test_decode_backtrack(self):
        node = RebeccaDecryption.Node('A', '123456789', "", 'ABCDEF')
        self.assertEqual(['1', '7'], RebeccaDecryption.decode_backtrack(node, list(), list(), 'ABCDEF'))

        node = RebeccaDecryption.Node('AA', '1234567890ABCDFGHIJkLMNO', "", 'ABCDEF')
        self.assertEqual(['12', '18', '1D', '1k', '78', '7D', '7k', 'CD', 'Ck', 'Jk'],
                         RebeccaDecryption.decode_backtrack(node, list(), list(), 'ABCDEF'))


logging.basicConfig(level=logging.DEBUG, format="%(asctime)s: %(levelname)-8s > %(message)s", datefmt="%I:%M:%S")
if __name__ == '__main__':
    unittest.main()
