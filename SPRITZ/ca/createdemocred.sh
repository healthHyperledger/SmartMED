function setupMSP {
    mkdir -p $FABRIC_CA_CLIENT_HOME/msp/admincerts

    echo "====> $FABRIC_CA_CLIENT_HOME/msp/admincerts"
    cp $FABRIC_CA_CLIENT_HOME/../../caserver/admin/msp/signcerts/*  $FABRIC_CA_CLIENT_HOME/msp/admincerts
}

export FABRIC_CA_CLIENT_HOME=$PWD/client/caserver/admin
echo "Enrolling: ca-server admin"
fabric-ca-client enroll -u http://admin:pw@localhost:7054

echo "Registering: healthcare-admin"
ATTRIBUTES='"hf.Registrar.Roles=peer,user,client","hf.AffiliationMgr=true","hf.Revoker=true"'
fabric-ca-client register --id.type client --id.name healthcare-admin --id.secret pw --id.affiliation healthcare --id.attrs $ATTRIBUTES

echo "Registering: orderer-admin"
ATTRIBUTES='"hf.Registrar.Roles=orderer"'
fabric-ca-client register --id.type client --id.name orderer-admin --id.secret pw --id.affiliation orderer --id.attrs $ATTRIBUTES
fabric-ca-client register --id.name client --id.name patient --id.secret pw --id.affiliation healthcare.patient --id.attrs patient=lv10
fabric-ca-client register --id.name client --id.name requestor --id.secret pw --id.affiliation healthcare.others --id.attrs patient=lv4
fabric-ca-client register --id.name client --id.name doctor --id.secret pw --id.affiliation healthcare.doctor --id.attrs patient=lv3

echo "Enrolling: healthcare-admin"
ORG_NAME="healthcare"
source setclient.sh   $ORG_NAME   admin  
mkdir -p $FABRIC_CA_CLIENT_HOME
cp $PWD/clientyaml/healthcare/* $FABRIC_CA_CLIENT_HOME/
fabric-ca-client enroll -u http://healthcare-admin:pw@localhost:7054

mkdir -p $FABRIC_CA_CLIENT_HOME/msp/admincerts
cp $PWD/client/caserver/admin/msp/signcerts/* $FABRIC_CA_CLIENT_HOME/msp/admincerts/
source setclient.sh   $ORG_NAME   patient
fabric-ca-client enroll -u http://patient:pw@localhost:7054
./add-admincerts.sh $ORG_NAME patient
source setclient.sh   $ORG_NAME   requestor
fabric-ca-client enroll -u http://requestor:pw@localhost:7054
./add-admincerts.sh $ORG_NAME requestor
source setclient.sh   $ORG_NAME   doctor
fabric-ca-client enroll -u http://doctor:pw@localhost:7054
./add-admincerts.sh $ORG_NAME doctor
setupMSP

echo "Enrolling: orderer-admin"
ORG_NAME="orderer"
source setclient.sh   $ORG_NAME   admin
mkdir -p $FABRIC_CA_CLIENT_HOME
cp $PWD/clientyaml/orderer/* $FABRIC_CA_CLIENT_HOME/
fabric-ca-client enroll -u http://orderer-admin:pw@localhost:7054
mkdir -p $FABRIC_CA_CLIENT_HOME/msp/admincerts
cp $PWD/client/caserver/admin/msp/signcerts/* $FABRIC_CA_CLIENT_HOME/msp/admincerts/
fabric-ca-client register --id.type orderer --id.name orderer --id.secret pw --id.affiliation orderer 
source setclient.sh   $ORG_NAME   orderer
fabric-ca-client enroll -u http://orderer:pw@localhost:7054
./add-admincerts.sh $ORG_NAME orderer
setupMSP

./setup-org-msp.sh healthcare
./setup-org-msp.sh orderer