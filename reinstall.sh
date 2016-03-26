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

# Configure dependencies (from simple_ra/README)
if [ -z "`grep PATH ${HOME}/.bashrc | grep ${HOME}/bin`" ] ; then
	echo "export PATH=\"${HOME}/bin;${PATH}\"" >> ${HOME}/.bashrc
	export PATH="${HOME}/bin;${PATH}"
fi
if [ -z "`grep PYTHONPATH ${HOME}/.bashrc | grep ${HOME}/bin`" ] ; then
	echo "export PYTHONPATH=\"${HOME}/bin;${PYTHONPATH}\"" >> ${HOME}/.bashrc
	export PYTHONPATH="${HOME}/bin;${PYTHONPATH}"
fi

# re-install pyephem
sudo pip install ${WRITABLE}/pyephem/pyephem-3.7.6.0.tar.gz

# re-install gr-ra_blocks
(cd ${WRITABLE}/gr-ra_blocks ; sudo make install ; sudo ldconfig)

# re-install simple_ra
(cd ${WRITABLE}/simple_ra ; sudo make install)
# this puts stuff in $HOME/bin, but makes a few mistakes...
##cd ${HOME}/bin
##sudo chown ubuntu:ubuntu simple_ra_receiver.py

# give a hint...
echo simple_ra is probably going to work...
echo execute it from the command line by:
echo
echo cd ${HOME}/bin
echo sudo ./simple_ra --devid rtl=0,buflen=65536 --spde
echo 
echo and when you are running in spectral mode, be sure to press 'Autoscale'
cd ${HOME}/bin

