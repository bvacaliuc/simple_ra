#!/bin/sh
# Re-Initialize installed programs from a (writable) DISK (USB,SSD,HDD,etc.)
WRITABLE=${1:-/usr/local/var}

# the disk that *this* script is running is the writable and is already mounted
dev=`df -h . | tail -1 | tr -s ' ' | cut -f1 -d' '`
mnt=`df -h . | tail -1 | tr -s ' ' | cut -f6 -d' '`

echo dev=${dev}
echo mnt=${mnt}
echo WRITABLE=${WRITABLE}

# reference this writable DISK
if [ ! -d ${WRITABLE} -o ! -L ${WRITABLE} ] ; then
	sudo ln -s ${mnt}/var ${WRITABLE}
fi

# reference the simple_ra_data/ from the writable DISK
if [ -d ${HOME}/simple_ra_data ] ; then
	sudo mv ${HOME}/simple_ra_data ${HOME}/simple_ra_data.previous
fi
sudo ln -s -f ${mnt}/simple_ra_data ${HOME}/simple_ra_data 

# Configure dependencies (from simple_ra/README)
if [ -z "`grep PATH ${HOME}/.bashrc | grep ${HOME}/bin`" ] ; then
	echo "export PATH=\"${HOME}/bin:${PATH}\"" >> ${HOME}/.bashrc
	export PATH="${HOME}/bin:${PATH}"
fi
if [ -z "`grep PYTHONPATH ${HOME}/.bashrc | grep ${HOME}/bin`" ] ; then
	echo "export PYTHONPATH=\"${HOME}/bin:${PYTHONPATH}\"" >> ${HOME}/.bashrc
	export PYTHONPATH="${HOME}/bin:${PYTHONPATH}"
fi

# check if files are present or not (maybe they forgot to build)
if [ ! -f ${WRITABLE}/pyephem/pyephem-3.7.6.0.tar.gz -o \
     ! -f ${WRITABLE}/gawk/gawk-4.0.1.tar.gz -o \
     ! -d ${WRITABLE}/gr-ra_blocks -o \
     ! -d ${WRITABLE}/simple_ra ] ; then
	cat << EOF | cat

One or more of the files/folders needed to reinstall simple_ra
are missing.  Is it possible that you forgot a step?  If that
is so, there is an easy fix!  Just make sure your network is
connected, and then type:

make

Then, next time you have to reboot, you only need to type:

make reinstall

Like you were hoping to do this time, or use the desktop icon.

(I'm not going to do it because I'm afraid.  But you might have
enough courage to do it!)

EOF
	exit 1
fi

# re-install pyephem
sudo pip install ${WRITABLE}/pyephem/pyephem-3.7.6.0.tar.gz

# re-install gawk
(cd /tmp ; tar xf ${WRITABLE}/gawk/gawk-4.0.1.tar.gz ; cd gawk-4.0.1 ; ./configure ; make ; sudo make install )

# re-install gr-ra_blocks
(cd ${WRITABLE}/gr-ra_blocks ; sudo make install ; sudo ldconfig)

# re-install simple_ra
(cd ${WRITABLE}/simple_ra ; sudo make install)
# this puts stuff in $HOME/bin

if [ ! -x ${HOME}/bin/simple_ra ] ; then
	echo "Bummer.  simple_ra did not get built where I expected it."
	echo ""
	echo "Well, if you don't mind, please report this issue at:"
	echo "https://github.com/bvacaliuc/simple_ra/issues"
	echo ""
	echo "Please include the file ${WRITABLE}/reinstall.log"
	exit 1
fi

# give a hint...
echo simple_ra is probably going to work...
echo execute it from the command line by:
echo
echo cd ${HOME}/bin
echo sudo ./simple_ra --devid rtl=0,offset_tune=1
echo 
echo and when you are running in spectral mode, be sure to press 'Autoscale'
#cd ${HOME}/bin

