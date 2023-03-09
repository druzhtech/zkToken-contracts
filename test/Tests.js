const { expect } = require('chai')
const { ethers } = require('hardhat')

const registrationProofA = require('./RegistrationProof/proofA.json')
const registrationPublicA = require('./RegistrationProof/publicA.json')
const registrationInputA = require('./RegistrationProof/inputA.json')

const registrationProofB = require('./RegistrationProof/proofB.json')
const registrationPublicB = require('./RegistrationProof/publicB.json')
const registrationInputB = require('./RegistrationProof/inputB.json')

const mintProof = require('./MintProof/proof.json')
const mintPublic = require('./MintProof/public.json')
const mintInput = require('./MintProof/input.json')

const transferProofA = require('./TransferProof/proofA.json')
const transferPublicA = require('./TransferProof/publicA.json')
const transferInputA = require('./TransferProof/inputA.json')

describe('zkToken', function () {
  let zkToken,
    registrationVerifier,
    transferVerifier,
    mintVerifier,
    clientA,
    clientB

  const fee = ethers.utils.parseUnits('0.001', 'ether')

  before(async function () {
    ;[clientA, clientB] = await ethers.getSigners()

    const RegistrationVerifier = await hre.ethers.getContractFactory(
      'RegistrationVerifier'
    )
    registrationVerifier = await RegistrationVerifier.deploy()
    await registrationVerifier.deployed()

    const TransferVerifier = await hre.ethers.getContractFactory(
      'TransferVerifier'
    )
    transferVerifier = await TransferVerifier.deploy()
    await transferVerifier.deployed()

    const MintVerifier = await hre.ethers.getContractFactory('MintVerifier')
    mintVerifier = await MintVerifier.deploy()
    await mintVerifier.deployed()

    const ZKToken = await hre.ethers.getContractFactory('zkToken')
    zkToken = await ZKToken.deploy(
      transferVerifier.address,
      registrationVerifier.address,
      mintVerifier.address
    )
    await zkToken.deployed()
  })

  it('name', async function () {
    expect(await zkToken.name()).to.eq('zkToken')
  })

  it('symbol', async function () {
    expect(await zkToken.symbol()).to.eq('ZKT')
  })

  it('verifyRegistrationProof', async function () {
    await registrationVerifier.verifyProof(
      [registrationProofA.pi_a[0], registrationProofA.pi_a[1]],
      [
        [registrationProofA.pi_b[0][1], registrationProofA.pi_b[0][0]],
        [registrationProofA.pi_b[1][1], registrationProofA.pi_b[1][0]],
      ],
      [registrationProofA.pi_c[0], registrationProofA.pi_c[1]],
      registrationPublicA
    )
  })

  it('verifyMintProof', async function () {
    await mintVerifier.verifyProof(
      [mintProof.pi_a[0], mintProof.pi_a[1]],
      [
        [mintProof.pi_b[0][1], mintProof.pi_b[0][0]],
        [mintProof.pi_b[1][1], mintProof.pi_b[1][0]],
      ],
      [mintProof.pi_c[0], mintProof.pi_c[1]],
      mintPublic
    )
  })

  it('verifyTransferProof', async function () {
    await transferVerifier.verifyProof(
      [transferProofA.pi_a[0], transferProofA.pi_a[1]],
      [
        [transferProofA.pi_b[0][1], transferProofA.pi_b[0][0]],
        [transferProofA.pi_b[1][1], transferProofA.pi_b[1][0]],
      ],
      [transferProofA.pi_c[0], transferProofA.pi_c[1]],
      transferPublicA
    )
  })

  it('registration A', async function () {
    await zkToken.connect(clientA).registration(
      [registrationProofA.pi_a[0], registrationProofA.pi_a[1]],
      [
        [registrationProofA.pi_b[0][1], registrationProofA.pi_b[0][0]],
        [registrationProofA.pi_b[1][1], registrationProofA.pi_b[1][0]],
      ],
      [registrationProofA.pi_c[0], registrationProofA.pi_c[1]],
      registrationPublicA
    )

    expect(await zkToken.balanceOf(clientA.address)).to.eq(
      registrationInputA.encryptedBalance
    )
  })

  it('registration B', async function () {
    await zkToken.connect(clientB).registration(
      [registrationProofB.pi_a[0], registrationProofB.pi_a[1]],
      [
        [registrationProofB.pi_b[0][1], registrationProofB.pi_b[0][0]],
        [registrationProofB.pi_b[1][1], registrationProofB.pi_b[1][0]],
      ],
      [registrationProofB.pi_c[0], registrationProofB.pi_c[1]],
      registrationPublicB
    )

    expect(await zkToken.balanceOf(clientB.address)).to.eq(
      registrationInputB.encryptedBalance
    )
  })

  it('mint A', async function () {
    await zkToken.mint(
      clientA.address,
      [mintProof.pi_a[0], mintProof.pi_a[1]],
      [
        [mintProof.pi_b[0][1], mintProof.pi_b[0][0]],
        [mintProof.pi_b[1][1], mintProof.pi_b[1][0]],
      ],
      [mintProof.pi_c[0], mintProof.pi_c[1]],
      mintPublic
    )

    expect(
      decryption(
        await zkToken.balanceOf(clientA.address),
        46783589n,
        11692464n,
        39229921n
      )
    ).to.eq(mintInput.value)
  })

  it('Revert self-transfer', async function () {
    await expect(
      zkToken.connect(clientB).transfer(
        clientB.address,
        [transferProofA.pi_a[0], transferProofA.pi_a[1]],
        [
          [transferProofA.pi_b[0][1], transferProofA.pi_b[0][0]],
          [transferProofA.pi_b[1][1], transferProofA.pi_b[1][0]],
        ],
        [transferProofA.pi_c[0], transferProofA.pi_c[1]],
        transferPublicA
      )
    ).to.be.revertedWith('you cannot send money to yourself')
  })

  it('Transfer A to B', async function () {
    await zkToken.connect(clientA).transfer(
      clientB.address,
      [transferProofA.pi_a[0], transferProofA.pi_a[1]],
      [
        [transferProofA.pi_b[0][1], transferProofA.pi_b[0][0]],
        [transferProofA.pi_b[1][1], transferProofA.pi_b[1][0]],
      ],
      [transferProofA.pi_c[0], transferProofA.pi_c[1]],
      transferPublicA
    )

    expect(await zkToken.balanceOf(clientA.address)).to.eq(
      transferInputA.newEncryptedBalance
    )

    expect(
      decryption(
        await zkToken.balanceOf(clientB.address),
        17942993n,
        8967090n,
        15889415n
      )
    ).to.eq(transferInputA.value)
  })

  it('revert error registration', async function () {
    await expect(
      zkToken.connect(clientA).registration(
        [transferProofA.pi_a[0], transferProofA.pi_a[1]],
        [
          [transferProofA.pi_b[0][1], transferProofA.pi_b[0][0]],
          [transferProofA.pi_b[1][1], transferProofA.pi_b[1][0]],
        ],
        [transferProofA.pi_c[0], transferProofA.pi_c[1]],
        registrationPublicA
      )
    )
      .to.be.revertedWithCustomError(zkToken, 'WrongProof')
      .withArgs('Wrong proof')
  })
})

// exponentiation modulo
function pow(base, exp, mod) {
  let res = 1n
  while (exp != 0n) {
    if ((exp & 1n) != 0n) {
      res = BigInt(res * base) % mod
    }
    base = BigInt(base * base) % mod
    exp >>= 1n
  }
  return res
}

// Paye cryptosystem
function div(val, by) {
  return BigInt((val - (val % by)) / by)
}

function L(u, n) {
  return div(BigInt(u) - 1n, BigInt(n))
}

function encryption(g, m, r, n) {
  return BigInt(BigInt(pow(g, m, n * n) * pow(r, n, n * n)) % BigInt(n * n))
}

function decryption(c, n, l, mu) {
  return BigInt(
    BigInt(
      L(pow(BigInt(c), BigInt(l), BigInt(n * n)), BigInt(n)) * BigInt(mu)
    ) % BigInt(n)
  )
}
