#! /bin/bash

sed -i ''$((26+($1-3)*3))' i \ \ elif [ $ORG -eq '$1' ]; then' ${PWD}/../scripts/setAnchorPeer.sh
sed -i ''$((26+($1-3)*3+1))' i \ \ \ \ HOST="peer0.org'$1'.example.com"' ${PWD}/../scripts/setAnchorPeer.sh
sed -i ''$((26+($1-3)*3+2))' i \ \ \ \ PORT='$((7051+2000*$(($1-1))))'' ${PWD}/../scripts/setAnchorPeer.sh