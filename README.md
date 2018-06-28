# 3-authority PoA network

Build  Parity from scratch and launch 3-authority [PoA network](https://wiki.parity.io/Proof-of-Authority-Chains "Proof-of-Authority-Chains")

# Requirements

* git
* docker
* docker-compose

## Easy Start

Clone repo: 

```
git clone https://github.com/chainstorage/parity-PoA.git
cd ./parity-PoA
./run.sh
```

Monitoring dashboard will be available at

http://127.0.0.1:3001/

## Parameters

You can set in head of run.sh :

* Phrase and passwords for autority
* PARITY_VERSION for building

## Clean your enviroment after launch

```
./clean_all.sh
```
