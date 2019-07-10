# ZkNFT - Private NFTs with Zokrates and zkSNARKs

## Installation
### Prerequisites
This repository uses the `dapp.tools` toolchain for interacting with Ethereum. Please install it first by running:

    $ curl https://dapp.tools/install | sh

or check out https://dapp.tools/ for other installation options

If you want to run a local testnet with geth, the simplest way to do so is to run `dapp testnet`

    $ dapp testnet
    ...

### Environment variables
The following variables are required:

    export ETH_PASSWORD=/dev/null
    export ETH_GAS=5000000
    export ETH_KEYSTORE=~/PATH_TO_KEYSTORE
    export ETH_FROM=0x5a65c5e4289c34854f07dbb749ec7e8949a9131d
    export ETH_RPC_URL=http://localhost:8545

Running `./setup-env` will print the correct values for your local parity node or testnet instance. 
For Rinkeby the the quickest setup is to use Infura.

### Deployment
If you run a local instance, you will need to deploy the centrifuge contracts, which is out of scope for this. Alternatively you can deploy an instance of `AnchorMock` from src/test/zknft.t.sol that will allow you to imitate the behavior of the contract as shown in the zknft.t.sol test file.

Make sure you export the registry address that is printed as the variable NFT_REGISTRY after the dployment is done.

### Testing
The script `test-transaction` has a proof and the necessary data embedded to validate the circuit that is included in verifier.sol. You can execute it to see what it does.

## Compile the circuit
It assumes that Zokrates is installed and zokrates-pycrypto is part of your PYTHONPATH.

Install Zokrates: https://zokrates.github.io/gettingstarted.html

Install/Download Zokrates-pycrypto: https://github.com/Zokrates/pycrypto

  ```$bash
  mkdir -p out && cp proof_data.json out/
  cd src
  python3 input_generation.py #Produces out/nft_witness.txt  
  cd circuit
  zokrates compile -i nft.code --light #Produces out binary file
  zokrates compute-witness -a $(cat ../out/nft_witness.txt) #Produces witness binary file
  zokrates setup #Generates proving and verification keys
  zokrates export-verifier #Produces verifier.sol solidity smart contract
  zokrates generate-proof #Produces proof.json file that serves as input to verifier contract
  ```

## Warning
This is an proof-of-concept prototype. This implementation is not ready for production use. It does not yet contain all the features, careful code review, tests and integration that are needed for a deployment. Future changes to the cryptographic protocol and data formats are likely.
