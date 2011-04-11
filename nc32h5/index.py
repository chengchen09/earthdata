#!/usr/bin/env python
"""create the rtree index for a hdf dataset"""

import sys
import rtree
import h5py

def create_index(h5path, variable, dimension):
	h5_fh = h5py.File(h5path, 'r')
	
	ndims = len(dimension)
	ds = h5_fh[variable]
	
	dim_hs = []
	for path in dimension:
		dim_h = h5_fh[path]
		dim_hs.append(dim_h)
	
	
	

def insert():
	pass


def delete():
	pass


def search():
	pass


def load():
	pass


def test():
	pass


if __name__ == '__main__':
	test()
