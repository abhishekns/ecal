#define NW_DEVICE if you want to run server or client
hn=`hostname`
if [ "x${hn}" == "ethlab-8881" ]; then
   NW_DEVICE=eno0
fi

if [ "x${hn}" == "simfarm15" ]; then
  NW_DEVICE=enp6s0
fi


if [ -z ${NW_DEVICE+x} ]; then 
   echo "Define NW_DEVICE=<your nw device>   ex. NW_DEVICE=eno0 make server|client"
else
   sudo ip route add 239.0.0.0/24 via 0.0.0.0 dev ${NW_DEVICE} metric 1
   sudo ip route add 239.0.0.0/24 via 0.0.0.0 dev lo metric 1000
fi
