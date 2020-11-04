

###############################################################
#############       Org0-admin setup                  ##############
###############################################################

mkdir  -p admin/ca
sleep 2s
cp ./ca/server/crypto/ca-cert.pem ./admin/ca/org0-ca-cert.pem
sleep 1s
export FABRIC_CA_CLIENT_HOME=./admin
export FABRIC_CA_CLIENT_TLS_CERTFILES=ca/org0-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp

fabric-ca-client enroll -d -u https://admin-org0:org0adminpw@0.0.0.0:7053

sleep 2s
echo "                                                                 "
echo "#################################################################"
echo "################ org0-admin enrolled to org0 CA #################"
echo "#################################################################"
echo "                                                                 "

#################################################################
######  copy the certificate from this admin MSP    ###############
######  and move it to the orderer MSP in  ###############
####### the admincerts folder                     ###############
#################################################################


mkdir orderer/msp/admincerts
mkdir admin/msp/admincerts
sleep 2s
cp ./admin/msp/signcerts/cert.pem ./orderer/msp/admincerts/org0-admin-cert.pem
cp ./admin/msp/signcerts/cert.pem ./admin/msp/admincerts/org0-admin-cert.pem
sleep 2s
