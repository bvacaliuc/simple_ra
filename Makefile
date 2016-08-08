#
# Alternate way of running the various setup scripts

# NB: do not change this after first install, it gets 'remembered'
#     by gr-ra_blocks.
WRITABLE=/usr/local/var

# download/install - requires a network connection
all:	${WRITABLE}
	chmod a+x ./setup.sh
	sudo ./setup.sh ${WRITABLE} | tee -a ${WRITABLE}/setup.log

# reinstall after reboot - assume $cwd on the persistent media
reinstall:
	chmod a+x ./reinstall.sh
	./reinstall.sh ${WRITABLE} | tee -a ${WRITABLE}/reinstall.log

# initialize persistent media
persistent:
	chmod a+x ./persistent.sh
	./persistent.sh ${WRITABLE} | tee -a ${WRITABLE}/persistent.log

# create folder (when not using persistent media)
${WRITABLE}:
	sudo mkdir -p ${WRITABLE}

