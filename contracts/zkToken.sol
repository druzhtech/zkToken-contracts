// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./IVerifier.sol";

contract zkToken {
    string public name = "zkToken";
    string public symbol = "ZKT";
    uint256 public decimals = 0;

    IVerifier private transferVerifierAddr;
    IVerifier private registrationVerifierAddr;
    IVerifier private mintVerifierAddr;

    struct Key {
        uint256 g;
        uint256 n;
    }

    struct User {
        uint256 encryptedBalance;
        Key key;
    }

    mapping(address => User) private users;

    event Registration(address indexed _who);
    event Mint(address indexed _to);
    event Transfer(address indexed _to);

    error WrongProof(string _error);

    /* name, symbol, decimals */
    constructor(
        address _transferVerifieqAddr,
        address _registrationVerifierAddr,
        address _mintVerifierAddr
    ) {
        transferVerifierAddr = IVerifier(_transferVerifieqAddr);
        registrationVerifierAddr = IVerifier(_registrationVerifierAddr);
        mintVerifierAddr = IVerifier(_mintVerifierAddr);
    }

    function balanceOf(address _to) external view returns (uint256) {
        return users[_to].encryptedBalance;
    }

    /* onlyFee */
    function registration(
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint /*4*/[] memory input
    ) external payable /* onlyFee */ {
        require(input[0] >= 0, "wrong balance value");
        // input = balance, key.g, r, key.n
        require(input[1] >= 0 && input[3] >= 0, "invalid key value");

        bool registrationProofIsCorrect = registrationVerifierAddr.verifyProof(
            a,
            b,
            c,
            input
        );

        if (registrationProofIsCorrect) {
            users[msg.sender].encryptedBalance = input[0];
            users[msg.sender].key.g = input[1];
            users[msg.sender].key.n = input[3];
            emit Registration(msg.sender);
        } else revert WrongProof("Wrong proof");
    }

    function mint(
        address _to,
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint /*4*/[] memory input
    ) external {
        require(_to != address(0), "zero address");
        bool mintProofIsCorrect = mintVerifierAddr.verifyProof(a, b, c, input);
        if (mintProofIsCorrect) {
            users[_to].encryptedBalance =
                (users[_to].encryptedBalance * input[0]) %
                (users[_to].key.n * users[_to].key.n);
            emit Mint(_to);
        } else revert WrongProof("Wrong proof");
    }

    function transfer(
        address _to,
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint /*9*/[] memory input
    ) external payable /* onlyFee */ {
        require(msg.sender != _to, "you cannot send money to yourself");
        require(_to != address(0), "zero address");
        User storage user = users[_to];
        require(user.encryptedBalance != 0, "user not registered");
        require(user.key.g >= 0 && user.key.n >= 0, "invalid key value");

        bool transferProofIsCorrect = transferVerifierAddr.verifyProof(
            a,
            b,
            c,
            input
        );

        if (transferProofIsCorrect) {
            users[_to].encryptedBalance =
                (users[_to].encryptedBalance * input[1]) %
                (users[_to].key.n * users[_to].key.n);

            users[msg.sender].encryptedBalance = input[2];
            emit Transfer(_to);
        } else revert WrongProof("Wrong proof");
    }

    modifier onlyFee() {
        require(msg.value >= 0.001 ether, "Not enough fee!");
        _;
    }
}
