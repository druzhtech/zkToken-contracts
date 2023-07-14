pragma circom 2.1.5;

include "binpower.circom";

template Main() {
	signal input encryptedValue;
	signal input value;
	// public key: g, rand r, n
	signal input receiverPubKey[3];
	
	// value cannot be negative
	assert(value > 0);

	// payment encryption check
	component pow1 = Binpower();
	component pow2 = Binpower();

	pow1.b <== receiverPubKey[0];
	pow1.e <== value;
	pow1.modulo <== receiverPubKey[2] * receiverPubKey[2];

	pow2.b <== receiverPubKey[1];
	pow2.e <== receiverPubKey[2];
	pow2.modulo <== receiverPubKey[2] * receiverPubKey[2];

	signal enValue <-- (pow1.out * pow2.out) % (receiverPubKey[2] * receiverPubKey[2]);
	encryptedValue === enValue;
}

// public data
component main {
		public [encryptedValue]		// calculates + send to mint function
				} = Main();


