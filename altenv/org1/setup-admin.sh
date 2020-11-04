################################################################
##############       org1-admin setup                  ##############
################################################################

mkdir  -p admin/ca
sleep 2s
cp ./ca/server/crypto/ca-cert.pem ./admin/ca/org1-ca-cert.pem
sleep 1s
export FABRIC_CA_CLIENT_HOME=./admin
export FABRIC_CA_CLIENT_TLS_CERTFILES=ca/org1-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp
fabric-ca-client enroll -d -u https://admin-org1:org1AdminPW@0.0.0.0:7054
sleep 2s

# here we are creating admincerts dierctory in  every peer msp so that all the peers including the orderer have there  org's admin cert there
mkdir peers/peer1/msp/admincerts
mkdir peers/peer2/msp/admincerts
mkdir admin/msp/admincerts
sleep 2s
cp ./admin/msp/signcerts/cert.pem ./peers/peer1/msp/admincerts/org1-admin-cert.pem
cp ./admin/msp/signcerts/cert.pem ./peers/peer2/msp/admincerts/org1-admin-cert.pem
cp ./admin/msp/signcerts/cert.pem  ./admin/msp/admincerts/org1-admin-cert.pem
sleep 2s
