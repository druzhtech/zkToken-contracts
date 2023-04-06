pragma circom 2.1.3;

include "binpower.circom";

template Main() {
	signal input encryptedValue;
	signal input value;
	// PubKey = g, r, n
	signal input reciverPubKey[3];

	signal input encryptedReciverBalance;
	signal input newEncryptedReciverBalance;

	// value cannot be negative
	assert(value > 0);

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

	// verification of the correctly calculated new balance of the recipient
	signal enNewEncryptedReciverBalance <-- (encryptedReciverBalance * encryptedValue) % (reciverPubKey[2] * reciverPubKey[2]);

	newEncryptedReciverBalance === enNewEncryptedReciverBalance;
}

// public data
component main {
		public [encryptedValue,				// sender calculates
				reciverPubKey,				// in storage + rand r
				encryptedReciverBalance,	// in storage
				newEncryptedReciverBalance] // sender calculates
				} = Main();

