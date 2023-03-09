// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

import "./Pairing.sol";

contract TransferVerifier {
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
            4255362176294476774819134982980130246342756077295056526075712399905477859196,
            9758977250753345492941007363902747073330106699553208418047757032392441594955
        );

        vk.beta2 = Pairing.G2Point(
            [
                15697727910888621647610620454639950915963013220507469158887835663702061377932,
                16151096633763192798816375582209076807897779864525309395565827199805585961844
            ],
            [
                4314804207092265679371460118637423972847571023607772513332433962660948371527,
                943264494110270574569792207732721647853354021077666692899370624064765140932
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
                8401538997923026214885109529811089134422147200610249310792847740664355405533,
                2022746200216970617979884134389674721962438461512734844711710403735038873945
            ],
            [
                4601866663279043950003367202038539081777748303818973167893237805237300986980,
                21432027317437428333650975796433756808699636974850254389343466228952364549556
            ]
        );
        vk.IC = new Pairing.G1Point[](10);

        vk.IC[0] = Pairing.G1Point(
            3237465831969966460891719534517287796343828192598866204234489642054427504322,
            16535591117087120011642050233043736593265419467931296471693517382229643170723
        );

        vk.IC[1] = Pairing.G1Point(
            5943991684186284193040748563002226109557198283546307647736142679197776887639,
            19949453230157521168463047785650126149695861391083779400258879166485610968840
        );

        vk.IC[2] = Pairing.G1Point(
            1649091787000614530686086578737582397637368779234531674448045008608230387488,
            17522747240576545070042894979670565873545883296945548947177235725419548035026
        );

        vk.IC[3] = Pairing.G1Point(
            3628901675421788416293102947185149122588843713683469202061332304121895794532,
            12108524365921716448873728781675400805488092234736538644320721833251373792600
        );

        vk.IC[4] = Pairing.G1Point(
            16143891623751888324466295166434076580953864551865391413214241106056031916295,
            15825749489660717552670254145222820989505627727225227205206050663902903380355
        );

        vk.IC[5] = Pairing.G1Point(
            3717642141666185311140068997786759420023276920138656328745612301892416081302,
            21723052432711953983419100298092538350054152652243793080042096763735498644127
        );

        vk.IC[6] = Pairing.G1Point(
            16409750903119211803894863023182147181744315356658713020817472132811594945707,
            11268863200721211427365202832120314490962497623781750762483887159466631481969
        );

        vk.IC[7] = Pairing.G1Point(
            142879797948246559231174253803014985616323097374163568696695976277557953138,
            21861407437788665369469796485138592785175469191469815915134711236047709233973
        );

        vk.IC[8] = Pairing.G1Point(
            6686109544843670407207201167991220417919383161851528333884817184564073225111,
            10441279869422769249719236542923196635044849732049370482924182917006909721897
        );

        vk.IC[9] = Pairing.G1Point(
            11638949995488073760474153989605304537420032816661289847706911824435971065508,
            18618173272763692298496165713482449004318510802945047983501567997134045384646
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
        uint /*9*/[] memory input
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
