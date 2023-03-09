require('@nomicfoundation/hardhat-toolbox')
require('dotenv').config()

/** @type import('hardhat/config').HardhatUserConfig */

const privateKey = process.env.PRIVATE_KEY
const endpoint = process.env.URL

module.exports = {
  solidity: '0.8.18',
  networks: {
    goerli: {
      url: endpoint,
      accounts: [`0x${privateKey}`],
    },
  },
}
