#!/usr/bin/env python
"""create the rtree index for a hdf dataset"""

import sys
import rtree
import h5py

def create_index(h5path, variable, dimensions):
	h5_fh = h5py.File(h5path, 'r')
	var_id = h5_fh[variable]
	dim_ids = []
	for dim in dimensions:
		dim_id = h5_fh[dim]
		dim_ids.append(dim_id)
	
	chunk_objs = []
	create_2D_objs(var_id, dim_ids, chunk_objs)
	
	# create index
	p = rtree.index.Property()
	idx = rtree.index.Index('ETO_index', properties=p)
	for chunk_obj in chunk_objs:
		#print chunk_obj['id'], chunk_obj['coordinates'], chunk_obj['obj']
		idx.insert(chunk_obj['id'], chunk_obj['coordinates'], chunk_obj['obj'])	

	h5_fh.close()
	return idx


def create_2D_objs(var_id, dim_ids, chunk_objs):
	if var_id.chunks == None:
		print "variable is not chunked"
		sys.exit(1)
		
	chunk_dims = list(var_id.chunks)
	var_dims = list(var_id.shape)
	x = dim_ids[0]
	y = dim_ids[1]
	
	chunk_nums = []
	nchunks = 1
	for i in range(2):
		n = (var_dims[i] - 1) / chunk_dims[i] + 1
		chunk_nums.append(n)
		nchunks *= n

	for i in range(chunk_nums[0]):
		xmin = x[i * chunk_dims[0]]
		xmax = x[min(var_dims[0] - 1, (i + 1) * chunk_dims[0] - 1)]
		for j in range(chunk_nums[1]):
			ymin = y[j * chunk_dims[1]]
			ymax = y[min(var_dims[1] - 1, (j + 1) * chunk_dims[1] - 1)]
			chunk_obj = {}
			chunk_obj['id'] = i * chunk_nums[1] + j
			chunk_obj['coordinates'] = (xmin, ymin, xmax, ymax)
			chunk_obj['obj'] = str(i) + ':' + str(j)
			#print chunk_obj['id'], chunk_obj['coordinates'], chunk_obj['obj']
			#data = raw_input("")	
			chunk_objs.append(chunk_obj)

def test_create():
	dims = ['/y', '/x']
	idx = create_index(sys.argv[1], '/z', dims)
	
	hits = list(idx.intersection((0, 0, 60, 60), objects=True))
	for item in hits:
		print item.id, item.bbox, item.object

if __name__ == '__main__':
	test_create()
