#!/bin/bash
masterid=$(docker run -d -it -P --privileged=true -v /data:/data tiennt/ompi)
masterip=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${masterid}`
NUMBER_SLAVE=$1

for (( c=0; c<$NUMBER_SLAVE; c++ ))
do
  slaveid[${c}]=$(docker run -d -it --privileged=true -v /data:/data tiennt/ompi)
  slaveip[${c}]=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${slaveid[${c}]}`
done

SLAVE_NUM=${#slaveid[@]}

docker exec ${masterid} ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa

for (( c=0; c<$SLAVE_NUM; c++ ))
do
  docker exec ${slaveid[${c}]} ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa
done

for (( c=0; c<$SLAVE_NUM; c++ ))
do
  docker exec ${masterid} /root/ssh/ssh-copy-id.sh ${slaveip[${c}]}
done

echo "Master id : ${masterid}"
echo "Master ipadd: ${masterip}"
echo "NUmber container: ${NUMBER_CONTAINER}"

echo "Slave id: ${slaveid[0]}"
echo "Slave id: ${slaveid[1]}"
echo "Slave ipadd: ${slaveip[0]}"
echo "Slave ipadd: ${slaveip[1]}"

echo "Slave len: ${#slaveid[@]}"

#docker stop $(docker ps -a -q)
#docker rm $(docker ps -a -q)