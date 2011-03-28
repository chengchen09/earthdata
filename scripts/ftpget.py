#get .h5 files from ftp

import ftplib
import os
import re

def find_hdf5(ftp, dirname):
	filelist = []
	
	try:
		ftp.cwd(dirname)	# enter this dir
	except ftplib.error_perm:
		return;

	ftp.retrlines('LIST', filelist.append)
	print '---------------------------enter '+ dirname + '--------------------------------------'

	dirs = ftp.nlst()

	for line in filelist:
		fieldList = line.split(None, 8)
		flname = fieldList[-1]

		if len(fieldList) < 6:
			continue

		elif flname == '.' or flname == '..':
			continue		
		elif re.match('^d', fieldList[0]) is not None: 
			find_hdf5(ftp, flname)
		elif re.match('^-', fieldList[0]) is not None:
#			ret = flname.find('.h5')
			if re.match('.*\.h5$', filename) is not None and os.path.isfile(filedir+flname) == False:
				try:
					print 'start downloading file: ' + flname
					filehandler = open(filedir+flname, 'wb').write
					ftp.retrbinary('RETR ' + flname, filehandler)
					print 'end downloading file: ' + flname
				except ftplib.error_perm:
					print flname

	ftp.cwd('../')			# quit this dir
	print '---------------------------quit ' + dirname + '--------------------------------------'


def main():
	# main body
	ftpaddr = 'ftp.hdfgroup.uiuc.edu'
	#ftpaddr = '192.168.0.254'
	name = 'anonymous'
	pswd = 'anonymous'
	
	ftp = ftplib.FTP(ftpaddr)

	ftp.login()

	#ftp.retrlines('LIST')

	ftp.cwd('/pub')

	find_hdf5(ftp, 'outgoing')

	ftp.quit()
	ftp.close()
	
	return


filedir = '/home/chen/workspace/h5toNC4/h5diff/ftptest/'

if __name__ == '__main__':
	main()


