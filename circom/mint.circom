pragma circom 2.1.3;

include "binpower.circom";

template Main() {
	signal input encryptedValue;
	signal input value;
	// PubKey = g, r, n
	signal input reciverPubKey[3];

	// payment encryption check
	component pow1 = Binpower();
	component pow2 = Binpower();

	pow1.b <== reciverPubKey[0];
	pow1.e <== value;
	pow1.modulo <== reciverPubKey[2] * reciverPubKey[2];

	pow2.b <== reciverPubKey[1];
	pow2.e <== reciverPubKey[2];
	pow2.modulo <== reciverPubKey[2] * reciverPubKey[2];

	signal enValue <-- (pow1.out * pow2.out) % (reciverPubKey[2] * reciverPubKey[2]);
	encryptedValue === enValue;
}

// public data
component main {
		public [encryptedValue,		// sender calculates + send to mint function
				reciverPubKey] 		// in storage + rand r
				} = Main();

