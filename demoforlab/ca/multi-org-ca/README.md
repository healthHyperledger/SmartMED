Please NOTE:
============
The client and server folders are not empty. You may setup all the identities and any new identity if required, use the script `clean.sh all` to 
clear all the identites. 

Setting up the identities
==========
The crypto-material we will be using is generated via fabric-ca.  
- Get the fabric-ca-server running as instructed in the parent directory README.
- Run the script `register-enroll-admins.sh`, this will generate the required crypto material for all the org-admin including the orderer org.
- To add an identity to a corresponding org, first set the client as the org-admin using `. setclient.sh <org-name> admin`.
- Register the identity as the org-admin and perform enrollment as the user itself.
- The identity needs to be signed by the org-admin that has performed the addition of the new identity, run `add-admincerts.sh <org-name> <user-name>` to add the 
  signcerts of the admin to the identity folder. 

PS:
===
- You must add the orderer identity to run the orderer node, orderer-admin and orderer are two different identities and one cannot perform the same operation as
  the other.
```
$ . setlcient.sh orderer admin
$ fabric-ca-client register --id.name orderer --id.type orderer --id.affiliation orderer --id.secret pw
$ . setlcient orderer orderer
$ fabric-ca-client enroll -u http://orderer:pw@localhost:7054
```
Scripts
=======
- ca/multi-org-ca/run-all.sh      Will setup the Crypto for the muti-org-ca setup. It sets up the
                                - Org admins
                                - Org msps
                                - You still need to generate the Orderer & Peer identities
                                Use this script once you understand the identity management
                                in Fabric

- ca/clean.sh             Cleans up the ./server & ./client folder
- ca/setclient.sh         Sets the FABRIC_CA_CLIENT_HOME takes ORG and User. 
                        If args not provided current value shown
- ca/add-admincerts.sh    Adds the admin's cert to msp/admincerts folder of the specified identity 


- ca/server.sh                    (1) Initialize, Start/Stop CA Server, Enroll CA Server admin
                                    ./server.sh start
                                    ./server.sh enroll

- ca/register-enroll-admins.sh    (2) Registers and enrolls the admins
                                    ./register-enroll-admins.sh

                                (2.1)  Set up org identity(s) + Add admin certs
                
- ca/setup-org-msp.sh             (3) Setup the org msps


- peer/launch-peer.sh  Launches the peer specified by ORG-Name & Peer_Name ... port number pending
- peer/set-env.sh      Sets the environment vars for the provided ORG_Name & Peer
- peer/show-env.sh     Shows the current environment

- peer/config/generate-baseline.sh    Generates the baseline json configuration
- peer/config/clean.sh                Deletes the json/pb/block files from the folder
