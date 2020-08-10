echo "Make sure you've set all the identities beforehand."
./generate-genesis.sh
./generate-channel-tx.sh
echo "launching orderer binary in solo ordering mode."
orderer