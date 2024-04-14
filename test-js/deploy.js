import { InMemorySigner } from '@taquito/signer';
import { TezosToolkit } from '@taquito/taquito';
import { readFileSync } from 'fs';
import dotenv from 'dotenv';
import test from 'node:test';


dotenv.config();


const Tezos = new TezosToolkit(process.env.RPC_URL || 'http://localhost:20000');
Tezos.setProvider({
  signer: new InMemorySigner(process.env.PRIVATE_KEY || ''),
});


const tokenContractCode = JSON.parse(readFileSync('ProjetTezos-exe6/src/token.mligo', 'utf8'));
const vestingContractCode = JSON.parse(readFileSync('/ProjetTezos-exe6/src/vesting_contract.mligo', 'utf8'));


const tokenInitialStorage = {
  admin: process.env.ADMIN_ADDRESS || '',
    total_supply: 1000000,
    ledger: {
        [process.env.ADMIN_ADDRESS || '']: 1000000,
    },
};


const vestingInitialStorage = {
  admin: process.env.ADMIN_ADDRESS || '',
    token_info: {
        fa2_address: '',
        token_id: 0,
    },
};

// function to deploy the token contract
async function deployTokenContract() {
  try {
    const op = await Tezos.contract.originate({
      code: tokenContractCode,
      storage: tokenInitialStorage,
    });
    await op.confirmation();
    console.log('Contrato de token desplegado en: ', op.contractAddress);
    return op.contractAddress;
  } catch (error) {
    console.error('Error al desplegar el contrato de token: ', error);
  }
}


async function deployVestingContract(tokenContractAddress) {
  try {
    vestingInitialStorage.token_info.fa2_address = tokenContractAddress; 
    const op = await Tezos.contract.originate({
      code: vestingContractCode,
      storage: vestingInitialStorage,
    });
    await op.confirmation();
    console.log('Contrato de vesting desplegado en: ', op.contractAddress);
    return op.contractAddress;
  } catch (error) {
    console.error('Error al desplegar el contrato de vesting: ', error);
  }
}


async function runTests() {
  const tokenContract = await Tezos.contract.at(tokenContractAddress);
    const vestingContract = await Tezos.contract.at(vestingContractAddress);

    test('Test 1: Test de transferencia de tokens', async () => {
      function sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
      }
    });
}

// Deploy both contracts and run tests
(async () => {
  const tokenContractAddress = await deployTokenContract();
  if (tokenContractAddress) {
    const vestingContractAddress = await deployVestingContract(tokenContractAddress);
    if (vestingContractAddress) {
      await runTests(); 
    }
  }
})();
