import unittest
import logging
import string


class TestStringMethods(unittest.TestCase):

    def test_remove_illegal_characters11(self):
        print('Hello World')
        #self.assertEqual("A", RebeccaEncryption.remove_illegal_characters("AB CDE", "A"))


logging.basicConfig(level=logging.INFO, format="%(asctime)s: %(levelname)-8s > %(message)s", datefmt="%I:%M:%S")
if __name__ == '__main__':
    unittest.main()

