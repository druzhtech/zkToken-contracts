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
            658275524437578894372841189209037423577036971747381770345657322142692220031,
            7873681085224822191729703105888047693523694272471970858969765188471918464189
        );

        vk.beta2 = Pairing.G2Point(
            [
                12750562917231245402846979415565929918071958341384259433516029031838306381113,
                21234610922514140634100089837049853140138345570179582271126693222353895381134
            ],
            [
                4248983391522076495852209280475944205172927368890810549512632254706552494658,
                10903404811555455779237095525613382918187114381444675071232859226920555016759
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
                3235641650340381618373154577313572939199790475286763541428602182439582429362,
                7827052253475652106126951683371549195617810931294360841956926083432191639419
            ],
            [
                16006903698742997139684820762950148338142032738740898435729452144306910468898,
                10479686760332312112357341203820154923788687651792286641938586792809918444923
            ]
        );
        vk.IC = new Pairing.G1Point[](5);

        vk.IC[0] = Pairing.G1Point(
            18388380486650143029554996329182205133484264041283305960593518493686756434879,
            8948637648877812357337098493597374591756769685574095896265815857928166564233
        );

        vk.IC[1] = Pairing.G1Point(
            15740192961247594433451502802530164866990423131920200894845047814694726451973,
            20638984106405937260380948440656021356529044153068864516007738760858709246309
        );

        vk.IC[2] = Pairing.G1Point(
            3566913058731516369141782133365475845072409554745480692683825246729026800834,
            15513637738994780738340420788107853013696058024574562909505008071014805605674
        );

        vk.IC[3] = Pairing.G1Point(
            3884881094617859141030685029513247910260951697940323592434035471440625553583,
            7449605940719970465470875829785296376144387902469370866010087244695472081758
        );

        vk.IC[4] = Pairing.G1Point(
            7222734934401894549996382599312962764829487648316743324277458876506271197378,
            13244034329457953008229020137939417142096755790130870040149886476021405810183
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
        uint /*4*/[] memory input
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
