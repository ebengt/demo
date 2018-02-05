import unittest

import command


class Test_command( unittest.TestCase ):

	def test_prepare( self ):
		command.prepare()

	def test_command( self ):
		self.assertTrue( command.result("echo") == 0 )

	def test_command_arg( self ):
		self.assertTrue( command.result("echo 1") == 0 )

	def test_command_fail( self ):
		self.assertTrue( command.result("false") == 1 )
