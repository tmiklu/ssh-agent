#!/bin/bash

DIR="/home/user/scripts/keys"

#eval `ssh-agent -s`
eval `ssh-agent`
# path to password with file
pass=$(cat ${DIR}/.pass)

# path to private rsa key
expect << EOF
  spawn ssh-add ${DIR}/tko
  expect "Enter passphrase"
  send "$pass\r"
  expect eof
EOF

#
## run ssh tunnel
#
ssh -f -N -p 22 tomas@<ip-address> -R 80:localhost:80
