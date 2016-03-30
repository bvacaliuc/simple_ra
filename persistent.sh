#!/bin/sh
# Configure a (writable) DISK (USB,SSD,HDD,etc.) to hold installed programs and data
WRITABLE=${1:-/usr/local/var}
expert=0

echo 'Ensure you have the disk you wish to use for persistent storage connected'
echo 'and that it is listed in the following table:'
df -h
echo 'type the device for the disk you wish to configure (e.g. /dev/sdb1):'
read udev

# obtain device path and mount point of selected disk
dev=`df -h | grep $udev | tr -s ' ' | cut -f1 -d' '`
mnt=`df -h | grep $udev | tr -s ' ' | cut -f6- -d' ' --output-delimiter=',' | tr -d ','`

echo '\nSelected:'
echo WRITABLE=${WRITABLE}
echo dev=${dev}
echo mnt=${mnt}
echo udev=${udev}

if [ -z "${dev}" -o -z "${mnt}" ] ; then
	echo '\nYour choice did not match an existing device or mount'
	if [ -b "${udev}" ] ; then
		echo 'But it is a valid block device, so it could be used.'
		echo 'Do you want to use this device?  The partition table is as follows:'
		sudo fdisk -l ${udev}
		echo 'Are you sure you want to use this DISK?  You must type "yes"'
		read res
		if [ ! ${res} = "yes" ] ; then
			exit 1
		fi
		expert=1	# prevent media check later..
		dev=${udev}1
		mnt=/mnt
	else
		echo 'try again...'
		exit 1
	fi
fi
if [ ! -b "${dev}" -o ! -d "${mnt}" ] ; then
	echo "\nEither dev is not a device or '${mnt}' is not a folder"
	echo 'try again...'
	exit 1
fi
echo '\nUsing:'
if ! (echo "${mnt}" | grep media) ; then
	if [ $expert -ne 1 ] ; then
		echo '\nThe device you selected is not a media device.'
		echo 'This will not likely have the effect you want and'
		echo 'I am too cowardly to go on, so please try again...'
		exit 1
	fi
fi

# http://stackoverflow.com/questions/16623835/bash-remove-a-fixed-prefix-suffix-from-a-string
dev1=${dev%%[0-9]}
part=${dev#${dev1}}
sudo fdisk -l ${dev1}

echo "\nInitializing ${dev1}, partition ${part} for persistent storage"
echo '*** LAST chance to stop before wiping the ENTIRE disk ***'
echo ''
echo 'Are you sure you are ready to do this?  You must type "yes"'
read res
if [ ! ${res} = "yes" ] ; then
	exit 1
fi

# unmount the disk
sudo umount "${mnt}"

# partition the disk and set the partition type
#http://superuser.com/questions/332252/creating-and-formating-a-partition-using-a-bash-script
sed -e 's/\t\([\+0-9a-zA-Z]*\)[ \t].*/\1/' << EOF | sudo fdisk ${dev1}
	o # clear the in memory partition table
	n # new partition
	p # primary partition
	1 # partition number 1
	 # default - start at beginning of disk 
	 # default - use the entire disk
	t # change partition type
	83 # Linux partition
	p # print the in-memory partition table
	w # write the partition table
	q # and we're done
EOF

# create a file system
sudo mke2fs ${dev}

# re-mount the file system
sudo mount ${dev} /mnt

# create the /src, /var folders and copy the project to the /src
sudo chmod a+w /mnt
mkdir /mnt/src
mkdir /mnt/var
mkdir /mnt/simple_ra_data
cwd=`pwd`
cp -r ../$(basename $cwd) /mnt/src

# re-create the symbolic link to the persistent media
if [ ! -d ${WRITABLE} -o ! -L ${WRITABLE} ] ; then
	sudo ln -s -f /mnt/var ${WRITABLE}
fi

# create or copy the /simple_ra_data, link to it
if [ -d ${HOME}/simple_ra_data ] ; then
	sudo cp -r ${HOME}/simple_ra_data /mnt/simple_ra_data
	sudo mv ${HOME}/simple_ra_data ${HOME}/simple_ra_data.copied-to-persistent
else
	mkdir /mnt/simple_ra_data
fi
sudo ln -s -f /mnt/simple_ra_data ${HOME}/simple_ra_data





