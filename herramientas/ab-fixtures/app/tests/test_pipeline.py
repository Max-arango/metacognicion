import unittest

from pipeline import process


class TestPipeline(unittest.TestCase):
    def test_process(self):
        self.assertEqual(process(["a", "b", "c"]), ["A", "B", "C"])


if __name__ == "__main__":
    unittest.main()
