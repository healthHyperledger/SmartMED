
mkdir -p ca/server
sleep 1s

mkdir -p ca/client/admin
sleep 2s
#################################################################
################ configuring the environment ####################
#################################################################
docker-compose -f ordererCA.yml up -d
sleep 4s


cp ./ca/server/crypto/ca-cert.pem ./ca/client/admin/tls-ca-cert.pem
sleep 2s









export FABRIC_CA_CLIENT_HOME=./ca/client/admin
export FABRIC_CA_CLIENT_TLS_CERTFILES=tls-ca-cert.pem
sleep 2s
#########################################################################
######If the path of the environment variable                      ######
######FABRIC_CA_CLIENT_TLS_CERTFILES is not an absolute path,      ######
######it will be parsed as relative to the client’s home directory ######
#########################################################################

fabric-ca-client enroll -d -u https://rca-org0-admin:rca-org0-adminpw@0.0.0.0:7053
sleep 2s
echo "                                                                 "
echo "#################################################################"
echo "################ Orderer-Admin enrolled ##########################"
echo "#################################################################"
echo "                                                                 "
fabric-ca-client register -d --id.name orderer1-org0 --id.secret ordererpw --id.type orderer -u https://0.0.0.0:7053
sleep 2s
echo "                                                                 "
echo "#################################################################"
echo "################ orderer1-org0 registered #######################"
echo "#################################################################"
echo "                                                                 "
fabric-ca-client register -d --id.name admin-org0 --id.secret org0adminpw --id.type admin --id.attrs "hf.Registrar.Roles=client,hf.Registrar.Attributes=*,hf.Revoker=true,hf.GenCRL=true,admin=true:ecert,abac.init=true:ecert" -u https://0.0.0.0:7053
sleep 2s
echo "                                                                 "
echo "#################################################################"
echo "################ admin-org0 registered ##########################"
echo "#################################################################"
echo "                                                                 "
