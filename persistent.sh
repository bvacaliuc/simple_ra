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

echo '\nSelected:'
echo WRITABLE=${WRITABLE}
echo dev=${dev}
echo mnt=${mnt}
echo udev=${udev}

if [ -z "${dev}" -o -z "${mnt}" ] ; then
	echo '\nYour choice did not match an existing device or mount'
	echo 'try again...'
	exit 1
fi
if [ ! -b "${dev}" -o ! -d "${mnt}" ] ; then
	echo '\nEither dev is not a device or mnt is not a folder'
	echo 'try again...'
	exit 1
fi
echo '\nUsing:'
if ! (echo "${mnt}" | grep media) ; then
	echo '\nThe device you selected is not a media device.'
	echo 'This will not likely have the effect you want and'
	echo 'I am too cowardly to go on, so please try again...'
	exit 1
fi

echo "\nInitializing ${dev} for persistent storage"
echo '*** LAST chance to stop before wiping the disk ***'
echo ''
echo 'Are you sure you are ready to do this?  You must type "yes"'
read res
if [ ! ${res} = "yes" ] ; then
	exit 1
fi

# TEMPORARY: remove
echo "*** next steps are to unmount/partition and create the filesystem"
echo "    but they have yet to be implemented"

# unmount the disk

# redefine the partition type

# create a file system

# re-mount the file system

# create the /src, /var folders and copy the project to the /src




# create a 



