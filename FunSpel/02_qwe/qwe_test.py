
import unittest
import logging
import string


class TestStringMethods(unittest.TestCase):


    def test_remove_illegal_characters(self):
        #print('Hello World')
        logging.info('asdasd')
        logging.info('qweqwe')
        logging.info('zxczxc')
        #self.assertEqual("A", RebeccaEncryption.remove_illegal_characters("AB CDE", "A"))



logging.basicConfig(level=logging.INFO, format="%(asctime)s: %(levelname)-8s > %(message)s", datefmt="%I:%M:%S")
logging.info("Start")
if __name__ == '__main__':

    logging.info('1111')
    unittest.main()

