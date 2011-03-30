#!/usr/bin/env python
"""This is the support module for httpget.py"""

# AUTHOR: chen cheng
# DATA: 2011/03/30

import urllib
import sys
from collections import deque


def redo_failed(failed_path, dest_path):
	file_q = deque([])
	
	failed_fh = open(failed_path, 'r')
	reload_failed(failed_fh, file_q)
	failed_fh.close()

	download_file(file_q, dest_path)

def download_file(file_q, dest_path):
	failed_fh = open(dest_path + 'failed.log', 'w')
	down_fh = open(dest_path + 'downloaded.log', 'a')
	count = 0
	num = len(file_q)
	for (url, path) in file_q:
		try: 
			count += 1
			print 'downloading ' + url
			urllib.urlretrieve(url, path)
			print path + ' downloaded'
			left = num - count
			print('There are {0} files left'.format(left))
			down_fh.write(url + ' ' + path + '\n')
		except:
			print path + ' downloading faild'
			failed_fh.write(url + ' ' + path + '\n')
			
	failed_fh.close()
	down_fh.close()


def reload_failed(failed_fh, file_q):
	for line in failed_fh:
		line = line.rstrip('\n')
		(url, path) = line.split()
		file_q.append((url, path))

	
if __name__ == '__main__':
	file_q = deque([])
	with open(sys.argv[1], 'r') as fh:
		reload_failed(fh, file_q)
		print file_q
