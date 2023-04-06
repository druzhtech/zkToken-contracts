const hre = require('hardhat')

async function main() {
  const RegistrationVerifier = await hre.ethers.getContractFactory(
    'RegistrationVerifier'
  )
  const registrationVerifier = await RegistrationVerifier.deploy()
  await registrationVerifier.deployed()

  console.log('RegistrationVerifier address:', registrationVerifier.address)

  const TransferVerifier = await hre.ethers.getContractFactory(
    'TransferVerifier'
  )
  const transferVerifier = await TransferVerifier.deploy()
  await transferVerifier.deployed()

  console.log('TransferVerifier address:', transferVerifier.address)

  const MintVerifier = await hre.ethers.getContractFactory('MintVerifier')
  const mintVerifier = await MintVerifier.deploy()
  await mintVerifier.deployed()

  console.log('MintVerifier address:', mintVerifier.address)

  const ZKToken = await hre.ethers.getContractFactory('zkToken')
  const zkToken = await ZKToken.deploy(
    transferVerifier.address,
    registrationVerifier.address,
    mintVerifier.address
  )
  await zkToken.deployed()

  console.log('zkToken address:', zkToken.address)
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
