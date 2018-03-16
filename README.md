# OVS Configuration setup
Build Instructions:
http://docs.openvswitch.org/en/latest/intro/install/dpdk/
########################
# Install DPDK         #
########################0
$ cd /usr/src/
$ wget http://fast.dpdk.org/rel/dpdk-17.11.tar.xz
$ tar xf dpdk-17.11.tar.xz
$ export DPDK_DIR=/usr/src/dpdk-17.11
$ cd $DPDK_DIR
$ export DPDK_TARGET=x86_64-native-linuxapp-gcc
$ export DPDK_BUILD=$DPDK_DIR/$DPDK_TARGET
$ make install T=$DPDK_TARGET DESTDIR=install
$ export LD_LIBRARY_PATH=$DPDK_DIR/x86_64-native-linuxapp-gcc/lib
########################
# Install OVS          #
########################
$ ./configure --with-dpdk=$DPDK_BUILD
$ make
$ make install    #by default under /usr/local
