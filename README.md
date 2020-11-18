# DNCS-LAB

This repository contains the Vagrant files required to run the virtual lab environment used in the DNCS course.
```


        +-----------------------------------------------------+
        |                                                     |
        |                                                     |eth0
        +--+--+                +------------+             +------------+
        |     |                |            |             |            |
        |     |            eth0|            |eth2     eth2|            |
        |     +----------------+  router-1  +-------------+  router-2  |
        |     |                |            |             |            |
        |     |                |            |             |            |
        |  M  |                +------------+             +------------+
        |  A  |                      |eth1                       |eth1
        |  N  |                      |                           |
        |  A  |                      |                           |
        |  G  |                      |                     +-----+----+
        |  E  |                      |eth1                 |          |
        |  M  |            +-------------------+           |          |
        |  E  |        eth0|                   |           |  host-c  |
        |  N  +------------+      SWITCH       |           |          |
        |  T  |            |                   |           |          |
        |     |            +-------------------+           +----------+
        |  V  |               |eth2         |eth3                |eth0
        |  A  |               |             |                    |
        |  G  |               |             |                    |
        |  R  |               |eth1         |eth1                |
        |  A  |        +----------+     +----------+             |
        |  N  |        |          |     |          |             |
        |  T  |    eth0|          |     |          |             |
        |     +--------+  host-a  |     |  host-b  |             |
        |     |        |          |     |          |             |
        |     |        |          |     |          |             |
        ++-+--+        +----------+     +----------+             |
        | |                              |eth0                   |
        | |                              |                       |
        | +------------------------------+                       |
        |                                                        |
        |                                                        |
        +--------------------------------------------------------+



```

