#!/usr/bin/env python
"""generate a netCDF3 classic file"""

import netCDF4
import numpy

def gen():
	f = netCDF4.Dataset('test.nc', 'w', format='NETCDF3_CLASSIC')
	f.Convertions = 'CF 1.0'
	f.history = 'now'
	f.createDimension('x', 10)
	f.createDimension('y', 10)
	lon = f.createVariable('lon', 'f4', ('x',))
	lat = f.createVariable('lat', 'f4', ('y',))
	temp = f.createVariable('temp', 'i4', ('x', 'y'))
	temp.unit = 'degrees'
	temp.name = 'temprature'
	lon[:] = numpy.arange(0, 10)
	lat[:] = numpy.arange(40, 50)
	temp[...] = -10
	f.close()


if __name__ == '__main__':
	gen()
