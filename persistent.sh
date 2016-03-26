#!/bin/sh
# Configure a (writable) DISK (USB,SSD,HDD,etc.) to hold installed programs and data
WRITABLE=${1:-/usr/local/var}

echo 'Ensure you have the disk you wish to use for persistent storage connected'
echo 'and that it is listed in the following table:'
df -h
echo 'type the device for the disk you wish to configure (e.g. /dev/sdb1):'
read udev

# obtain device path and mount point of selected disk
dev=`df -h | grep $udev | tr -s ' ' | cut -f1 -d' '`
mnt=`df -h | grep $udev | tr -s ' ' | cut -f6 -d' '`

echo WRITABLE=${WRITABLE}
echo dev=${dev}
echo mnt=${mnt}
echo udev=${udev}

if [ -z ${dev} -o -z ${mnt} ] ; then
	echo 'your choice did not match an existing device or mount'
	echo 'try again...'
	exit 1
fi
if [ ! -b ${dev} -o ! -d ${mnt} ] ; then
	echo 'either dev is not a device or mnt is not a folder'
	echo 'try again...'
	exit 1
fi

echo "Initializing ${dev} for persistent storage"
echo '*** LAST chance to stop before wiping the disk ***'
echo ''
echo 'Are you sure you are ready to do this?  You must type "yes"'
read res
if [ ! ${res} = "yes" ] ; then
	exit 1
fi

# unmount the disk

# redefine the partition type

# create a file system

# re-mount the file system

# create the /src, /var folders and copy the project to the /src




# create a 



