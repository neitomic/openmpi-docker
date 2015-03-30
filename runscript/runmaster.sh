#!/bin/bash

echo "Initializing Master container...."
masterid=$(sudo docker run -d -it -P --privileged=true -v /data:/data tiennt/ompi)
masterip=`sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${masterid}`
NUMBER_SLAVE=$1
echo "done."

echo "Initializing slave containers...."
for (( c=0; c<$NUMBER_SLAVE; c++ ))
do
  slaveid[${c}]=$(sudo docker run -d -it -P --privileged=true -v /data:/data tiennt/ompi)
  slaveip[${c}]=`sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${slaveid[${c}]}`
done
SLAVE_NUM=${#slaveid[@]}
echo "done. ${SLAVE_NUM} slaves initialed!"

echo "Generate RSA key..."
sudo docker exec ${masterid} ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa >> /dev/null

for (( c=0; c<$SLAVE_NUM; c++ ))
do
  sudo docker exec ${slaveid[${c}]} ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa >> /dev/null
done
echo "done."

echo "Add ssh key of master to slaves.."
for (( c=0; c<$SLAVE_NUM; c++ ))
do
  sudo docker exec ${masterid} /root/ssh/ssh-copy-id.sh ${slaveip[${c}]} >> /dev/null
done

echo "done."
#docker exec ${masterid} touch /root/hostfile

echo "Create host file..."
echo "" > /data/hostfile
for (( c=0; c<$SLAVE_NUM; c++ ))
do
  echo ${slaveip[${c}]} >> /data/hostfile
done
echo "Done."

sudo docker exec -it ${masterid} /bin/bash

sudo docker stop $(sudo docker ps -a -q)
sudo docker rm $(sudo docker ps -a -q)
