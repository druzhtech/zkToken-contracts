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
            18435331054658905156028151622621429547633643027770148323266342041107469941626,
            5181013217588440769799352712709805019335038891957200603275759379621557684163
        );

        vk.beta2 = Pairing.G2Point(
            [
                13390106787626386918720262484380522767975118294767584124887482342148189232600,
                20310660278782810362556982676468349619070619219388616399439010843127171516493
            ],
            [
                18083325792550037778438631904444738896302702329809664951708140422712418473417,
                8476151171263752989506734225865478552392027648194375453996829105924466356935
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
                142416673849401254402748452979823663471478580876784416425214050417693986747,
                11958586454748695991890422770199795710217115389259356038826472393550032275261
            ],
            [
                17986271036091008763587876203490380784832594015906597198663216615488489223271,
                18591372146664916447889071510579841741978528409037940385548804802343149721984
            ]
        );
        vk.IC = new Pairing.G1Point[](7);

        vk.IC[0] = Pairing.G1Point(
            18177924794416959771132483319201148788297987941244499178103629971122051433219,
            5593627083436596548011916752291891250556682873173388608951083396958238222122
        );

        vk.IC[1] = Pairing.G1Point(
            8882039754436682069287296574821356823121877968047468779434589355402269466138,
            14605785187549280106939535127479380449031930942390109612737740948094482930043
        );

        vk.IC[2] = Pairing.G1Point(
            12439363349517301925680782160993460137776759481312527085234352292161061872272,
            6580492170978295038840042617988054325281904280079216482412848382746570078011
        );

        vk.IC[3] = Pairing.G1Point(
            2852147356103909211256478664899024736644994485109350466733856338413436198756,
            6435521357120710208467677331020662956640738068144360293414311500688312566292
        );

        vk.IC[4] = Pairing.G1Point(
            11819816105122596240257782128011242664419713454915384830975886210331451852990,
            11263197580467853679591680932656693865808459068152495260042635266498645827867
        );

        vk.IC[5] = Pairing.G1Point(
            5249943766849860372173319341417827164885846607430474458705256245964758654190,
            14739211280226076487694367165105870086690742675237280138308964785670578589622
        );

        vk.IC[6] = Pairing.G1Point(
            1744463582453892316705414735523656476301311422058913616539323656575059846781,
            19256968243243425079672419657695480429317185515175651141076523563374753779919
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
        uint /*6*/[] memory input
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
