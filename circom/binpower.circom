pragma circom 2.1.5;

template Binpower() {
	signal input b;
	signal input e;
	signal input modulo;
	
	signal output out;
	
	var res = 1;
	var exp = e;
	var base = b;
    
    while (exp != 0) 
    {
        if ((exp & 1) != 0)
        {
            res = (res * base) % modulo;
        }
        base = (base * base) % modulo;
        exp >>= 1;
    }
    out <-- res;
}