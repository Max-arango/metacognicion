import unittest

from normalize import normalize


class TestNormalize(unittest.TestCase):
    def test_normalize_accents(self):
        self.assertEqual(normalize("HOLA, MÚNDO!"), "hola, mundo!")


if __name__ == "__main__":
    unittest.main()
