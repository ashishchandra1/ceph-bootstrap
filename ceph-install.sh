# A very minimal ceph install script, using ceph-deploy
set -x

sudo apt-get install -y ceph-deploy

ceph-remove () {
ceph-deploy purge $HOST
ceph-deploy purgedata $HOST
ceph-deploy forgetkeys
}


HOST=$(hostname)
ceph-remove
ceph-deploy new $HOST

cat <<EOF >> ceph.conf
osd pool default size=2
osd crush chooseleaf type = 0
EOF

ceph-deploy install $HOST --release firefly
ceph-deploy mon create-initial $HOST

sudo mkdir /var/local/osd0
sudo mkdir /var/local/osd1
sudo mkdir /var/local/osd2

ceph-deploy osd prepare $HOST:/var/local/osd0 $HOST:/var/local/osd1 $HOST:/var/local/osd2
ceph-deploy osd activate  $host:/var/local/osd0 $host:/var/local/osd1 $HOST:/var/local/osd2
sleep 30 # Give some time for ceph to work its magic
sudo ceph health

