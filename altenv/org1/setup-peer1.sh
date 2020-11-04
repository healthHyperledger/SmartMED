mkdir -p peers/peer1/assets/ca
mkdir  peers/peer1/assets/tls-ca
sleep 2s
#copying  org1 root certificate to peer1-org1
cp ./ca/server/crypto/ca-cert.pem ./peers/peer1/assets/ca/org1-ca-cert.pem
#copying TLS-CA root certificate to  peer1-org1 for tls authentication
cp ../TLS-CA/server/crypto/ca-cert.pem ./peers/peer1/assets/tls-ca/tls-ca-cert.pem
sleep 2s
#################################################################
################ configuring the environment ####################
#################################################################

//peer1-org1 enrolling with org1-ca
export FABRIC_CA_CLIENT_HOME=./peers/peer1/
export FABRIC_CA_CLIENT_TLS_CERTFILES=assets/ca/org1-ca-cert.pem

fabric-ca-client enroll -d -u https://peer1-org1:peer1PW@0.0.0.0:7054
sleep 2s

// peer1-org1 enrolling with TLS-CA to get tls certificate
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=assets/tls-ca/tls-ca-cert.pem
fabric-ca-client enroll -d -u https://peer1-org1:peer1PW@0.0.0.0:7052 --enrollment.profile tls --csr.hosts peer1-org1
