#! /bin/bash

sed -i ''$((14+$1))' i export PEER0_ORG'$1'_CA=${PWD}/organizations/peerOrganizations/org'$1'.example.com/peers/peer0.org'$1'.example.com/tls/ca.crt' ${PWD}/../scripts/envVar.sh
sed -i ''$((40+($1-3)*6))' i \ \ elif [ $USING_ORG -eq '$1' ]; then' ${PWD}/../scripts/envVar.sh
sed -i ''$((40+($1-3)*6+1))' i \ \ \ \ export CORE_PEER_LOCALMSPID="Org'$1'MSP"' ${PWD}/../scripts/envVar.sh
sed -i ''$((40+($1-3)*6+2))' i \ \ \ \ export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG'$1'_CA' ${PWD}/../scripts/envVar.sh
sed -i ''$((40+($1-3)*6+3))' i \ \ \ \ export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org'$1'.example.com/users/Admin@org'$1'.example.com/msp' ${PWD}/../scripts/envVar.sh
sed -i ''$((40+($1-3)*6+4))' i \ \ \ \ export CORE_PEER_ADDRESS=localhost:'$((7051+2000*$(($1-1))))'' ${PWD}/../scripts/envVar.sh
sed -i ''$((68+($1-3)*8))' i \ \ elif [ $USING_ORG -eq '$1' ]; then' ${PWD}/../scripts/envVar.sh
sed -i ''$((68+($1-3)*8+1))' i \ \ \ \ export CORE_PEER_ADDRESS=peer0.org'$1'.example.com:'$((7051+2000*$(($1-1))))'' ${PWD}/../scripts/envVar.sh