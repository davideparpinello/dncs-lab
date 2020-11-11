export DEBIAN_FRONTEND=noninteractive
# Startup commands go here

sudo ip addr add 10.0.0.1/30 dev enp0s9
sudo ip link set dev enp0s9 up

sudo ip link add link enp0s8 name enp0s8.10 type vlan id 10 
sudo ip link add link enp0s8 name enp0s8.30 type vlan id 30 

sudo ip addr add 192.168.1.1/23 dev enp0s8.10
sudo ip addr add 192.168.3.1/23 dev enp0s8.30

sudo ip link set dev enp0s8 up

sudo sysctl -w net.ipv4.ip_forward=1

sudo ip route add 192.168.5.0/26 via 10.0.0.2