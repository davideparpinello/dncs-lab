export DEBIAN_FRONTEND=noninteractive
# Startup commands go here

sudo ip addr add 10.0.0.2/30 dev enp0s9
sudo ip link set dev enp0s9 up

sudo ip addr add 192.168.5.1/26 dev enp0s8
sudo ip link set dev enp0s8 up

sudo sysctl -w net.ipv4.ip_forward=1

sudo ip route add 192.168.0.0/21 via 10.0.0.1