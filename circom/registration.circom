pragma circom 2.1.3;

include "binpower.circom";

template Main() {
    signal input encryptedBalance;
	signal input balance;
	// PubKey = g, r, n
	signal input pubKey[3];

	// проверка того, что баланс равен нулю
	balance === 0;
	
	// checking that the sender knows his balance and it is correct, you need to know r
	component pow1 = Binpower();
	component pow2 = Binpower();

	pow1.b <== pubKey[0];
	pow1.e <== balance;
	pow1.modulo <== pubKey[2] * pubKey[2];

	pow2.b <== pubKey[1];
	pow2.e <== pubKey[2];
	pow2.modulo <== pubKey[2] * pubKey[2];

	signal enBalance <-- (pow1.out * pow2.out) % (pubKey[2] * pubKey[2]);
	encryptedBalance === enBalance;
}

// public data
component main {
		public [encryptedBalance, 	// encrypted 0
				pubKey]				// in storage + rand r
				} = Main();

