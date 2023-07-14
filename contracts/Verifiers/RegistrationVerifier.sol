// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

import "./Pairing.sol";

contract RegistrationVerifier {
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
            10043268065398921453394175356062822101149025070707508278325823398226829454857,
            4531186109279442146605026610030233916045824473613781122264277368961780107064
        );

        vk.beta2 = Pairing.G2Point(
            [
                2382507348515846210932329411458158735258830495069663771909315437132429284033,
                15757383325999722758863607582528221902538869483658417846331108995771251074142
            ],
            [
                1977491062475878677507719707817449281773132769682539964970263884579231012777,
                5245887630139133864319090101382808187449263904679131491459962250345302632137
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
                1633411777362199934357396086505550179401565788478601823544238986831850349125,
                15358733474756795843589496362269912769874225910119940840301636246316819130344
            ],
            [
                3428190046298973550849088641866997324377874673718660871430113688599115577057,
                1825142602903579042975446744577467405571359437766884632575643637428261025019
            ]
        );
        vk.IC = new Pairing.G1Point[](5);

        vk.IC[0] = Pairing.G1Point(
            16927891270727401158723276493287324509892862489180822710308745558528569935500,
            6502425220979195030802951801592262992704341358008177985498677035190307724362
        );

        vk.IC[1] = Pairing.G1Point(
            1451589592952605916866994192081317750871537906675725319021226648162516003070,
            21300968598723575729057645172259510065440904072748131443513676028633017270520
        );

        vk.IC[2] = Pairing.G1Point(
            15589214995968401151117583229946886338410998795187583583263358698060292138660,
            18190173347061333173147886890332220319837546251097867586167770758786144346200
        );

        vk.IC[3] = Pairing.G1Point(
            1023799639395307774740052323930810073366035297655560491760533956885382175634,
            17405265461784551455955167461876640333090009841668539491663324211901928145298
        );

        vk.IC[4] = Pairing.G1Point(
            12518727461090809003703943313086567075114365447955001674530678960760606599488,
            11475348387750655621343549133402054966741388606960287391311712238208710958607
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
