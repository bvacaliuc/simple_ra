#
# Alternate way of running the various setup scripts

all:	mount
	chmod a+x ./setup.sh
	sudo ./setup.sh

mount:	${WRITABLE}
	sudo ln -s ${WRITABLE} /usr/local/var

${WRITABLE}:
	mkdir -p ${WRITABLE}

