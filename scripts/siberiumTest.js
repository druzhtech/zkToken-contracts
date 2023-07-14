const ethers = require('ethers')
const paillierBigint = require('paillier-bigint')
require('dotenv').config()

const privateKey = process.env.PRIVATE_KEY

const adresses = require('./adresses.json')
const abiZKToken = require('../abi/contracts/zkToken.sol/zkToken.json')
const abiRegistrationVerifier = require('../abi/contracts/Verifiers/RegistrationVerifier.sol/RegistrationVerifier.json')

const registrationPublicA = require('../test/registrationProof/publicA.json')
const registrationProofA = require('../test/registrationProof/proofA.json')

const keys = require('../test/inputs/keysA.json')

async function main() {
  /*
  const publicKey = new paillierBigint.PublicKey(BigInt(keys.n), BigInt(keys.g))
  const privateKey = new paillierBigint.PrivateKey(
    BigInt(keys.lambda),
    BigInt(keys.mu),
    publicKey
  )
*/
  const provider = new ethers.providers.JsonRpcProvider(
    'https://rpc.test.siberium.net'
  )

  const network = await provider.getNetwork()
  console.log('Chain ID:', network.chainId)

  const blockNumber = await provider.getBlockNumber()
  console.log('Current block number:', blockNumber)

  const gasPrice = await provider.getGasPrice()
  console.log('Gas price:', ethers.utils.formatUnits(gasPrice, 'gwei'))

  const wallet = new ethers.Wallet(privateKey, provider)

  const balance = await provider.getBalance(wallet.address)
  console.log('Current balance:', ethers.utils.formatEther(balance))

  const nonce = await provider.getTransactionCount(wallet.address)
  console.log('Current nonce:', nonce)

  const zkToken = new ethers.Contract(adresses.ZKTOKEN, abiZKToken, wallet)
  const name = await zkToken.name()
  console.log('Name:', name)
  const symbol = await zkToken.symbol()
  console.log('Symbol:', symbol)

  const RegistrationVerifier = new ethers.Contract(
    adresses.REGISTRATIONVERIFIER,
    abiRegistrationVerifier,
    wallet
  )

  const regVerifier = await RegistrationVerifier.verifyProof(
    [registrationProofA.pi_a[0], registrationProofA.pi_a[1]],
    [
      [registrationProofA.pi_b[0][1], registrationProofA.pi_b[0][0]],
      [registrationProofA.pi_b[1][1], registrationProofA.pi_b[1][0]],
    ],
    [registrationProofA.pi_c[0], registrationProofA.pi_c[1]],
    registrationPublicA
  )
  console.log('Test registration verifier:', regVerifier)

  /* 
  const registration = await zkToken.registration(
    [registrationProofA.pi_a[0], registrationProofA.pi_a[1]],
    [
      [registrationProofA.pi_b[0][1], registrationProofA.pi_b[0][0]],
      [registrationProofA.pi_b[1][1], registrationProofA.pi_b[1][0]],
    ],
    [registrationProofA.pi_c[0], registrationProofA.pi_c[1]],
    registrationPublicA
  )

  const receiptRegistration = await registration.wait()

  // 380021
  console.log(
    'Gas used by registration:',
    '\x1b[33m',
    receiptRegistration.gasUsed.toString(),
    '\x1b[0m'
  )
*/

  const ZKTbalance = await zkToken.balanceOf(wallet.address)
  console.log('ZKTbalance after registration', ZKTbalance.toString())

  const PubKey = await zkToken.getPubKey(wallet.address)
  console.log('PubKey (g, n, n^2)', PubKey.toString())
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
