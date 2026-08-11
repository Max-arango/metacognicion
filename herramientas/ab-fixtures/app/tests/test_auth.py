import unittest

from auth import check_perm, verify


class TestAuth(unittest.TestCase):
    def test_verify_ok(self):
        self.assertTrue(verify("secreto", "secreto"))

    def test_verify_wrong(self):
        self.assertFalse(verify("secreto", "nope"))

    def test_check_perm_allow(self):
        self.assertTrue(check_perm({"perms": ["admin"]}, "admin"))

    def test_check_perm_deny(self):
        self.assertFalse(check_perm({"perms": ["admin"]}, "root"))


if __name__ == "__main__":
    unittest.main()
