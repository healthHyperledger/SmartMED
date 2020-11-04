
#################################################################
###############       peer1 setup                  ##############
#################################################################


mkdir -p peers/peer1/assets/ca
mkdir  peers/peer1/assets/tls-ca
sleep 2s
cp ./ca/server/crypto/ca-cert.pem ./peers/peer1/assets/ca/org2-ca-cert.pem
cp ../TLS-CA/server/crypto/ca-cert.pem ./peers/peer1/assets/tls-ca/tls-ca-cert.pem
sleep 2s
#################################################################
################ configuring the environment ####################
#################################################################


export FABRIC_CA_CLIENT_HOME=./peers/peer1/
export FABRIC_CA_CLIENT_TLS_CERTFILES=assets/ca/org2-ca-cert.pem

fabric-ca-client enroll -d -u https://peer1-org2:peer1PW@0.0.0.0:7055
sleep 2s

echo "                                                                 "
echo "#################################################################"
echo "################ peer1-org2 enrolled to org2 CA ##############################"
echo "#################################################################"
echo "                                                                 "
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=assets/tls-ca/tls-ca-cert.pem
fabric-ca-client enroll -d -u https://peer1-org2:peer1PW@0.0.0.0:7052 --enrollment.profile tls --csr.hosts peer1-org2


sleep 2s
echo "                                                                 "
echo "#################################################################"
echo "################ peer1-org2 enrolled to TLS-CA ##############################"
echo "#################################################################"
echo "                                                                 "

#################################################################
######Go to path org2/peers/peer1/tls-msp/keystore ##############
######and change the name of the key to key.pem.  ###############
#################################################################

