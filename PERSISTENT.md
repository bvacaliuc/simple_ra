# simple_ra/extras/PERSISTENT.md
Using a 2nd USB DISK for PERSISTENT storage and for off-line use

Step #1: get a Gnu Radio Live DVD/USB up and running
see: https://gnuradio.org/redmine/projects/gnuradio/wiki/GNURadioLiveDVD

Step #2: clone and switch to extras branch

git clone https://github.com/bvacaliuc/simple_ra.git
(cd simple_ra ; git checkout extras)

Step #3: insert the USB disk that you would like to use

Step #4: prepare the USB disk for persistent data

make persistent

You will be guided to select the disk to use.  It will give you confirmation before starting the work.  If you make any mistakes you can keep trying the command until you get it right.

Step #5: download/compile the needed dependencies to the persistent USB disk prepared in #4 above.  You will need a network connection for this part.

make

Step #6: reboot your system (unless you wish to enjoy the Live DVD first)

Upon a reboot, the Gnu Radio Live DVD system will have identified your USB disk and it will show up on the left side icon bar as a USB disk.  You can click on it and otherwise use it to save data files.

Step #7: navigate to the src/simple_ra/ on the persistent USB disk and issue the command to re-install the dependencies prepared in #5 above.  You do NOT need a network connection for this part.  You WILL have to do this step each time you reboot your Gnu Radio Live DVD.

make reinstall

Step #8: enjoy simple_ra with the Gnu Radio Live DVD

cd $HOME/bin
sudo ./simple_ra --devid rtl=0,buflen=65536 --spde

NOTE: For even more options, call simple_ra with the --help option and read the notes on the various command line parameters that are available.

