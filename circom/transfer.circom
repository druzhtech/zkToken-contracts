pragma circom 2.1.5;

include "binpower.circom";

template Main() {
	signal input encryptedSenderBalance;
	signal input encryptedSenderValue;
	signal input encryptedReceiverValue;
	signal input value;

	// public key: g, rand r, n
	signal input senderPubKey[3];
	signal input receiverPubKey[3];
	
	// private key: l, mu, n
	signal input senderPrivKey[3];
	
	// value cannot be negative
	assert(value > 0);
	
	// deciphering the current sender balance 
	component pow1 = Binpower();
	
	pow1.b <== encryptedSenderBalance;
	pow1.e <== senderPrivKey[0];
	pow1.modulo <== senderPrivKey[2] * senderPrivKey[2];

	signal senderBalance <-- (pow1.out - 1) / senderPrivKey[2] * senderPrivKey[1] % senderPrivKey[2];

	// checking that the current sender balance is greater than the payment amount
	assert(senderBalance >= value);
	
	// checking the value encryption for the receiver
	component pow3 = Binpower();
	component pow4 = Binpower();

	pow3.b <== receiverPubKey[0];
	pow3.e <== value;
	pow3.modulo <== receiverPubKey[2] * receiverPubKey[2];

	pow4.b <== receiverPubKey[1];
	pow4.e <== receiverPubKey[2];
	pow4.modulo <== receiverPubKey[2] * receiverPubKey[2];

	signal enReceiverValue <-- (pow3.out * pow4.out) % (receiverPubKey[2] * receiverPubKey[2]);
	encryptedReceiverValue === enReceiverValue;
	
	// checking the value encryption for the sender
	component pow5 = Binpower();
	component pow6 = Binpower();

	pow5.b <== senderPubKey[0];
	pow5.e <== senderPubKey[2] - value;
	pow5.modulo <== senderPubKey[2] * senderPubKey[2];

	pow6.b <== senderPubKey[1];
	pow6.e <== senderPubKey[2];
	pow6.modulo <== senderPubKey[2] * senderPubKey[2];

	signal enSenderValue <-- (pow5.out * pow6.out) % (senderPubKey[2] * senderPubKey[2]);
	encryptedSenderValue === enSenderValue;
}

// public data
component main {
		public [encryptedSenderBalance,		// in storage
				encryptedSenderValue, 		// sender calculates + send to transfer function
				encryptedReceiverValue]		// sender calculates + send to transfer function	
				} = Main();
