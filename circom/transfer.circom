pragma circom 2.1.3;

include "binpower.circom";

template Main() {
    signal input encryptedBalance;
	signal input encryptedValue;
	signal input newEncryptedBalance;
    signal input senderBalance;
	signal input value;
	// old r
	signal input r;
	// PubKey = g, r, n
	signal input senderPubKey[3];
	signal input reciverPubKey[3];

	// checking that the current balance is greater than the payment amount
	assert(senderBalance >= value);

	// checking that the sender knows his balance and it is correct, you need to know r
	component pow1 = Binpower();
	component pow2 = Binpower();

	pow1.b <== senderPubKey[0];
	pow1.e <== senderBalance;
	pow1.modulo <== senderPubKey[2] * senderPubKey[2];

	pow2.b <== r;
	pow2.e <== senderPubKey[2];
	pow2.modulo <== senderPubKey[2] * senderPubKey[2];

	signal enBalance <-- (pow1.out * pow2.out) % (senderPubKey[2] * senderPubKey[2]);
	encryptedBalance === enBalance;

	// payment encryption check
	component pow3 = Binpower();
	component pow4 = Binpower();

	pow3.b <== reciverPubKey[0];
	pow3.e <== value;
	pow3.modulo <== reciverPubKey[2] * reciverPubKey[2];

	pow4.b <== reciverPubKey[1];
	pow4.e <== reciverPubKey[2];
	pow4.modulo <== reciverPubKey[2] * reciverPubKey[2];

	signal enValue <-- (pow3.out * pow4.out) % (reciverPubKey[2] * reciverPubKey[2]);
	encryptedValue === enValue;

	// checking the correctness of the new balance
	component pow5 = Binpower();
	component pow6 = Binpower();

	pow5.b <== senderPubKey[0];
	pow5.e <== senderBalance - value;
	pow5.modulo <== senderPubKey[2] * senderPubKey[2];

	pow6.b <== senderPubKey[1];
	pow6.e <== senderPubKey[2];
	pow6.modulo <== senderPubKey[2] * senderPubKey[2];

	signal enNewBalance <-- (pow5.out * pow6.out) % (senderPubKey[2] * senderPubKey[2]);
	newEncryptedBalance === enNewBalance;
}

// public data
component main {
		public [encryptedBalance, 	// in storage
				encryptedValue,		// sender calculates + send to transfer function
				newEncryptedBalance,// sender calculates + send to storage
				reciverPubKey, 		// in storage + rand r
				senderPubKey]		// in storage + rand r
				} = Main();

