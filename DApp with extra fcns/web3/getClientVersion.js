const Web3 = require('web3');

const web3 = new Web3(new Web3.providers.HttpProvider('https://rpc.ankr.com/eth_sepolia'));

async function getClientVersion() {
  try {
    const clientVersion = await web3.eth.getNodeInfo();
    console.log('Client Version:', clientVersion);
  } catch (error) {
    console.error('Error fetching client version:', error);
  }
}

getClientVersion();
