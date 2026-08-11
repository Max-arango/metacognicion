import unittest
from unittest import mock

from database import load, save


class TestDatabase(unittest.TestCase):
    def test_save_load(self):
        with mock.patch.dict("os.environ", {"DB_DIR": "/tmp/ab-db-test"}):
            self.assertTrue(save({"id": 1, "x": "y"}))
            self.assertEqual(load(), {"1": {"id": 1, "x": "y"}})


if __name__ == "__main__":
    unittest.main()
