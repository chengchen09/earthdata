package CIFS; 

#modify cmd
#$cmdmask[0x06] = 1;  # *  SMB_COM_DELETE: write|file         
#$cmdmask[0x07] = 1;  # *  SMB_COM_RENAME: write|file                 
#$cmdmask[0x0B] = 1;  # *d SMB_COM_WRITE: write|file                  
#$cmdmask[0x2F] = 1;  # *  SMB_COM_WRITE_ANDX: write|file              
#$cmdmask[0xA2] = 1;  # *  SMB_COM_NT_CREATE_ANDX      
#$cmdmask[0xD8] = 1; #	TRANS2_SET_FILE_INFORMATION: write|file
#$cmdmask[0xF3] = 1; #	NT_TRANSACT_SET_SECURITY_DESC

#not appeared in the modify-corp file, 17 times in modify-engi file
#$cmdmask[0xD6] = 1; #	TRANS2_SET_PATH_INFORMATION: write|directory
#not apperaed in the modify file
#$cmdmask[0xDD] = 1; #	TRANS2_CREATE_DIRECTORY: write|directory
#f1 is a invalid command
#$cmdmask[0xF1] = 1; # x	NT_TRANSACT_CREATE: open/create: appear 87 times in corporate and 2462 times in corporate
#not appeared in the modify file
#$cmdmask[0xF5] = 1; #	NT_TRANSACT_RENAME

my @cmdmask;
$cmdmask[0x00] = 1;  # ^d SMB_COM_CREATE_DIRECTORY       
$cmdmask[0x01] = 1;  # ^  SMB_COM_DELETE_DIRECTORY       
$cmdmask[0x02] = 0;  #  d SMB_COM_OPEN                   
$cmdmask[0x03] = 0;  #  d SMB_COM_CREATE                 
$cmdmask[0x04] = 0;  # *x SMB_COM_CLOSE           x                 
$cmdmask[0x05] = 0;  # *  SMB_COM_FLUSH                  
$cmdmask[0x06] = 1;  # *  SMB_COM_DELETE: write|file           
$cmdmask[0x07] = 1;  # *  SMB_COM_RENAME: write|file                 
$cmdmask[0x08] = 0;  # *d SMB_COM_QUERY_INFORMATION      
$cmdmask[0x09] = 1;  # *d SMB_COM_SET_INFORMATION: write|file        
$cmdmask[0x0A] = 0;  #  d SMB_COM_READ                   
$cmdmask[0x0B] = 1;  # *d SMB_COM_WRITE: write|file                  
$cmdmask[0x0C] = 0;  #  d SMB_COM_LOCK_BYTE_RANGE        
$cmdmask[0x0D] = 0;  #  d SMB_COM_UNLOCK_BYTE_RANGE      
$cmdmask[0x0E] = 0;  #    SMB_COM_CREATE_TEMPORARY       
$cmdmask[0x0F] = 0;  #  d SMB_COM_CREATE_NEW             
$cmdmask[0x10] = 0;  # *  SMB_COM_CHECK_DIRECTORY        
$cmdmask[0x11] = 0;  #  d SMB_COM_PROCESS_EXIT           
$cmdmask[0x12] = 0;  #    SMB_COM_SEEK                   
$cmdmask[0x13] = 0;  #  d SMB_COM_LOCK_AND_READ          
$cmdmask[0x14] = 0;  #  d SMB_COM_WRITE_AND_UNLOCK       
$cmdmask[0x1A] = 0;  #  d SMB_COM_READ_RAW               
$cmdmask[0x1B] = 0;  #  d SMB_COM_READ_MPX               
$cmdmask[0x1C] = 0;  #    SMB_COM_READ_MPX_SECONDARY     
$cmdmask[0x1D] = 0;  #  d SMB_COM_WRITE_RAW              
$cmdmask[0x1E] = 0;  #  d SMB_COM_WRITE_MPX              
$cmdmask[0x20] = 0;  #    SMB_COM_WRITE_COMPLETE         
$cmdmask[0x22] = 0;  #  d SMB_COM_SET_INFORMATION2       
$cmdmask[0x23] = 0;  #  d SMB_COM_QUERY_INFORMATION2     
$cmdmask[0x24] = 0;  # *  SMB_COM_LOCKING_ANDX           
$cmdmask[0x25] = 0;  # *x SMB_COM_TRANSACTION           x  : appear 8936966 times in corporate, 5291873 times in engineer      
$cmdmask[0x26] = 0;  #    SMB_COM_TRANSACTION_SECONDARY  
$cmdmask[0x27] = 0;  #    SMB_COM_IOCTL                  
$cmdmask[0x28] = 0;  #    SMB_COM_IOCTL_SECONDARY        
$cmdmask[0x29] = 0;  #    SMB_COM_COPY                   
$cmdmask[0x2A] = 0;  #    SMB_COM_MOVE                   
$cmdmask[0x2B] = 0;  # *  SMB_COM_ECHO                   
$cmdmask[0x2C] = 0;  #  d SMB_COM_WRITE_AND_CLOSE        

# different
$cmdmask[0x2D] = 0;  # *d SMB_COM_OPEN_ANDX              

