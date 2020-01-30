import unittest
import logging
import string
import RebeccaEncryption
import EncryptionError


class TestStringMethods(unittest.TestCase):

    def test_remove_illegal_characters(self):
        self.assertEqual("A", RebeccaEncryption.remove_illegal_characters("AB CDE", "A"))

    def test_remove_every_nth_letter(self):
        self.assertEqual("13579", RebeccaEncryption.remove_every_nth_letter("1234567890", 2))
        self.assertEqual("1", RebeccaEncryption.remove_every_nth_letter("1", 2))

    def test_process_to_index_list(self):
        self.assertEqual([0], RebeccaEncryption.process_to_index_list("ABCDE", "A"))
        self.assertEqual([0, 0], RebeccaEncryption.process_to_index_list("ABCDE", "AB"))
        self.assertEqual([0, 0, 2], RebeccaEncryption.process_to_index_list("ABCDE", "ABE"))

        with self.assertRaises(EncryptionError.EncryptionError):
            RebeccaEncryption.process_to_index_list("ABCDE", "AA")

    def test_map_to_alphabet(self):
        self.assertEqual("AEV", RebeccaEncryption.map_to_alphabet([0, 4, 21], "ABCDEFGHIJKLMNOPQRSTUVWXYZ"))
        self.assertEqual("AAA", RebeccaEncryption.map_to_alphabet([0, 26, 52], "ABCDEFGHIJKLMNOPQRSTUVWXYZ"))

    def test_ascii_alphabet(self):
        self.assertEqual('ABCDEFGHIJKLMNOPQRSTUVWXYZ', string.ascii_uppercase)


logging.basicConfig(level=logging.INFO, format="%(asctime)s: %(levelname)-8s > %(message)s", datefmt="%I:%M:%S")
if __name__ == '__main__':
    unittest.main()
