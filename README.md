# RecipeRadar Infrastructure Setup

This repository documents the steps required to set up a fresh RecipeRadar environment.

## Install dependencies

```
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
echo 'deb https://artifacts.elastic.co/packages/oss-7.x/apt stable main' | tee /etc/apt/sources.list.d/elastic-7.x.list
apt install elasticsearch-oss

apt install postgresql

apt install rabbitmq-server

# obtain the latest squid5 source from http://www.squid-cache.org/Versions/v5/
# build based on the configuration from build-scripts/squid5-configure.sh
# make install

apt install mongodb-server

apt install haproxy

wget -qO - https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/Debian_10/Release.key | sudo apt-key add -
echo 'deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/Debian_10/ /' | tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
apt install cri-o-1.17

wget -qO - https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo 'deb http://apt.kubernetes.io/ kubernetes-xenial main' | tee /etc/apt/sources.list.d/kubernetes.list
apt install kubeadm
```

## Configure cgroup management for crio
```
vim /etc/crio/crio.conf
...
cgroup_manager = "cgroupfs"
```

# Enable ipv4 packet forwarding
```
vim /etc/sysctl.d/99-sysctl.conf
...
net.ipv4.ip_forward=1
...
sysctl --system
```

# Install required kernel modules
```
echo br_netfilter >> /etc/modules
echo dummy >> /etc/modules
```

# Create a persistent dummy network interface
```
vim /etc/systemd/network/10-dummy0.netdev
...
[NetDev]
Name=dummy0
Kind=dummy
...
vim /etc/systemd/network/20-dummy0.network
...
[Match]
Name=dummy0

[Network]
Address=192.168.100.1
...
systemctl restart systemd-networkd
```

## Configure service listen ports
```
vim /etc/elasticsearch/elasticsearch.yml
...
network.host: 192.168.100.1
...
discovery.seed_hosts: ["192.168.100.1"]
...
```

```
vim /etc/postgresql/*/main/postgresql.conf
...
listen_addresses = '192.168.100.1'
...
vim /etc/postgresql/*/main/pg_hba.conf
...
# TYPE  DATABASE        USER            ADDRESS                 METHOD
host    all             all             192.168.0.0/16          trust
...
```

```
vim /etc/rabbitmq/rabbitmq.conf
...
loopback_users = none
...
vim /etc/rabbitmq/rabbitmq-env.conf
...
NODE_IP_ADDRESS=192.168.100.1
...
```

```
vim /etc/squid/squid.conf
...
http_port 192.168.100.1:3128
...
cp etc/squid/conf.d/recipe-radar.conf /etc/squid/conf.d/recipe-radar.conf
/usr/lib/squid/security_file_certgen -c -s /var/spool/squid/ssl_db -M 512MB
sh -x etc/squid/create-certificates.sh
```

## Configure the local mongodb instance
```
cp etc/mongodb/mongodb.conf /etc/mongodb.conf
```

## Set up a local haproxy instance to route browser requests
```
cp etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg
```

## Start system services
```
for service in systemd-networkd elasticsearch postgresql rabbitmq-server squid mongodb haproxy crio kubelet;
do
    systemctl enable ${service}.service
    systemctl restart ${service}.service
done
```

## Initialize the application database
```
sudo -u postgres createuser api
sudo -u postgres createdb api
```

## Initialize a kubernetes cluster
```
kubeadm init --apiserver-advertise-address=192.168.100.1 --pod-network-cidr=192.168.100.0/24
```

```
IMPORTANT: DROP YOUR PRIVILEGES AT THIS POINT

Everything from this point onwards can be performed as an unprivileged user
```

## Configure kubectl user access
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

## Configure kubernetes infrastructure
```
for component in k8s/*;
do
	kubectl apply -f ${component}
done;
```

# Allow scheduling of application workloads on master
```
kubectl taint nodes `hostname` node-role.kubernetes.io/master:NoSchedule-
```

## Make the proxy certificate available to the cluster
```
kubectl create secret generic proxy-cert --from-file=/etc/squid/certificates/ca.crt
```

## Smoke tests
```
# Make a request to a deployed service
curl -H 'Host: frontend' localhost:30080

# Make a request via the Kubernetes ingress controller
curl localhost
```
