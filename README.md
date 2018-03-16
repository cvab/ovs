# OVS Configuration setup
Build Instructions:
http://docs.openvswitch.org/en/latest/intro/install/dpdk/
########################
# Install DPDK         #
########################
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

########################
# OVS Setup            #
########################
killall ovsdb-server
killall ovs-vswitchd
#ovs-vsctl del-port br0 dpdk0
#ovs-vsctl del-br br0
rm -rf  /usr/local/etc/openvswitch
#cscope -b -q -k -R

########################
# OVS DB Server        #
########################
export PATH=$PATH:/usr/local/share/openvswitch/scripts
mkdir -p  /usr/local/etc/openvswitch
ovsdb-tool create /usr/local/etc/openvswitch/conf.db \
    openvswitch-2.7.0/vswitchd/vswitch.ovsschema
export DB_SOCK=/usr/local/var/run/openvswitch/db.sock
ovs-ctl --no-ovs-vswitchd start

########################
# OVS vSwitchD         #
########################
ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-init=true
ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-socket-mem="1024,0"
ovs-vsctl --no-wait set Open_vSwitch . other_config:pmd-cpu-mask=0x1e
ovs-vsctl --no-wait set Open_vSwitch .  other_config:n-dpdk-rxqs=1
ovs-vsctl --no-wait set Open_vSwitch .  other_config:n-dpdk-txqs=1
ovs-ctl --no-ovsdb-server --db-sock="$DB_SOCK" start

##########################
# OVS Port Configuration #
##########################
ovs-vsctl add-br br0 -- set bridge br0 datapath_type=netdev
ovs-vsctl add-port br0 dpdk0 -- set Interface dpdk0 type=dpdk options:dpdk-devargs=0000:03:00.0
ovs-vsctl add-port br0 dpdk1 -- set Interface dpdk1 type=dpdk options:dpdk-devargs=0000:03:00.1
ovs-vsctl add-port br0 vhost-client-1 -- set Interface vhost-client-1 type=dpdkvhostuser
ovs-vsctl add-port br0 vhost-client-2 -- set Interface vhost-client-2 type=dpdkvhostuser
ovs-vsctl set Interface dpdk0 other_config:pmd-rxq-affinity="0:128"
ovs-vsctl set Interface dpdk1 other_config:pmd-rxq-affinity="0:64"
ovs-vsctl set Interface vhost-client-1 other_config:pmd-rxq-affinity="0:32"
ovs-vsctl set Interface vhost-client-2 other_config:pmd-rxq-affinity="0:16"
#ovs-vsctl add-br br0 -- set bridge br0 datapath_type=netdev
#ovs-vsctl add-port br0 dpdk0 -- set Interface dpdk0 type=dpdk [ofport_request=<x>] options:dpdk-devargs=0000:01:00.0
#ovs-vsctl add-port br0 dpdk1 -- set Interface dpdk1 type=dpdk [ofport_request=<x>] options:dpdk-devargs=0000:01:00.1
#ovs-vsctl add-port br0 vhost-client-1 -- set Interface vhost-client-1 type=dpdkvhostuser [ofport_request=<x>]
#ovs-vsctl add-port br0 vhost-client-2 -- set Interface vhost-client-2 type=dpdkvhostuser [ofport_request=<x>] [other_config:pmd-rxq-affinity="0:3,1:7,3:8"]
#ovs-vsctl add-port br0 dpdk0 -- set Interface dpdk-p0 type=dpdk options:dpdk-devargs=0000:03:00.0 options:rx-checksum-offload=true/false
#ovs-vsctl set Interface dpdk0 options:rx-checksum-offload=false
#ovs-vsctl add-port br0 dpdk0 -- set Interface dpdk0 type=dpdk options:dpdk-devargs=0000:03:00.0 mtu_request=9000
#Similarly, to change the MTU of an existing port to 6200::
#ovs-vsctl set Interface dpdk<x> mtu_request=<y>
#ovs-vsctl set interface dpdk<x> mtu_request=2048
#ovs-vsctl set Interface <DPDK interface> options:n_rxq=<integer> /* Port nRxQs */
#ovs-vsctl set Interface <DPDK interface> options:n_txq=<integer> /* Port nTxQs */
#ovs-vsctl set Interface <DPDK interface> options:n_rxq_desc=<integer>   /* Port RxQ size */
#ovs-vsctl set Interface <DPDK interface> options:n_txq_desc=<integer>   /* Port TxQ size */
#ovs-vsctl set Interface <DPDK interface> other_config:pmd-rxq-affinity="0:3,1:7,3:8" /* Port/Queue to CPU affinity */
############################
# OVS Switch configuration #
############################
ovs-ofctl add-flow br0 in_port=1,action=output:3
ovs-ofctl add-flow br0 in_port=3,action=output:1
ovs-ofctl add-flow br0 in_port=2,action=output:4
ovs-ofctl add-flow br0 in_port=4,action=output:2
#ovs-ofctl add-flow br0 in_port=1,dl_type=0x0800,dl_vlan=200,dl_vlan_pcp=7,dl_src=00:00:01:00:05:00,dl_dst=00:00:01:00:04:00,nw_src=100.100.100.2,nw_dst=100.100.100.1,nw_proto=17,tp_src=101,tp_dst=2152,action=output:3
#ovs-appctl dpctl/show
#ovs-appctl dpctl/show -s
#ovs-vsctl list-ports br0
#ovs-ofctl dump-tables br0
#ovs-ofctl dump-flows br0
#ovs-ofctl mod-port br0 dpdk<x>/vhost-client-<x> flood/no-flood
#ovs-ofctl add-flow br0 table=0 in_port=<x>,action=output:<y>  /* Hint:ovs-appctl dpctl/show for port no */
##########################
# OVS Port stats     #
##########################
#ovs-vsctl get interface dpdk<x> statistics     /* Interface stats */
#ovs-vsctl get interface br<x> statistics   /* Bridge stats */
#ovs-vsctl clear interface dpdk<x> statistics   /* Clear Bridge stats */
##########################
# OVS Packet Tracing     #
##########################
#ovs-appctl ofproto/trace br0 in_port=<x>,<other matching criteria>
