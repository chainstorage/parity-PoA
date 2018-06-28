#!/bin/sh

docker stack rm poa
docker stack rm poainit

sleep 15

rm -rf ./parity/config_generated/*
rm -f docker-compose-generated.yml
sudo rm -rf ./parity/data/node[0-9]/*
