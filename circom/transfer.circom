pragma circom 2.1.3;

include "binpower.circom";

template Main() {
    signal input encryptedBalance;
	signal input encryptedValue;
	signal input newEncryptedBalance;
	signal input value;

	// PubKey = g, rand r, n
	signal input senderPubKey[3];
	signal input reciverPubKey[3];
	// l mu n
	signal input senderPrivKey[3];

	// checking that the sender knows his balance and it is correct, you need to know r

	// deciphering the old balance 
	component pow1 = Binpower();
	

	pow1.b <== encryptedBalance;
	pow1.e <== senderPrivKey[0];
	pow1.modulo <== senderPrivKey[2] * senderPrivKey[2];

	signal senderBalance <-- (pow1.out - 1) / senderPrivKey[2] * senderPrivKey[1] % senderPrivKey[2];

	// checking that the current balance is greater than the payment amount
	assert(senderBalance >= value);

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

