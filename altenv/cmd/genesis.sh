
sudo rm ../org1/peers/peer1/assets/mychannel.block
export COMPOSE_PROJECT_NAME=cmd
docker-compose -f compose.yml down --volumes
sleep 10s
rm -r ../org0/orderer/genesis.block
rm -r ../org1/peers/peer1/assets/channel.tx
sleep 2s
rm -r ../org1/peers/peer1/assets/mychannel.block
rm -r ../org2/peers/peer1/assets/mychannel.block
sleep 2s

echo "                                                                "
echo "################################################################"
echo "############### cleaning the environment  ######################"
echo "################################################################"
echo "                                                                "
./configtxgen -profile TwoOrgsOrdererGenesis -channelID byfn-sys-channel -outputBlock ../org0/orderer/genesis.block
sleep 2s
echo "                                                          "
echo "################################################################"
echo "############### Generating the genesis block  ##################"
echo "################################################################"
echo "                                                                "

export CHANNEL_NAME=mychannel
./configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ../org1/peers/peer1/assets/channel.tx -channelID $CHANNEL_NAME
sleep 2s
echo "                                                                "
echo "################################################################"
echo "############### Generating the transaction channel  ############"
echo "################################################################"
echo "                                                                "

export COMPOSE_PROJECT_NAME=cmd
docker-compose -f compose.yml up -d
sleep 10s

echo "                                                                "
echo "################################################################"
echo "############### starting the network                ############"
echo "################################################################"
echo "                                                                "


docker exec -e "CORE_PEER_MSPCONFIGPATH=/tmp/hyperledger/org1/admin/msp"  cli-org1 peer channel create -c mychannel -f /tmp/hyperledger/org1/peer1/assets/channel.tx -o orderer1-org0:7050 --outputBlock /tmp/hyperledger/org1/peer1/assets/mychannel.block --tls --cafile /tmp/hyperledger/org1/peer1/tls-msp/tlscacerts/tls-0-0-0-0-7052.pem
sleep 2s
cp ../org1/peers/peer1/assets/mychannel.block ../org2/peers/peer1/assets/mychannel.block


echo "                                                                "
echo "################################################################"
echo "############### creating  channel                   ############"
echo "################################################################"
echo "                                                                "


docker exec -e "CORE_PEER_MSPCONFIGPATH=/tmp/hyperledger/org1/admin/msp" -e "CORE_PEER_ADDRESS=peer1-org1:7051" cli-org1 peer channel join -b /tmp/hyperledger/org1/peer1/assets/mychannel.block
sleep 2s
echo "                                                                "
echo "################################################################"
echo "############### joining peer1-org1 to my channel    ############"
echo "################################################################"
echo "                                                                "



docker exec -e "CORE_PEER_MSPCONFIGPATH=/tmp/hyperledger/org1/admin/msp" -e "CORE_PEER_ADDRESS=peer2-org1:7051" cli-org1 peer channel join -b /tmp/hyperledger/org1/peer1/assets/mychannel.block
sleep 2s
echo "                                                                "
echo "################################################################"
echo "############### joining peer2-org1 to my channel    ############"
echo "################################################################"
echo "                                                                "





docker exec -e "CORE_PEER_MSPCONFIGPATH=/tmp/hyperledger/org2/admin/msp" -e "CORE_PEER_ADDRESS=peer1-org2:7051" cli-org2 peer channel join -b /tmp/hyperledger/org2/peer1/assets/mychannel.block
sleep 2s
echo "                                                                "
echo "################################################################"
echo "############### joining peer1-org2 to my channel    ############"
echo "################################################################"
echo "                                                                "

docker exec -e "CORE_PEER_MSPCONFIGPATH=/tmp/hyperledger/org2/admin/msp" -e "CORE_PEER_ADDRESS=peer2-org2:7051" cli-org2 peer channel join -b /tmp/hyperledger/org2/peer1/assets/mychannel.block
sleep 2s
echo "                                                                "
echo "################################################################"
echo "############### joining peer2-org2 to my channel    ############"
echo "################################################################"
echo "                                                                "


docker exec -e "CORE_PEER_MSPCONFIGPATH=/tmp/hyperledger/org1/admin/msp" -e "CORE_PEER_ADDRESS=peer1-org1:7051" cli-org1 peer chaincode install -n mycc -v 1.0 -p github.com/hyperledger/fabric-samples/chaincode/sacc/
sleep 2s
echo "                                                                "
echo "################################################################"
echo "############### installing chaincode on peer1-org1       #######"
echo "################################################################"
echo "                                                                "


docker exec -e "CORE_PEER_MSPCONFIGPATH=/tmp/hyperledger/org1/admin/msp" -e "CORE_PEER_ADDRESS=peer2-org1:7051" cli-org1 peer chaincode install -n mycc -v 1.0 -p github.com/hyperledger/fabric-samples/chaincode/sacc/
sleep 2s
echo "################################################################"
echo "############### installing chaincode on peer2-org1       #######"
echo "################################################################"
echo "                                                                "



docker exec -e "CORE_PEER_MSPCONFIGPATH=/tmp/hyperledger/org2/admin/msp" -e "CORE_PEER_ADDRESS=peer1-org2:7051" cli-org2 peer chaincode install -n mycc -v 1.0 -p github.com/hyperledger/fabric-samples/chaincode/sacc/
sleep 2s
echo "                                                                "
echo "################################################################"
echo "############### installing chaincode on peer1-org2      #######"
echo "################################################################"
echo "                                                                "


docker exec -e "CORE_PEER_MSPCONFIGPATH=/tmp/hyperledger/org2/admin/msp" -e "CORE_PEER_ADDRESS=peer2-org2:7051" cli-org2 peer chaincode install -n mycc -v 1.0 -p github.com/hyperledger/fabric-samples/chaincode/sacc/
sleep 2s
echo "################################################################"
echo "############### installing chaincode on peer2-org2       #######"
echo "################################################################"
echo "                                                                "
sleep 7s


echo "################################################################"
echo "############### instantiating chaincode on peer2-org2      #####"
echo "################################################################"
echo "                                                                "

#docker exec -e "CORE_PEER_MSPCONFIGPATH=/tmp/hyperledger/org2/admin/msp" -e "CORE_PEER_ADDRESS=peer2-org2:7051" cli-org2 peer chaincode instantiate -C mychannel -n mycc -v 1.0 -c '{"Args":["a","10"]}' -o orderer1-org0:7050 --tls --cafile /tmp/hyperledger/org2/peer1/tls-msp/tlscacerts/tls-0-0-0-0-7052.pem
#
#
#docker exec -e "CORE_PEER_MSPCONFIGPATH=/tmp/hyperledger/org2/admin/msp" -e "CORE_PEER_ADDRESS=peer2-org2:7051" cli-org2 peer chaincode query -C mychannel -n mycc -c '{"Args":["query","a"]}'