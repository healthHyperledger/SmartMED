mkdir -p ca/server
sleep 1s
mkdir -p ca/client/admin
sleep 2s
#################################################################
################ configuring the environment ####################
#################################################################

docker-compose -f org1CA.yml up -d
sleep 4s
#copys the org1-CA server root ceritficate to org1-ca client for tls authentication
cp ./ca/server/crypto/ca-cert.pem ./ca/client/admin/tls-ca-cert.pem
sleep 2s

export FABRIC_CA_CLIENT_HOME=./ca/client/admin
export FABRIC_CA_CLIENT_TLS_CERTFILES=tls-ca-cert.pem
sleep 2s

fabric-ca-client enroll -d -u https://rca-org1-admin:rca-org1-adminpw@0.0.0.0:7054
sleep 2s

fabric-ca-client register -d --id.name peer1-org1 --id.secret peer1PW --id.type peer -u https://0.0.0.0:7054
sleep 2s

fabric-ca-client register -d --id.name peer2-org1 --id.secret peer2PW --id.type peer -u https://0.0.0.0:7054
sleep 2s

fabric-ca-client register -d --id.name admin-org1 --id.secret org1AdminPW --id.type client -u https://0.0.0.0:7054
sleep 2s

fabric-ca-client register -d --id.name user-org1 --id.secret org1UserPW --id.type user -u https://0.0.0.0:7054
sleep 2s