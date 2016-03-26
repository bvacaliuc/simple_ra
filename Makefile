#
# Alternate way of running the various setup scripts

# NB: do not change this after first install, it gets 'remembered'
#     by gr-ra_blocks.
WRITABLE=/usr/local/var

# download/install - requires a network connection
all:	${WRITABLE}
	chmod a+x ./setup.sh
	sudo ./setup.sh ${WRITABLE}

# reinstall after reboot - assume $cwd on the persistent media
reinstall:
	chmod a+x ./reinstall.sh
	./reinstall.sh ${WRITABLE}

# initialize persistent media
persistent:
	chmod a+x ./persistent.sh
	./persistent.sh ${WRITABLE}

# create folder (when not using persistent media)
${WRITABLE}:
	mkdir -p ${WRITABLE}

