#!/bin/sh
# NB: the below line is to create a mountable/writable filesystem to /usr/local/var
#     the mount point will be different on every system/VM.  it must be world-writable/readable
# ln -s /media/ubuntu/2917309f-7599-4b7a-8fb6-1708ffc4050c/var /usr/local/var
# ugh.. its just a hassle.  Use $HOME/var, or whatever...  but it needs to exist... and writable
WRITABLE=${1:-/usr/local/var}
if [ ! -d ${WRITABLE} ] ; then
	sudo mkdir -p ${WRITABLE}
fi
sudo chmod a+rwx ${WRITABLE}
if ! touch ${WRITABLE}/.check ; then
	echo "I must be able to write to ${WRITABLE}"
	echo "I tried to fix it for you, but it didn't work."
	echo "Please fix it, or tell me where else to put my stuff"
	echo "by re-running this script with a different path; e.g."
	echo ""
	echo "$0 /a-folder-that-can-be-written-to"
	exit 1
fi

# Where are we?
plumb=`pwd`

# Configure dependencies (from simple_ra/README)
if [ -z "`grep PATH ${HOME}/.bashrc | grep ${HOME}/bin`" ] ; then
	echo "export PATH=\"${HOME}/bin:${PATH}\"" >> ${HOME}/.bashrc
	export PATH="${HOME}/bin:${PATH}"
fi
if [ -z "`grep PYTHONPATH ${HOME}/.bashrc | grep ${HOME}/bin`" ] ; then
	echo "export PYTHONPATH=\"${HOME}/bin:${PYTHONPATH}\"" >> ${HOME}/.bashrc
	export PYTHONPATH="${HOME}/bin:${PYTHONPATH}"
fi

# Determine GNU Radio version
# https://github.com/bvacaliuc/simple_ra/issues/2
version=`python -c "from gnuradio import gr ; print gr.version()"`
major=`echo $version | cut -d. -f1`
minor=`echo $version | cut -d. -f2`
release=`echo $version | cut -d. -f3`
patch=`echo $version | cut -d. -f4`

# diagnostic
echo GNURadio Version $major.$minor.$release.$patch

# implement certain variants
simple_ra_build_sudo=
simple_ra_exec_sudo=

if [ ! $major -eq 3 -o \( $major -eq 3 -a ! $minor -eq 7 \) ] ; then
	echo "This appears to be GNU Radio version $version"
	echo "I only know how to deal with version 3.7.x at the moment"
	echo "If you are game to go on, so am I, but you have to say 'yes'"
	read response
	if [ ! "$response" = "yes" ] ; then
		exit 1
	fi
# 3.7.x from now on...
elif [ $release -lt 9 -o \( $release -eq 9 -a -z "$patch" \) ] ; then
	echo "This appears to be GNU Radio version $version"
	echo "I have not worked with GNU Radio versions less than 3.7.9.1"
	echo "so I might do the wrong things.  Please be patient with me..."
	echo ""
	echo "Hit Enter to go on."
	read _junk
elif [ $release -eq 9 -a ! -z "$patch" ] ; then
	# 3.7.9.x in here
	if [ $patch -eq 1 ] ; then
		# 3.7.9.1 needs to build simple_ra with sudo
		# otherwise, you get 'file open error' on fsm::fsm and the files are created owned by root
		# and the ubuntu user cannot execute them.
		simple_ra_build_sudo=sudo		         			simple_ra_exec_sudo=sudo
	fi
elif [ $release -eq 10 -a -z "$patch" ] ; then
	echo "Aha!  This is that GNU Radio version with Bug #927"
	echo "http://gnuradio.org/redmine/issues/927"
	echo ""
	echo "I am going to apply the patch and go on.  I just want you"
	echo "to be aware of this.  Hit Enter to go on."
	read _junk

	# download and obtain the patch
	# http://stackoverflow.com/questions/6658313/generate-a-git-patch-for-a-specific-commit
	repo='https://github.com/gnuradio/gnuradio-wg-grc.git'
	folder=`echo $repo | cut -d/ -f5 | cut -d. -f1`
	sha='df86a6bf1ec0a1e628eba5e916859ba38c7c769c'
	base='/usr/local/src/pybombs_legacy/src/gnuradio/gr-utils'
	if [ ! -e ${WRITABLE}/$sha.patch ] ; then
		git clone $repo
		( cd $folder ; git format-patch -1 $sha --stdout ) > ${WRITABLE}/$sha.patch
		if [ ! -e ${WRITABLE}/$sha.patch ] ; then
			echo "Something went wrong...  I could not create the patch for you"
			echo "Please report this issue at:"
			echo "https://github.com/bvacaliuc/simple_ra/issues"
			exit 1
		fi
	fi

	# http://unix.stackexchange.com/questions/55780/check-if-a-file-or-folder-has-been-patched-already
	patch -p2 -N --dry-run -d $base < ${WRITABLE}/$sha.patch
	if [ $? -eq 0 ] ; then
		# apply the patch to the current GNU Radio Live DVD
		git apply --stat ${WRITABLE}/$sha.patch
		sudo chmod a+rwx $base/python/utils		# patch wants to make a tmpfile named grcc.xxxx
		sudo chmod a+rwx $base/python/utils/grcc	# patch needs to modify this file
		patch -p2 -N -d $base < ${WRITABLE}/$sha.patch
	fi
	sudo chmod a+rwx /usr/local/bin/grcc			# and this is the file that we use
	cp $base/python/utils/grcc /usr/local/bin/grcc