$cmdmask[0x2E] = 0;  # *  SMB_COM_READ_ANDX              
$cmdmask[0x2F] = 1;  # *  SMB_COM_WRITE_ANDX: write|file              
$cmdmask[0x31] = 0;  #    SMB_COM_CLOSE_AND_TREE_DISC    
$cmdmask[0x32] = 0;  # *x SMB_COM_TRANSACTION2           x
$cmdmask[0x33] = 0;  #    SMB_COM_TRANSACTION2_SECONDARY 
$cmdmask[0x34] = 0;  # *x SMB_COM_FIND_CLOSE2            
$cmdmask[0x35] = 0;  #    SMB_COM_FIND_NOTIFY_CLOSE      
$cmdmask[0x70] = 0;  #  d SMB_COM_TREE_CONNECT           
$cmdmask[0x71] = 0;  # *  SMB_COM_TREE_DISCONNECT        
$cmdmask[0x72] = 0;  #	  SMB_COM_NEGOTIATE              
$cmdmask[0x73] = 0;  # *  SMB_COM_SESSION_SETUP_ANDX     
$cmdmask[0x74] = 0;  # *  SMB_COM_LOGOFF_ANDX            
$cmdmask[0x75] = 0;  # *  SMB_COM_TREE_CONNECT_ANDX      
$cmdmask[0x80] = 0;  #  d SMB_COM_QUERY_INFORMATION_DISK 
$cmdmask[0x81] = 0;  #  d SMB_COM_SEARCH                 
$cmdmask[0x82] = 0;  #    SMB_COM_FIND                   
$cmdmask[0x83] = 0;  #    SMB_COM_FIND_UNIQUE            
$cmdmask[0xA0] = 0;  # *x SMB_COM_NT_TRANSACT            
$cmdmask[0xA1] = 0;  #    SMB_COM_NT_TRANSACT_SECONDARY  
$cmdmask[0xA2] = 1;  # *  SMB_COM_NT_CREATE_ANDX         
$cmdmask[0xA4] = 0;  # *  SMB_COM_NT_CANCEL              
$cmdmask[0xC0] = 0;  #    SMB_COM_OPEN_PRINT_FILE        
$cmdmask[0xC1] = 0;  #  d SMB_COM_WRITE_PRINT_FILE       
$cmdmask[0xC2] = 0;  #  d SMB_COM_CLOSE_PRINT_FILE       
$cmdmask[0xC3] = 0;  #    SMB_COM_GET_PRINT_QUEUE

# subcmd of SMB_COM_TRANSACTION2(0x32) from d0-d1
# ^ means not find in the trace data
$cmdmask[0xD0] = 1;	# ^	TRANS2_OPEN2: not find in parse data
$cmdmask[0xD1] = 0; #	TRANS2_FIND_FIRST2
$cmdmask[0xD2] = 0; #	TRANS2_FIND_NEXT2
$cmdmask[0xD3] = 0; #	TRANS2_QUERY_FS_INFORMATION
$cmdmask[0xD4] = 0; #	Reserved
$cmdmask[0xD5] = 0; #	TRANS2_QUERY_PATH_INFORMATION
$cmdmask[0xD6] = 1; #	TRANS2_SET_PATH_INFORMATION: write|directory
$cmdmask[0xD7] = 0; #	TRANS2_QUERY_FILE_INFORMATION
$cmdmask[0xD8] = 1; #	TRANS2_SET_FILE_INFORMATION: write|file
$cmdmask[0xD9] = 0; #	Not implemented by NT server
$cmdmask[0xDA] = 0; #	Not implemented by NT server
$cmdmask[0xDB] = 0; #	Not implemented by NT server
$cmdmask[0xDC] = 0; #	Not implemented by NT server
$cmdmask[0xDD] = 1; #	TRANS2_CREATE_DIRECTORY: write|directory
$cmdmask[0xDE] = 0; #	TRANS2_SESSION_SETUP
$cmdmask[0xE0] = 0; #	TRANS2_GET_DFS_REFERRAL
$cmdmask[0xE1] = 0; #	TRANS2_REPORT_DFS_INCONSISTENCY

# SMB_COM_NT_TRANSACTION(0xa0) Subcommand Codes: f1-f6
$cmdmask[0xF1] = 1; # x	NT_TRANSACT_CREATE: open/create: appear 87 times in corporate and 2462 times in corporate
$cmdmask[0xF2] = 0; #	NT_TRANSACT_IOCTL
$cmdmask[0xF3] = 1; #	NT_TRANSACT_SET_SECURITY_DESC
$cmdmask[0xF4] = 0; #	NT_TRANSACT_NOTIFY_CHANGE
$cmdmask[0xF5] = 1; #	NT_TRANSACT_RENAME
$cmdmask[0xF6] = 0; #	NT_TRANSACT_QUERY_SECURITY_DESC

sub getflag{
	my ($cmd) = @_;
	
	return $cmdmask[hex $cmd];
}

sub check_modify{
	my ($item) = @_;
	my $cmd;
	my @field;
	
	$cmd = substr($item, 0, 2);
	if($cmd ne "a2"){
		return $cmdmask[hex $cmd];
	}
	elsif((split(/\|/, $item))[4] eq "w"){
		return 1;
	}

	return 0;
}

1;
