#################################################################
###############       peer2 setup                  ##############
#################################################################


mkdir -p peers/peer2/assets/ca
mkdir  peers/peer2/assets/tls-ca

cp ./ca/server/crypto/ca-cert.pem ./peers/peer2/assets/ca/org1-ca-cert.pem
cp ../TLS-CA/server/crypto/ca-cert.pem ./peers/peer2/assets/tls-ca/tls-ca-cert.pem
sleep 2s
#################################################################
################ configuring the environment ####################
#################################################################


export FABRIC_CA_CLIENT_HOME=./peers/peer2/
export FABRIC_CA_CLIENT_TLS_CERTFILES=assets/ca/org1-ca-cert.pem

fabric-ca-client enroll -d -u https://peer2-org1:peer2PW@0.0.0.0:7054

sleep 2s

echo "                                                                 "
echo "#################################################################"
echo "################ peer2-org1 enrolled to org1 CA ##############################"
echo "#################################################################"
echo "                                                                 "
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=assets/tls-ca/tls-ca-cert.pem
fabric-ca-client enroll -d -u https://peer2-org1:peer2PW@0.0.0.0:7052 --enrollment.profile tls --csr.hosts peer2-org1
sleep 2s
echo "                                                                 "
echo "#################################################################"
echo "################ peer2-org1 enrolled to TLS-CA ##############################"
echo "#################################################################"
echo "                                                                 "

#################################################################
######Go to path org1/peers/peer2/tls-msp/keystore ##############
######and change the name of the key to key.pem.  ###############
#################################################################

