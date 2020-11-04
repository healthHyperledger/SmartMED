
################################################################
##############       ordere1 setup                  ############
################################################################


mkdir -p orderer/assets/ca
mkdir  orderer/assets/tls-ca
sleep 2s
cp ./ca/server/crypto/ca-cert.pem ./orderer/assets/ca/org0-ca-cert.pem
cp ../TLS-CA/server/crypto/ca-cert.pem ./orderer/assets/tls-ca/tls-ca-cert.pem
sleep 2s
#################################################################
################ configuring the environment ####################
#################################################################


export FABRIC_CA_CLIENT_HOME=./orderer
export FABRIC_CA_CLIENT_TLS_CERTFILES=assets/ca/org0-ca-cert.pem

fabric-ca-client enroll -d -u https://orderer1-org0:ordererpw@0.0.0.0:7053
sleep 2s

echo "                                                                 "
echo "#################################################################"
echo "################ orderer-org0 enrolled to org0 CA ###############"
echo "#################################################################"
echo "                                                                 "
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=assets/tls-ca/tls-ca-cert.pem
fabric-ca-client enroll -d -u https://orderer1-org0:ordererPW@0.0.0.0:7052 --enrollment.profile tls --csr.hosts orderer1-org0
sleep 2s
echo "                                                                 "
echo "#################################################################"
echo "################ orderer1-org0 enrolled to TLS-CA ###############"
echo "#################################################################"
echo "                                                                 "

################################################################
#####Go to path org0/orderer/tls-msp/keystore ##############
#####and change the name of the key to key.pem.  ###############
################################################################

