import unittest
import logging
import RebeccaDecryption


class MyTestCase(unittest.TestCase):

    def test_get_valid_positions(self):
        self.assertEqual([0], RebeccaDecryption.get_all_valid_positions('A', '123', 'ABCDEF', list()))
        self.assertEqual([6], RebeccaDecryption.get_all_valid_positions('A', '123456789', 'ABCDEF', list(), 1))
        self.assertEqual([0, 6], RebeccaDecryption.get_all_valid_positions('A', '123456789', 'ABCDEF', list(), 0))
        self.assertEqual([0, 6, 12], RebeccaDecryption.get_all_valid_positions('A', '1234567890ABCDFGHI', 'ABCDEF', list(), 0))

    def test_decode_backtrack(self):
        self.assertEqual(['1', '7'], RebeccaDecryption.decode_backtrack('A', '123456789', 'ABCDEF', list(), '', list()))
        self.assertEqual(['12', '18', '1D', '1k', '78', '7D', '7k', 'CD', 'Ck', 'Jk'],
                         RebeccaDecryption.decode_backtrack('AA', '1234567890ABCDFGHIJkLMNO', 'ABCDEF', list(), '', list()))


logging.basicConfig(level=logging.DEBUG, format="%(asctime)s: %(levelname)-8s > %(message)s", datefmt="%I:%M:%S")
if __name__ == '__main__':
    unittest.main()
