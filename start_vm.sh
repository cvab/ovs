qemu-system-x86_64 -cpu host -enable-kvm -m 8192 -smp 10,sockets=1,cores=10,threads=1     \
    -chardev socket,id=char1,path=/usr/local/var/run/openvswitch/vhost-client-1 -netdev type=vhost-user,id=mynet1,chardev=char1,vhostforce -device virtio-net-pci,mac=00:00:00:00:01:01,netdev=mynet1,mrg_rxbuf=on \
    -chardev socket,id=char2,path=/usr/local/var/run/openvswitch/vhost-client-2 -netdev type=vhost-user,id=mynet2,chardev=char2,vhostforce -device virtio-net-pci,mac=00:00:00:00:02:01,netdev=mynet2,mrg_rxbuf=on \
    -net user,hostfwd=tcp::10021-:22 -net nic -object memory-backend-file,id=mem,size=8192M,mem-path=/dev/hugepages,share=on -numa node,memdev=mem -mem-prealloc /var/lib/libvirt/images/vpp1.qcow2 --nographic &


#username:vpp password:vpp
#ssh vpp@localhost -p 10021  password:vpp
#scp -P 10021 <file> vpp@localhost:<path>

