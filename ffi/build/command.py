#! /usr/bin/env python

import subprocess
import sys
import time


def prepare():
	time.sleep( 1 ) # Fake workload

def result( command ):
	return subprocess.call( command.split(), stdout=subprocess.PIPE )


if __name__ == '__main__':
	prepare()
	sys.exit( result(" ".join(sys.argv[1:])) )
