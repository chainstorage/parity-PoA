#!/bin/bash

# Write here you phrases and passwords
NODE0_Phrase="ololo6test3zzzsdcdscsvwfv2csvc";  NODE0_pass="hb3hjv56dt35"
NODE1_Phrase="ertr7ergtgtrgr6rrhgrhddffhwsvc";  NODE1_pass="5dtmk543l4hd"
NODE2_Phrase="sdgdfgfffffffffffffgdfffdagfgg";  NODE2_pass="d4y46y48oijy"

PARITY_VERSION=v1.10.7

################# Build image ###############################################
docker build --build-arg PARITY_VERSION=$PARITY_VERSION -t parity:$PARITY_VERSION .

######################## Run init enviroment with initial configs ##########################
env IMG=parity:$PARITY_VERSION docker stack deploy --compose-file ./docker-compose.yml poainit

sleep 20

# Generate id and password,
NODE0_ID=$(curl -s -X POST --data "{\"method\":\"parity_newAccountFromPhrase\",\"params\":[\"$NODE0_Phrase\",\"$NODE0_pass\"],\"id\":1,\"jsonrpc\":\"2.0\"}" \
-H "Content-Type: application/json" localhost:8560 |cut -d\" -f8)

NODE1_ID=$(curl -s -X POST --data "{\"method\":\"parity_newAccountFromPhrase\",\"params\":[\"$NODE1_Phrase\",\"$NODE1_pass\"],\"id\":1,\"jsonrpc\":\"2.0\"}" \
-H "Content-Type: application/json" localhost:8561 |cut -d\" -f8)

NODE2_ID=$(curl -s -X POST --data "{\"method\":\"parity_newAccountFromPhrase\",\"params\":[\"$NODE2_Phrase\",\"$NODE2_pass\"],\"id\":1,\"jsonrpc\":\"2.0\"}" \
-H "Content-Type: application/json" localhost:8562 |cut -d\" -f8)

echo node0: $NODE0_ID
echo node1: $NODE1_ID
echo node2: $NODE2_ID

######################### Generate new configs ############################################
# Generate chain.json
cp parity/config_init/chain.json parity/config_generated/chain.json
sed -i "/list/a \"$NODE0_ID\", \"$NODE1_ID\", \"$NODE2_ID\"" parity/config_generated/chain.json

mkdir -p parity/config_generated/node0 parity/config_generated/node1 parity/config_generated/node2
cp parity/config_generated/chain.json parity/config_generated/node0/chain.json
cp parity/config_generated/chain.json parity/config_generated/node1/chain.json
cp parity/config_generated/chain.json parity/config_generated/node2/chain.json

# Write to ./parity/pwd/nodeX/passwoer.file
echo $NODE0_pass > parity/config_generated/node0/password.file
echo $NODE1_pass > parity/config_generated/node1/password.file
echo $NODE2_pass > parity/config_generated/node2/password.file

# Generate daemon configs
cp parity/config_init/node0/daemon.toml parity/config_generated/node0/daemon.toml
cp parity/config_init/node1/daemon.toml parity/config_generated/node1/daemon.toml
cp parity/config_init/node2/daemon.toml parity/config_generated/node2/daemon.toml

cat parity/config_init/daemon.template >> parity/config_generated/node0/daemon.toml
cat parity/config_init/daemon.template >> parity/config_generated/node1/daemon.toml
cat parity/config_init/daemon.template >> parity/config_generated/node2/daemon.toml

echo engine_signer = \"$NODE0_ID\" >> parity/config_generated/node0/daemon.toml
echo engine_signer = \"$NODE1_ID\" >> parity/config_generated/node1/daemon.toml
echo engine_signer = \"$NODE2_ID\" >> parity/config_generated/node2/daemon.toml

# Generate new compose file
cp docker-compose.yml docker-compose-generated.yml
sed -i 's/config_init/config_generated/g' docker-compose-generated.yml


docker stack rm poainit
env IMG=parity:$PARITY_VERSION docker stack deploy --compose-file ./docker-compose-generated.yml poa

sleep 5

docker service logs --tail 20 poa_node0
