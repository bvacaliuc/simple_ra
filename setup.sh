#!/bin/sh
# NB: the below line is to create a mountable/writable filesystem to /usr/local/var
#     the mount point will be different on every system/VM.  it must be world-writable/readable
# ln -s /media/ubuntu/2917309f-7599-4b7a-8fb6-1708ffc4050c/var /usr/local/var
# ugh.. its just a hassle.  Use $HOME/var, or whatever...  but it needs to exist
WRITABLE=${1:-/usr/local/var}

# Configure dependencies (from simple_ra/README)
if [ -z "`grep PATH ${HOME}/.bashrc | grep ${HOME}/bin`" ] ; then
	echo "export PATH=\"${HOME}/bin;${PATH}\"" >> ${HOME}/.bashrc
	export PATH="${HOME}/bin;${PATH}"
fi
if [ -z "`grep PYTHONPATH ${HOME}/.bashrc | grep ${HOME}/bin`" ] ; then
	echo "export PYTHONPATH=\"${HOME}/bin;${PYTHONPATH}\"" >> ${HOME}/.bashrc
	export PYTHONPATH="${HOME}/bin;${PYTHONPATH}"
fi

# Installing dependencies (from simple_ra/README)
#sudo pip install ephem
# http://stackoverflow.com/questions/15031694/installing-python-packages-from-local-file-system-folder-with-pip
mkdir -p ${WRITABLE}/pyephem
echo "3d6c19d92a2a80fef87770f3e2007453 pyephem-3.7.6.0.tar.gz" > ${WRITABLE}/pyephem/md5sum.txt
(cd ${WRITABLE}/pyephem ; wget https://pypi.python.org/packages/source/p/pyephem/pyephem-3.7.6.0.tar.gz ; md5sum -c md5sum.txt )
sudo pip install ${WRITABLE}/pyephem/pyephem-3.7.6.0.tar.gz

# simple_ra/README says to use svn, but the repos has moved...
##svn co https://www.cgran.org/svn/projects/gr-ra_blocks
(cd ${WRITABLE} ; git clone https://github.com/patchvonbraun/gr-ra_blocks.git)
(cd ${WRITABLE}/gr-ra_blocks ; cmake . ; make ; sudo make install ; sudo ldconfig)

# get simple_ra, build it
(cd ${WRITABLE} ; git clone https://github.com/patchvonbraun/simple_ra.git)
(cd ${WRITABLE}/simple_ra ; sudo make install)
# this puts stuff in $HOME/bin, but makes a few mistakes...
#cd ${HOME}/bin
#sudo chown ubuntu:ubuntu simple_ra_receiver.py

# give a hint...
echo simple_ra is probably going to work...
echo execute it from the command line by:
echo
echo cd ${HOME}/bin
echo sudo ./simple_ra --devid rtl=0,buflen=65536 --spde
echo 
echo and when you are running in spectral mode, be sure to press 'Autoscale'
#cd ${HOME}/bin



