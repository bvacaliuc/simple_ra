#
# Alternate way of running the various setup scripts

all:	mount
	chmod a+x ./setup.sh
	sudo ./setup.sh

# figure out where your writable file system is
##WRITABLE=/media/ubuntu/2917309f-7599-4b7a-8fb6-1708ffc4050c/var
WRITABLE=$HOME/var

mount:	$WRITABLE
	sudo ln -s $WRITABLE /usr/local/var 

$WRITABLE:
	mkdir $WRITABLE

