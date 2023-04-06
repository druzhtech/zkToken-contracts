require('@nomicfoundation/hardhat-toolbox')
require('dotenv').config()

/** @type import('hardhat/config').HardhatUserConfig */

const privateKey =
  process.env.PRIVATE_KEY !== undefined
    ? process.env.PRIVATE_KEY
    : 'ac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80'
const endpoint =
  process.env.URL !== undefined ? process.env.URL : 'http://127.0.0.1:8545'
const etherscanKey = process.env.ETHERSCAN_KEY

module.exports = {
  solidity: '0.8.18',
  networks: {
    sepolia: {
      url: endpoint,
      accounts: [`0x${privateKey}`],
    },
  },
  etherscan: {
    apiKey: {
      sepolia: etherscanKey,
    },
  },
}
