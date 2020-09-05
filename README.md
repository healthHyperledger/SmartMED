# SmartMED

**Dependencies**
- oracle virtual-box 
- vagrant
- vagrantFile for the test-environment
- visual-studio code
- docker
- fabric binaries


## Installation

- Download the vagrant environment `https://drive.google.com/file/d/1VEA_GMVkFieWBnGa8zVvSfcCO5VVnngc/view?usp=sharing` and extract the file to obtain the vagrant
  machine directory.
- Navigate to the directory and run `vagrant up`.
- After the VM is up, run `vagrant ssh`, this will connect your terminal to the Ubuntu VM via CLI that we will be using for 
  interacting with our environment. (Keep atleast 4 terminals open).
- The necessary identities that are required to put up a network are already created, only use the CA client to add new users to the network.
- Run the `clean.sh` scripts in the orderer and peer directory and `clean-peer-ledger-folder.sh` in the peer directory.

### Running the CA Server

- The CA server must be running in order to register and enroll new identities to the network.
```shell
$ export FABRIC_CA_SERVER_HOME=/vagrant/demoforlab/ca/multi-org-ca/server
$ fabric-ca-server start
```

### Running the orderer node

- The CA server must be running in order to register and enroll new identities to the network.
```shell
$ cd demoforlab/orderer/multi-org-ca/
$ ./generate-genesis.sh
$ ./generate-channel-tx.sh
# ./launch.sh
```
### Running the peer node

- Following commands show how to run a peer node and join the healthcare channel.
```shell
$ cd demoforlab/peer/multi-org-ca/
$ . set-env.sh healthcare peer1 7050 admin
$ ./sign-channel-tx.sh
$ ./submit-create-channel.sh
$ ./launch.sh healthcare peer1 7050 
```
- Now switch to another terminal connected to the vagrant machine.
```shell
$ . set-env.sh healthcare peer1 7050 admin
$ ./join-healthcare-channel.sh
```

