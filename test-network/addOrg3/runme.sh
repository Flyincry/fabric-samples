#! /bin/bash

# read me
# you can use this runme.sh to generate new organizations
# for example: if you want to create org7, you can just run "sh runme.sh 7"
# $1, which is the # of org, is the necessary parameter we need

sh updateFiles.sh $1
chmod +x ccp-generate$1.sh
./addOrg3.sh up -ca -o $1
