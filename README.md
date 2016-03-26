# simple_ra/extras
Extras for Simple (hah) integrated radio astronomy receiver for Gnu Radio Live DVD (and others?)

Step #1: get a Gnu Radio Live DVD/USB up and running
see: https://gnuradio.org/redmine/projects/gnuradio/wiki/GNURadioLiveDVD

Step #2: clone and switch to extras branch

git clone https://github.com/bvacaliuc/simple_ra.git
(cd simple_ra ; git checkout extras)

Step #3: do the "extra" stuff needed

make

Step #4: enjoy simple_ra with the Gnu Radio Live DVD

cd $HOME/bin
sudo ./simple_ra --devid rtl=0,buflen=65536 --spde

NOTE: there are several types of devices supported by simple_ra.  The list of sources is given in the console when the program starts and includes: rtl, rtl_tcp, uhd, hackrf, bladerf, rfspace, airspy and redpitaya.  Other devices may become available via the gr-osmosdr device support.

Advanced: If you would like to setup a second USB disk to use as persistent storage or to use the Gnu Radio Live DVD/USB without a network connection, please see these [instructions](https://github.com/bvacaliuc/simple_ra/blob/extras/PERSISTENT.md)

