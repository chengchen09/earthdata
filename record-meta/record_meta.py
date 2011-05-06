#!/usr/bin/python
"""record the metadata of input file"""

import bsddb3.db as bsddb

dbpath = 'record.db'


def record_meta(dbfile, records):
	dbh = bsddb.DB()
	dbh.set_flags(bsddb.DB_DUPSORT)
	dbh.open(dbfile, dbtype=bsddb.DB_BTREE, flags=bsddb.DB_CREATE)
	
	for (key, value) in records:
	# put data
		try:
			dbh.put(key, value, flags=bsddb.DB_NODUPDATA)
		except bsddb.DBKeyExistError:
			# print 'catch DBKeyExistError'
			pass
	dbh.close()


def get_records(fpath, records):
	with open(fpath, 'r') as fh:
		for line in fh:
			strs = line.split()
			if 0 == len(strs):
				pass
			elif 1 == len(strs):
				# TODO: write log
				pass
			else:
				for tab in strs[1:]:
					records.append((tab, strs[0]))
					#print tab, strs[0]


def record_data(fpath):
	# TODO: write log
	records = []
	get_records(fpath, records)
	record_meta(dbpath, records)


def test_record():
	records = []
		
	# print data
	dbh = bsddb.DB()
	dbh.set_flags(bsddb.DB_DUPSORT)
	dbh.open(dbpath, dbtype=bsddb.DB_BTREE, flags=bsddb.DB_CREATE)
	
	values = []
	cur = dbh.cursor()
	val = cur.first()
	while val is not None:
		print val
		values.append(val[1])
		val = cur.next()
	
	cur.close()
	dbh.close()


if __name__ == '__main__':
    import sys
    record_data(sys.argv[1])
    test_record()
