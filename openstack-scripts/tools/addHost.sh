#!/bin/bash

echo "${CONTROLLER_IP} controller" >> tmp

COUNT="1"

while [ -v "COMPUTE_${COUNT}" ];
do
	TMP="COMPUTE_${COUNT}"
	echo "${!TMP} compute${COUNT}" >> tmp
	COUNT=$[${COUNT}+1]
done
