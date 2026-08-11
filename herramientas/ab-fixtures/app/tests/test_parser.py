import unittest

from parsers import parse_user


class TestParser(unittest.TestCase):
    def test_parse_ok(self):
        self.assertEqual(
            parse_user("Ana|admin|30"),
            {"name": "Ana", "role": "admin", "age": 30},
        )


if __name__ == "__main__":
    unittest.main()
