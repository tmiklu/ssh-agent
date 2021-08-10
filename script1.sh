#!/bin/bash

DIR="/home/administrator/scripts/keys"

ssh_agent() {
    eval `ssh-agent`
    pass=$(cat ${DIR}/.pass)

    expect << EOF
    spawn ssh-add ${DIR}/tko
    expect "Enter passphrase"
    send "$pass\r"
    expect eof
EOF

}

while : 
do
  nc -w 5 -vz x.x.x.x 22
  
  if [ $? == 0 ]; then
    #
    ## run ssh-agent
    #
    ssh_agent

    SSH_FORWARD=$(ps aux | egrep "\-R\s22:localhost:22" | awk '{print $2}')

    if [ -v ${SSH_FORWARD} ]; then
        echo "ssh forward is not running on ubuntu server"
        ssh -i /home/administrator/scripts/keys/tko -f -N -p 22 tomas@x.x.x.x -R 22:localhost:22

    else
        echo "ssh forward 22 is running"
    fi
    
    SSH_FORWARD_HTTP=$(ps aux | egrep "\-R\s80:localhost:80" | awk '{print $2}')
    
    if [ -v ${SSH_FORWARD_HTTP} ]; then
        echo "http ssh forward is not running on ubuntu server"
        ssh -i /home/administrator/scripts/keys/tko -f -N -p 22 tomas@x.x.x.x -R 80:localhost:80
    else
	   echo "ssh forward 80 is running"
    fi

    SSH_FORWARD_SSHFS=$(ps aux | egrep "sshfs" | grep -v grep | awk '{print $2}')
    
    if [ -v ${SSH_FORWARD_SSHFS} ]; then
        echo "sshfs forward is not running on ubuntu server"
        sshfs -o IdentityFile=/home/administrator/scripts/keys/tko -p 22 tomas@x.x.x.x:\\tmp /mnt/tko
    else
	   echo "sshfs is running"
    fi
      
  else
    echo "network is down"
    PID=$(ps aux | egrep "tomas\@X\.X\.X\.X\s\-R\s22\:localhost\:22" | awk '{ print $2 }')
    
    if [ ! -v $PID ]; then
        echo "Killing http ssh forward ${PID}"
        kill -9 ${PID}

    else
        echo "Tomas's computer lost connection, see client side" 
    fi

    #
    ## kill active ssh-agent
    #
    SSH_AGENT=$(ps aux | grep -i ssh-agent | grep -v grep | awk '{ print $2 }' | wc -l)

    if [ ${SSH_AGENT} -gt 0 ]; then
       while read line
       do
           echo "Killing ssh-agent ${line}"
           kill -9 ${line}
       done < <(ps aux | grep -i ssh-agent | grep -v grep | awk '{ print $2 }')
    fi
  fi
  sleep 3
done
