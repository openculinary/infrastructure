# RecipeRadar Infrastructure Setup

## Install dependencies

```
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
echo 'deb https://artifacts.elastic.co/packages/oss-7.x/apt stable main' | tee /etc/apt/sources.list.d/elastic-7.x.list
apt install elasticsearch-oss

apt install postgresql
sudo -u postgres createuser api
sudo -u postgres createdb api

apt install rabbitmq-server

wget -qO - http://packages.diladele.com/diladele_pub.asc | apt-key add -
echo 'deb [arch=amd64] http://squid48.diladele.com/ubuntu/ bionic main' | tee /etc/apt/sources.list.d/squid48.diladele.com.list
apt install squid
/usr/lib/squid/security_file_certgen -c -s /var/spool/squid/ssl_db -M 512MB
cp etc/squid/recipe-radar.conf /etc/squid/conf.d/recipe-radar.conf

add-apt-repository ppa:projectatomic/ppa
apt install cri-o-1.15

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

## Initialize a kubernetes cluster
```
kubeadm init --apiserver-advertise-address=192.168.100.1 --pod-network-cidr=192.168.100.0/24
```

## Start system services
```
for service in systemd-networkd elasticsearch postgresql rabbitmq-server squid crio kubelet;
do
    systemctl enable ${service}.service
    systemctl restart ${service}.service
done
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

## Configure pod networking and ingress
```
kubectl apply -f k8s/networking/calico.yaml
kubectl apply -f k8s/ingress/nginx-ingress-controller.yaml
kubectl apply -f k8s/ingress/nginx-ingress-service.yaml
```

# Allow scheduling of application workloads on master
```
kubectl taint nodes `hostname` node-role.kubernetes.io/master:NoSchedule-
```

## Add read-only credentials to enable pulling new images
```
kubectl create secret docker-registry gitlab-registry \
    --docker-server registry.gitlab.com \
    --docker-username <username> \
    --docker-password <password>
```

## Deploy the application
```
kubectl create -f frontend-deployment.yml
kubectl create -f frontend-service.yml
kubectl create -f frontend-ingress.yml
kubectl set image deployment/frontend-deployment frontend=registry.gitlab.com/openculinary/frontend:$(git rev-parse --short HEAD)
```

## Make a smoke test request to the application
```
PORT=$(kubectl -n ingress-nginx get svc --no-headers -o custom-columns=port:spec.ports[*].nodePort)
curl -4 -H 'Host: frontend' localhost:${PORT}
```
