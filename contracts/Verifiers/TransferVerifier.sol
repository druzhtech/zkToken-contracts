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
            19626122892883507972516836034502233180297731137150053347641776099302412304093,
            12285847012957588783978649533695141738585893192648141774030285237145338777478
        );

        vk.beta2 = Pairing.G2Point(
            [13437592324576944125106131145204674830880043039125385913446303960019661913809,
             8422289279257296728320810703675856566160093203534127214113448087847661630214],
            [11126337896169261202427117821032812632766358222189219139951632875045539665680,
             14186721194275745575672115983135398824401771199199132623347950822758506097183]
        );
        vk.gamma2 = Pairing.G2Point(
            [11559732032986387107991004021392285783925812861821192530917403151452391805634,
             10857046999023057135944570762232829481370756359578518086990519993285655852781],
            [4082367875863433681332203403145435568316851327593401208105741076214120093531,
             8495653923123431417604973247489272438418190587263600148770280649306958101930]
        );
        vk.delta2 = Pairing.G2Point(
            [630922107186405080380462225267525238112308851919319949547429785122079325541,
             15450642158272866111767234245684335272657977058365802605924821517091336037939],
            [3921409170745933014144073454305809812819662441450349420265910051092661318745,
             20311029993741687474309347741991251286965744543822796369109790900514243531261]
        );
        vk.IC = new Pairing.G1Point[](4);
        
        vk.IC[0] = Pairing.G1Point( 
            5385960168668413789651170216318304504933523677836877191814296099033698327957,
            8645867962570582341712562360194977943805780369399584147207424610016085702844
        );                                      
        
        vk.IC[1] = Pairing.G1Point( 
            17084975040739813983535808304237154653897850083865209395319978920926636319601,
            1902074180295074840094916023688870491056445252209305096619399132178565416595
        );                                      
        
        vk.IC[2] = Pairing.G1Point( 
            10969041961214673556564812941283668435753497059972299240060517523418690556332,
            7314839063211004279495750269863037754837452213591702955772780497932748767303
        );                                      
        
        vk.IC[3] = Pairing.G1Point( 
            16494685979989012326077577654614486596868041062039352411847422637075815126763,
            15776172511953464672074089533281027329346260672517334393284956107990334053045
        );                                      
        
    }
    function verify(uint[] memory input, Proof memory proof) internal view returns (uint) {
        uint256 snark_scalar_field = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
        VerifyingKey memory vk = verifyingKey();
        require(input.length + 1 == vk.IC.length,"verifier-bad-input");
        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint i = 0; i < input.length; i++) {
            require(input[i] < snark_scalar_field,"verifier-gte-snark-scalar-field");
            vk_x = Pairing.addition(vk_x, Pairing.scalar_mul(vk.IC[i + 1], input[i]));
        }
        vk_x = Pairing.addition(vk_x, vk.IC[0]);
        if (!Pairing.pairingProd4(
            Pairing.negate(proof.A), proof.B,
            vk.alfa1, vk.beta2,
            vk_x, vk.gamma2,
            proof.C, vk.delta2
        )) return 1;
        return 0;
    }
    /// @return r  bool true if proof is valid
    function verifyProof(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint/*3*/[] memory input
        ) public view returns (bool r) {
        Proof memory proof;
        proof.A = Pairing.G1Point(a[0], a[1]);
        proof.B = Pairing.G2Point([b[0][0], b[0][1]], [b[1][0], b[1][1]]);
        proof.C = Pairing.G1Point(c[0], c[1]);
        uint[] memory inputValues = new uint[](input.length);
        for(uint i = 0; i < input.length; i++){
            inputValues[i] = input[i];
        }
        if (verify(inputValues, proof) == 0) {
            return true;
        } else {
            return false;
        }
    }
}
