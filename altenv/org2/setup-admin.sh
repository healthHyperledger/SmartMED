




################################################################
##############       org2-admin setup             ##############
################################################################

mkdir  -p admin/ca
sleep 2s
cp ./ca/server/crypto/ca-cert.pem ./admin/ca/org2-ca-cert.pem
sleep 1s
export FABRIC_CA_CLIENT_HOME=./admin
export FABRIC_CA_CLIENT_TLS_CERTFILES=ca/org2-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp

fabric-ca-client enroll -d -u https://admin-org2:org2AdminPW@0.0.0.0:7055
sleep 2s
echo "                                                                 "
echo "#################################################################"
echo "################ org1-admin enrolled to org1 CA ##############################"
echo "#################################################################"
echo "                                                                 "

#################################################################
######  copy the certificate from this admin MSP    ###############
######  and move it to the peer1 and peer2 MSP in  ###############
####### the admincerts folder                     ###############
#################################################################


mkdir peers/peer1/msp/admincerts
mkdir peers/peer2/msp/admincerts
mkdir admin/msp/admincerts
sleep 2s
cp ./admin/msp/signcerts/cert.pem ./peers/peer1/msp/admincerts/org2-admin-cert.pem
cp ./admin/msp/signcerts/cert.pem ./peers/peer2/msp/admincerts/org2-admin-cert.pem
cp ./admin/msp/signcerts/cert.pem  ./admin/msp/admincerts/org2-admin-cert.pem
sleep 2s
