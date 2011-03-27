#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""usage: progname [OPTION] ... inputfile
Example: progname --ph52nc4"""

import sys
import getopt

import entry

def manager():
	try:
		opts, args = getopt.gnu_getopt(sys.argv[1:], "hH", ["help", "h52nc4", "he2nc3", "hdfeos2nc3"])
	except getopt.GetoptError, err:
		print str(err)
		usage()
	
	# initial
	h52nc4 = 0
	he2nc3 = 0
	
	# parse command line
	for o, a in opts:
		if o in ("-h", "-H", "--help"):
			usage()
		elif o == "--ph52nc4":
			ph52nc4 = 1
		elif o in ("--he2nc3", "--hdfeos2nc3"):
			he2nc3 = 1
		else:
			assert False, "unhanded option"
	
	if h52nc4 == 1:
		for arg in args:
			nprocs = get_nprocs(arg)
			lauch_h52nc4(arg, nprocs)
	elif he2nc3 == 1:
		for arg in args:
			nproc = get_nprocs(arg)
			lauch_he2nc3(arg, nproc)

def usage():
	print __doc__
	sys.exit(-1)

def get_nprocs(arg):
	return 1

def lauch_h52nc4(arg, nprocs):
	print entry.h52nc4
	print '({0}, {1})'.format(arg, nprocs)

def lauch_he2nc3(arg, nprocs):
#	print entry.he2nc3
#	print '({0}, {1})'.format(arg, nprocs)
	cmd = entry.he2nc3 + ' ' + arg + ' ' + arg[:len(arg)-3] + 'nc'
	print cmd
	os.system(cmd)

if __name__ == '__main__':
	manager()
