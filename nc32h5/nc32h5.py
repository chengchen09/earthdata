#!/usr/bin/env python
"""convert netcdf3 file to hdf5 file"""

import sys
import netCDF4
import numpy
import h5py

def usage():
	print "Usage: {0} netcdf3-file hdf5-file".format(sys.argv)
	sys.exit(1)


def nc32h5(nc3path, h5path):
	nc3_fh = netCDF4.Dataset(nc3path, 'r', format='NETCDF3_CLASSIC')
	
	# global attributes
	global_attrs = []
	get_attrs(nc3_fh, global_attrs)

	# variables
	variables = []
	vars_name = nc3_fh.variables.keys()
#	for name in nc3_fh.variables.keys():


def get_attrs(obj_h, attrs):
	for name in obj_h.ncattrs():
		attr = obj_h.getncattr(name)
		attrs.append((name, attr))


def main():
	if len(sys.argv) < 3:
		usage(sys.argv[0])
	
	nc32h5(sys.argv[1], sys.argv[2])
	
if __name__ == '__main__':
	main()
