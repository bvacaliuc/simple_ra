# simple_ra/extras
Extras for Simple (hah) integrated radio astronomy receiver for Gnu Radio Live DVD (and others?)

Step #1: get a Gnu Radio Live DVD/USB up and running
see: https://gnuradio.org/redmine/projects/gnuradio/wiki/GNURadioLiveDVD

step #2: clone and switch to extras branch

git clone https://github.com/bvacaliuc/simple_ra.git
(cd simple_ra ; git checkout extras)

Step #3: do the "extra" stuff needed

make

Step #4: enjoy simple_ra with the Gnu Radio Live DVD

cd $HOME/bin
sudo ./simple_ra --devid rtl=0,buflen=65536 --spde

