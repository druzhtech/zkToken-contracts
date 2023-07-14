// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

import "./Pairing.sol";

contract MintVerifier {
    using Pairing for *;
    struct VerifyingKey {
        Pairing.G1Point alfa1;
        Pairing.G2Point beta2;
        Pairing.G2Point gamma2;
        Pairing.G2Point delta2;
        Pairing.G1Point[] IC;
    }
    struct Proof {
        Pairing.G1Point A;
        Pairing.G2Point B;
        Pairing.G1Point C;
    }

    function verifyingKey() internal pure returns (VerifyingKey memory vk) {
        vk.alfa1 = Pairing.G1Point(
            10432045470451421579879973820133815979864873298294317099763126227636707198579,
            18895585206280597600729050354993084193787752903508466794982367046184826080388
        );

        vk.beta2 = Pairing.G2Point(
            [
                7311468341355222556488540459862254008581463059149240168082973012359986691797,
                7429109455925614084827375328477843628102247761269965296917187444805793475151
            ],
            [
                16237915279756860293314597021872505413863751293504843477362441167573248611257,
                16427295003818324778672305952995939863894401899027750539190732084046703275132
            ]
        );
        vk.gamma2 = Pairing.G2Point(
            [
                11559732032986387107991004021392285783925812861821192530917403151452391805634,
                10857046999023057135944570762232829481370756359578518086990519993285655852781
            ],
            [
                4082367875863433681332203403145435568316851327593401208105741076214120093531,
                8495653923123431417604973247489272438418190587263600148770280649306958101930
            ]
        );
        vk.delta2 = Pairing.G2Point(
            [
                16030320196835364601842821324429324548680340443029192437767166142037544662131,
                8053759278825516489541389556122163920127005928707473515774368238261755392366
            ],
            [
                12621883896874584953151049263338183000612862395021862904000933241480404008496,
                1020155011796463536056855769139212105179526900303006506565478407745346194817
            ]
        );
        vk.IC = new Pairing.G1Point[](2);

        vk.IC[0] = Pairing.G1Point(
            18633222904448448001499579985960016138654911492276280874896049410209970598415,
            21693982138939126746112047034303885974782292631755951282830192533042063321436
        );

        vk.IC[1] = Pairing.G1Point(
            15885508167295328387726735928464015836403376129367976074791827841063647204418,
            229159419594447156521713879107088657958142946304962547198049925253301665318
        );
    }

    function verify(
        uint[] memory input,
        Proof memory proof
    ) internal view returns (uint) {
        uint256 snark_scalar_field = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
        VerifyingKey memory vk = verifyingKey();
        require(input.length + 1 == vk.IC.length, "verifier-bad-input");
        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint i = 0; i < input.length; i++) {
            require(
                input[i] < snark_scalar_field,
                "verifier-gte-snark-scalar-field"
            );
            vk_x = Pairing.addition(
                vk_x,
                Pairing.scalar_mul(vk.IC[i + 1], input[i])
            );
        }
        vk_x = Pairing.addition(vk_x, vk.IC[0]);
        if (
            !Pairing.pairingProd4(
                Pairing.negate(proof.A),
                proof.B,
                vk.alfa1,
                vk.beta2,
                vk_x,
                vk.gamma2,
                proof.C,
                vk.delta2
            )
        ) return 1;
        return 0;
    }

    /// @return r  bool true if proof is valid
    function verifyProof(
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint /*1*/[] memory input
    ) public view returns (bool r) {
        Proof memory proof;
        proof.A = Pairing.G1Point(a[0], a[1]);
        proof.B = Pairing.G2Point([b[0][0], b[0][1]], [b[1][0], b[1][1]]);
        proof.C = Pairing.G1Point(c[0], c[1]);
        uint[] memory inputValues = new uint[](input.length);
        for (uint i = 0; i < input.length; i++) {
            inputValues[i] = input[i];
        }
        if (verify(inputValues, proof) == 0) {
            return true;
        } else {
            return false;
        }
    }
}
