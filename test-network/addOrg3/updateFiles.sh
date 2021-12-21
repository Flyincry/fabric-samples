#! /bin/bash

# Edit docker-compose-ca-org3.yaml


echo '# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

version: '"'2'"'

services:

  ca_org'$1':
    image: hyperledger/fabric-ca:$IMAGE_TAG
    environment:
      - FABRIC_CA_HOME=/etc/hyperledger/fabric-ca-server
      - FABRIC_CA_SERVER_CA_NAME=ca-org'$1'
      - FABRIC_CA_SERVER_TLS_ENABLED=true
      - FABRIC_CA_SERVER_PORT='$((7054+2000*$(($1-1))))'
    ports:
      - "'$((7054+2000*$(($1-1))))':'$((7054+2000*$(($1-1))))'"
    command: sh -c '"'fabric-ca-server start -b admin:adminpw -d'"'
    volumes:
      - ../fabric-ca/org'$1':/etc/hyperledger/fabric-ca-server
    container_name: ca_org'$1'' > "${PWD}/docker/docker-compose-ca-org$1.yaml"

# Edit docker-compose-couch-org.yaml

echo '# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

version: '"'2'"'

networks:
  test:

services:
  couchdb'$(($1+1))':
    container_name: couchdb'$(($1+1))'
    image: couchdb:3.1.1
    environment:
      - COUCHDB_USER=admin
      - COUCHDB_PASSWORD=adminpw
    ports:
      - "'$((5984+2000*$(($1-1))))':5984"
    networks:
      - test

  peer0.org'$1'.example.com:
    environment:
      - CORE_LEDGER_STATE_STATEDATABASE=CouchDB
      - CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS=couchdb'$(($1+1))':5984
      - CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME=admin
      - CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD=adminpw
    depends_on:
      - couchdb'$(($1+1))'
    networks:
      - test' > "${PWD}/docker/docker-compose-couch-org$1.yaml"


# Edit docker-compose-org.yaml

echo '# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

version: '"'2'"'

volumes:
  peer0.org'$1'.example.com:

networks:
  test:

services:

  peer0.org'$1'.example.com:
    container_name: peer0.org'$1'.example.com
    image: hyperledger/fabric-peer:latest
    labels:
      service: hyperledger-fabric
    environment:
      #Generic peer variables
      - CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock
      - CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE=${COMPOSE_PROJECT_NAME}_test
      - FABRIC_LOGGING_SPEC=INFO
      #- FABRIC_LOGGING_SPEC=DEBUG
      - CORE_PEER_TLS_ENABLED=true
      - CORE_PEER_PROFILE_ENABLED=true
      - CORE_PEER_TLS_CERT_FILE=/etc/hyperledger/fabric/tls/server.crt
      - CORE_PEER_TLS_KEY_FILE=/etc/hyperledger/fabric/tls/server.key
      - CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/tls/ca.crt
      # Peer specific variables
      - CORE_PEER_ID=peer0.org'$1'.example.com
      - CORE_PEER_ADDRESS=peer0.org'$1'.example.com:'$((7054+2000*$(($1-1))-3))'
      - CORE_PEER_LISTENADDRESS=0.0.0.0:'$((7054+2000*$(($1-1))-3))'
      - CORE_PEER_CHAINCODEADDRESS=peer0.org'$1'.example.com:'$((7054+2000*$(($1-1))-2))'
      - CORE_PEER_CHAINCODELISTENADDRESS=0.0.0.0:'$((7054+2000*$(($1-1))-2))'
      - CORE_PEER_GOSSIP_BOOTSTRAP=peer0.org'$1'.example.com:'$((7054+2000*$(($1-1))-3))'
      - CORE_PEER_GOSSIP_EXTERNALENDPOINT=peer0.org'$1'.example.com:'$((7054+2000*$(($1-1))-3))'
      - CORE_PEER_LOCALMSPID=Org'$1'MSP
    volumes:
        - /var/run/docker.sock:/host/var/run/docker.sock
        - ../../organizations/peerOrganizations/org'$1'.example.com/peers/peer0.org'$1'.example.com/msp:/etc/hyperledger/fabric/msp
        - ../../organizations/peerOrganizations/org'$1'.example.com/peers/peer0.org'$1'.example.com/tls:/etc/hyperledger/fabric/tls
        - peer0.org'$1'.example.com:/var/hyperledger/production
    working_dir: /opt/gopath/src/github.com/hyperledger/fabric/peer
    command: peer node start
    ports:
      - '$((7054+2000*$(($1-1))-3))':'$((7054+2000*$(($1-1))-3))'
    networks:
      - test' > "${PWD}/docker/docker-compose-org$1.yaml"

# Generate configtx.yaml

echo '# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

---
################################################################################
#
#   Section: Organizations
#
#   - This section defines the different organizational identities which will
#   be referenced later in the configuration.
#
################################################################################
Organizations:
    - &Org'$1'
        # DefaultOrg defines the organization which is used in the sampleconfig
        # of the fabric.git development environment
        Name: Org'$1'MSP

        # ID to load the MSP definition as
        ID: Org'$1'MSP

        MSPDir: ../organizations/peerOrganizations/org'$1'.example.com/msp

        Policies:
            Readers:
                Type: Signature
                Rule: "OR('"'Org$1MSP.admin'"', '"'Org$1MSP.peer'"', '"'Org$1MSP.client'"')"
            Writers:
                Type: Signature
                Rule: "OR('"'Org$1MSP.admin'"', '"'Org$1MSP.client'"')"
            Admins:
                Type: Signature
                Rule: "OR('"'Org$1MSP.admin'"')"
            Endorsement:
                Type: Signature
                Rule: "OR('"'Org$1MSP.peer'"')"' > configtx.yaml

echo '#!/bin/bash

function one_line_pem {
    echo "'"\`awk '"'NF {sub(/\\\\n/, ""); printf "'"%s\\\\\\\\\\\\\\\\\\\\\\\\\\\n"'",$0;}'"' \$1\`"'"
}

function json_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        ccp-template.json
}

function yaml_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        ccp-template.yaml | sed -e $'"'s/\\\\\\\\\\\\\\\n/\\\\\\\\\\\n        /g'"'
}

ORG='$1'
P0PORT='$((7054+2000*$(($1-1))-3))'
CAPORT='$((7054+2000*$(($1-1))))'
PEERPEM=../organizations/peerOrganizations/org'$1'.example.com/tlsca/tlsca.org'$1'.example.com-cert.pem
CAPEM=../organizations/peerOrganizations/org'$1'.example.com/ca/ca.org'$1'.example.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > ../organizations/peerOrganizations/org'$1'.example.com/connection-org'$1'.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > ../organizations/peerOrganizations/org'$1'.example.com/connection-org'$1'.yaml' > "${PWD}/ccp-generate$1.sh"
