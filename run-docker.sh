WD=$1
DL=$2
SS=$3

sudo docker run --add-host dockerhost:172.17.0.1 --rm -it \
-v $WD:/workdir \
-v $DL:/opt/yocto/downloads \
-v $SS:/opt/yocto/sstate-cache \
mypokycrops:ubuntu-16.04 \
--workdir=/workdir
