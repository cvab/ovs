
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
################################
# OVS open-flow working config #
################################
root@ADK-BLR-PET620:/workspace/sw/sitummal/adk-tiger/1.0.4.023# ovs-ofctl dump-flows br0
NXST_FLOW reply (xid=0x4):
 cookie=0x0, duration=92.921s, table=0, n_packets=3, n_bytes=270, idle_age=32, in_port=1 actions=output:3
 cookie=0x0, duration=86.814s, table=0, n_packets=3, n_bytes=1638, idle_age=14, in_port=2 actions=output:4
 cookie=0x0, duration=52.729s, table=0, n_packets=2, n_bytes=1092, idle_age=14, in_port=3 actions=output:1
 cookie=0x0, duration=47.885s, table=0, n_packets=2, n_bytes=180, idle_age=32, in_port=4 actions=output:2
 cookie=0x0, duration=22761.252s, table=0, n_packets=2461577, n_bytes=221860840, idle_age=218, priority=0 actions=NORMAL
root@ADK-BLR-PET620:/workspace/sw/sitummal/adk-tiger/1.0.4.023# ovs-appctl dpctl/show
netdev@ovs-netdev:
        lookups: hit:3342330 missed:460 lost:0
        flows: 0
        port 0: ovs-netdev (tap)
        port 1: br0 (tap)
        port 2: dpdk0 (dpdk: configured_rx_queues=1, configured_rxq_descriptors=2048, configured_tx_queues=2, configured_txq_descriptors=2048, mtu=1500, requested_rx_queues=1, requested_rxq_descriptors=2048, requested_tx_queues=2, requested_txq_descriptors=2048, rx_csum_offload=true)
        port 3: dpdk1 (dpdk: configured_rx_queues=1, configured_rxq_descriptors=2048, configured_tx_queues=2, configured_txq_descriptors=2048, mtu=1500, requested_rx_queues=1, requested_rxq_descriptors=2048, requested_tx_queues=2, requested_txq_descriptors=2048, rx_csum_offload=true)
        port 4: vhost-client-1 (dpdkvhostuser: configured_rx_queues=1, configured_tx_queues=1, mtu=1500, requested_rx_queues=1, requested_tx_queues=1)
        port 5: vhost-client-2 (dpdkvhostuser: configured_rx_queues=1, configured_tx_queues=1, mtu=1500, requested_rx_queues=1, requested_tx_queues=1)



