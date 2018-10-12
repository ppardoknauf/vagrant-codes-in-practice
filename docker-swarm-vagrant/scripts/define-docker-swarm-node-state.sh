#!/usr/bin/env bash

hostname=`hostname -s`
declare -a nodelist=('node1' 'node2' 'node3' 'node4')

for node in "$nodelist"
do
    if [ "$hostname" = "node3" -o "$hostname" = "node4" ]
    then
        echo This Swarm node configured as Worker!!!
	/vagrant/scripts/cometoworker.sh
    else
        echo This Swarm node configured as Manager!!!
        /vagrant/scripts/cometomanager.sh
    fi
done