elif [ $release -eq 10 -a ! -z "$patch" ] ; then
	# 3.7.10.x in here
	if [ $patch -eq 1 ] ; then
		# 3.7.10.1 seems to build ok, but
		# you still get 'file open error' on fsm::fsm
		# even if you use sudo to build it.
		# The ubuntu user can execute ok either way
		echo ""
	else
		echo "This appears to be GNU Radio version $version"
		echo "I have not tested GNU Radio versions of 3.7.10 greater than 3.7.10.1"
		echo "so I might do the wrong things.  Please be patient with me..."
		echo ""
		echo "Hit Enter to go on."
		read _junk
	fi
elif [ $release -gt 10 ] ; then
	echo "This appears to be GNU Radio version $version"
	echo "I have not worked with GNU Radio versions greater than 3.7.10"
	echo "so its anybody's guess what might happen."
	echo ""
	echo "If you are willing to have a go, so am I but don't blame me if it doesn't work."
	echo "If you have enough 'courage' to go on, then type that, otherwise"
	echo "I'm too afraid and you are on your own."
	read response
	if [ ! "$response" = "courage" ] ; then
		exit 1
	fi
fi

# Installing dependencies (from simple_ra/README)
#sudo pip install ephem
# http://stackoverflow.com/questions/15031694/installing-python-packages-from-local-file-system-folder-with-pip
# http://stackoverflow.com/questions/27870003/pip-install-please-check-the-permissions-and-owner-of-that-directory
mkdir -p ${WRITABLE}/pyephem
echo "3d6c19d92a2a80fef87770f3e2007453 pyephem-3.7.6.0.tar.gz" > ${WRITABLE}/pyephem/md5sum.txt
(cd ${WRITABLE}/pyephem ; wget https://pypi.python.org/packages/source/p/pyephem/pyephem-3.7.6.0.tar.gz ; md5sum -c md5sum.txt )
sudo -H pip install ${WRITABLE}/pyephem/pyephem-3.7.6.0.tar.gz

# simple_ra requires gawk (and GNU Radio Live DVD installs 4.0.1 using apt-get)
mkdir -p ${WRITABLE}/gawk
echo "bab2bda483e9f32be65b43b8dab39fa5 gawk-4.0.1.tar.gz" > ${WRITABLE}/gawk/md5sum.txt
(cd ${WRITABLE}/gawk ; wget http://ftp.gnu.org/gnu/gawk/gawk-4.0.1.tar.gz ; md5sum -c md5sum.txt )
(cd /tmp ; tar xf ${WRITABLE}/gawk/gawk-4.0.1.tar.gz ; cd gawk-4.0.1 ; ./configure ; make ; sudo make install )

# simple_ra requires gr-ra_blocks
(cd ${WRITABLE} ; git clone https://github.com/patchvonbraun/gr-ra_blocks.git)
(cd ${WRITABLE}/gr-ra_blocks ; cmake . ; make ; sudo make install ; sudo ldconfig)

# get simple_ra, build it
(cd ${WRITABLE} ; git clone https://github.com/patchvonbraun/simple_ra.git)
(cd ${WRITABLE}/simple_ra ; $simple_ra_build_sudo make ; sudo make install)

if [ ! -x ${HOME}/bin/simple_ra ] ; then
	echo "Bummer.  simple_ra did not get built where I expected it."
	echo ""
	echo "Well, if you don't mind, please report this issue at:"
	echo "https://github.com/bvacaliuc/simple_ra/issues"
	echo ""
	echo "Please include the file ${WRITABLE}/setup.log"
	exit 1
fi
# give a hint...
echo ""
echo "**********"
echo "*** OK ***"
echo "**********"
echo simple_ra is probably going to work...
echo execute it from the command line by:
echo
echo cd ${HOME}/bin
echo $simple_ra_exec_sudo ./simple_ra --devid rtl=0
echo 
echo and when you are running in spectral mode, be sure to press 'Autoscale'




