#################################################################
###############       msp-org1 setup               ##############
#################################################################


mkdir -p msp/admincerts
mkdir  msp/cacerts
mkdir  msp/tlscacerts
mkdir  msp/users

sleep 2s
# copying org1 root ca certificat to msp/cacerts directory.
cp ./ca/server/crypto/ca-cert.pem ./msp/cacerts/org1-ca-cert.pem
# copying TLS CA root certificat to msp/tlscacerts directory.
cp ../TLS-CA/server/crypto/ca-cert.pem ./msp/tlscacerts/tls-ca-cert.pem
# copying org1 admin singning certificat to msp/admincerts directory.

cp ./admin/msp/signcerts/cert.pem  ./msp/admincerts/org1-admin-cert.pem