# Requirements
 - Python 3
 - 10GB disk storage
 - 2GB free RAM
 - Virtualbox
 - Vagrant (https://www.vagrantup.com)
 - Internet

# How-to
 - Install Virtualbox and Vagrant
 - Clone this repository
`git clone https://github.com/fabrizio-granelli/dncs-lab`
 - You should be able to launch the lab from within the cloned repo folder.
```
cd dncs-lab
[~/dncs-lab] vagrant up
```
Once you launch the vagrant script, it may take a while for the entire topology to become available.
 - Verify the status of the 4 VMs
 ```
 [dncs-lab]$ vagrant status                                                                                                                                                                
Current machine states:

router                    running (virtualbox)
switch                    running (virtualbox)
host-a                    running (virtualbox)
host-b                    running (virtualbox)
 ```
- Once all the VMs are running verify you can log into all of them:
`vagrant ssh router`
`vagrant ssh switch`
`vagrant ssh host-a`
`vagrant ssh host-b`
`vagrant ssh host-c`

# Assignment
This section describes the assignment, its requirements and the tasks the student has to complete.
The assignment consists in a simple piece of design work that students have to carry out to satisfy the requirements described below.
The assignment deliverable consists of a Github repository containing:
- the code necessary for the infrastructure to be replicated and instantiated
- an updated README.md file where design decisions and experimental results are illustrated
- an updated answers.yml file containing the details of your project

## Design Requirements
- Hosts 1-a and 1-b are in two subnets (*Hosts-A* and *Hosts-B*) that must be able to scale up to respectively 373 and 302 usable addresses
- Host 2-c is in a subnet (*Hub*) that needs to accommodate up to 50 usable addresses
- Host 2-c must run a docker image (dustnic82/nginx-test) which implements a web-server that must be reachable from Host-1-a and Host-1-b
- No dynamic routing can be used
- Routes must be as generic as possible
- The lab setup must be portable and executed just by launching the `vagrant up` command

## Tasks
- Fork the Github repository: https://github.com/fabrizio-granelli/dncs-lab
- Clone the repository
- Run the initiator script (dncs-init). The script generates a custom `answers.yml` file and updates the Readme.md file with specific details automatically generated by the script itself.
  This can be done just once in case the work is being carried out by a group of (<=2) engineers, using the name of the 'squad lead'. 
- Implement the design by integrating the necessary commands into the VM startup scripts (create more if necessary)
- Modify the Vagrantfile (if necessary)
- Document the design by expanding this readme file
- Fill the `answers.yml` file where required (make sure that is committed and pushed to your repository)
- Commit the changes and push to your own repository
- Notify the examiner (fabrizio.granelli@unitn.it) that work is complete specifying the Github repository, First Name, Last Name and Matriculation number. This needs to happen at least 7 days prior an exam registration date.

# Notes and References
- https://rogerdudler.github.io/git-guide/
- http://therandomsecurityguy.com/openvswitch-cheat-sheet/
- https://www.cyberciti.biz/faq/howto-linux-configuring-default-route-with-ipcommand/
- https://www.vagrantup.com/intro/getting-started/

# Team 👥

This project was done by Baccichet Giovanni (`202869`) and Parpinello Davide (`201494` - team leader).

# Design 💡
We started by executing the dcns-init script, that returned us the different values that need to be the number of scalable hosts in the subnets:

- Subnet (host-a): 373 hosts;
- Subnet  (host-b): 302 hosts;
- Subnet (host-c): 50 hosts.

### Subnets 📡

Considering the design requirements, we decided to create 4 subnets. Doing some math, we calculated the most efficient way to organise the IP addresses:

1. **Subnet 1** is between router-1 and router-2. We used private class-a addresses with the subnet `10.0.0.0/30` to cover only the 2 routers (2<sup>32-30</sup>-2=2);
2. **Subnet 2** is between router-1 and host-a, and according to the design requirements it has a max number of host of 373. We used private class-c addresses for this subnet `192.168.1.0/23` (2<sup>32-23</sup>-2 = 510>373);
3. **Subnet 3** is between router-1 and host-b. We used private class-c addresses with the subnet `192.168.3.0/23` to cover the 302 hosts (2<sup>32-23</sup>-2=510>302);
4. **Subnet 4** is between router-2 and host-c. We used private class-c addresses with the subnet `192.168.5.0/26` to cover the 50 hosts (2<sup>32-26</sup>-2=62>50).

### VLANs and IP configurations 💾

<img src="network-config.jpg" width="650">

| Device   | Interface predictable name | Interface | IP          | Subnet |
| -------- | -------------------------- | --------- | ----------- | ------ |
| Router-1 | enp0s9                     | eth2      | 10.0.0.1    | 1      |
| Router-2 | enp0s9                     | eth2      | 10.0.0.2    | 1      |
| Router-1 | enp0s8                     | eth1      | 192.168.1.1 | 2      |
| Host-A   | enp0s8                     | eth1      | 192.168.1.2 | 2      |
| Router-1 | enp0s8                     | eth1      | 192.168.3.1 | 3      |
| Host-B   | enp0s8                     | eth1      | 192.168.3.2 | 3      |
| Router-2 | enp0s8                     | eth1      | 192.168.5.1 | 4      |
| Host-C   | enp0s8                     | eth1      | 192.168.5.2 | 4      |

We then proceeded to create 2 VLANs, respectively for the subnets 2 and 3 with Tag `10` and `30`.

# Vagrant configuration 🖥

We included all the commands needed for the configuration of the network in a bash script for each of the devices. Those scripts will configure the network during the creation of the VMs, after the command `vagrant up`. These scripts are included in the `Vagrantfile` using the `provision` command. We also needed to increase the memory of `host-c` from 256 to 512 (MB), otherwise it would have been impossible to pull and run the Docker image; in order to do that we modified the option `vb.memory`.

## Commands used 🔧

Since the newer Debian-based distros use predictable names for network interfaces, we had to check what interfaces corresponded to `eth1`, `eth2` and `eth3`, to match the specifications given.
We used the command `dmesg | grep -i eth` and put the results in the table above. Every other command from now has to be executed by the superuser (adding `sudo` before the command).
- [**IP**] We then proceeded assigning an IP address to each interface, with the command `ip addr add [IP_ADDR] dev [INTERFACE]`, then activating said interface with `ip link set dev [INTERFACE] up`;
- [**FORWARDING**] Then we enabled the IPv4 forwarding in the routers with `sysctl -w net.ipv4.ip_forward=1`; 
- [**VLAN**] For creating the VLANs mentioned earlier, we used `ip link add link enp0s8 name enp0s8.10 type vlan id 10` and `ip link add link enp0s8 name enp0s8.30 type vlan id 30` and added IP addresses to the virtual interfaces with `addr add 192.168.1.1/23 dev enp0s8.10` and `ip addr add 192.168.3.1/23 dev enp0s8.30`;
- [**ROUTE**] To create a route we used the `ip route add 192.168.5.0/26 via 10.0.0.2` command. The first parameter `192.168.5.0/26` corresponds to the network we want to reach, and after `via` there is the IP address of the next hop, that is the interface of the router placed in the subnet where the current host is. Every host that has to reach another subnet has specific routes that achieve this, but, in particular, some hosts have generic routes with destinations like `192.168.0.0/23`, with the purpose of designing the routes as generic as possible, covering the range `192.168.0.0 - 192.168.5.255`, that includes all of our host subnets.

## Switch configuration 🔀

We then had to setup the switch, assigning the VLAN tags to the ports. We created a bridge named “switch” with `ovs-vsctl add-br switch`.
Then we configured the ports:
```
ovs-vsctl add-port switch enp0s8
ovs-vsctl add-port switch enp0s9 tag="10"
ovs-vsctl add-port switch enp0s10 tag="30"
```
## Host C configuration 🕸

Since one design requirement was for the Host C to run a docker image, we proceeded with its configuration:
```
apt-get update
apt-get -y install docker.io
systemctl start docker
systemctl enable docker
docker pull dustnic82/nginx-test
docker run --name nginx -p 80:80 -d dustnic82/nginx-test
```
To check if the Host C was reachable from the Host A and the Host B we executed from every one of them `curl 192.168.5.2`, resulting in the following output:
```
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```
The output was correct.