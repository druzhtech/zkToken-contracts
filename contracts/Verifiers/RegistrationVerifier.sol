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
            5972070596280457898946417523712279582278686486805872283470049379623916848658,
            13737597506884932933518864910133955744028648431870595406380810033602763002498
        );

        vk.beta2 = Pairing.G2Point(
            [
                3412878598632417585788374811394303180295685469296449586972119888119380249338,
                9481669387810924404808377181835963861239807776223032969115322037212674871266
            ],
            [
                1718894593894535692718802079665566683325763108847368328377120398878937043276,
                9725492167935950009755542624943793977886347093680619477741371535430295585294
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
                10893942477209870511995816132034698897844373002742601693378476706866001670372,
                6095789018271508517686224166753284163663091788208033823086395218872455290927
            ],
            [
                1147342958775896529260201262321709527108340287160567753005275597424638336496,
                15093586434118463996253950732665358617087430076055816164047370446725627316633
            ]
        );
        vk.IC = new Pairing.G1Point[](5);

        vk.IC[0] = Pairing.G1Point(
            16123020488101773048519832567214997353896496976993689406515923805790600970784,
            19328129959616131532693494192985940807606253437918388428780117698177679281824
        );

        vk.IC[1] = Pairing.G1Point(
            460906355945031678054781191521766640144580172239118913754897915702920928119,
            768952214644413326607285675418290169834546889577921845783165742305113523056
        );

        vk.IC[2] = Pairing.G1Point(
            12542261422999737865848461491398451167657251504807484455726251599207702316425,
            13539325913236983539956038774925104951000962511587549118810379566256658197198
        );

        vk.IC[3] = Pairing.G1Point(
            5697238529692607226379554405842010340967112934914309890082533055132953846359,
            15675777964967233881892480563171528958344140240849066463759906287801996401615
        );

        vk.IC[4] = Pairing.G1Point(
            13563250474482180363120688750856344042204464256909606742463610037500288411481,
            20338227450747862789186874694975092097533827295949812308730631270143583110370
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
