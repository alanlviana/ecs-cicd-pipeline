import unittest
from unittest.mock import patch
from flask import Flask

from app import app

class AppTestCase(unittest.TestCase):
    def setUp(self):
        self.app = app.app.test_client()
        self.app.testing = True

    @patch('os.getenv')
    @patch('os.uname')
    def test_index(self, mock_uname, mock_getenv):
        mock_getenv.return_value = 'Test Environment'
        mock_uname.return_value = ['','test-hostname']

        response = self.app.get('/')
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'Version: 4', response.data)
        self.assertIn(b'Environment: Test Environment', response.data)
        self.assertIn(b'Hostname: test-hostname', response.data)


if __name__ == '__main__':
    unittest.main()