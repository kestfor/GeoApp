import unittest


class TestService(unittest.TestCase):
    def test_mock(self):
        test = "test"
        self.assertEqual(test, "test")
