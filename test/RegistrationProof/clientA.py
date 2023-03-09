import math
import random

def L(u, n):
    return (u - 1)//(n)
    
def encryption(g, m, r, n):
    return pow(g, m, n*n) * pow(r, n, n*n) % (n*n)
    
def decryption(c, n, l, mu):
    return L(pow(c, l, n*n), n) * mu % n
    
def gcdExtended(a, b):
    if a == 0 :
        return b,0,1
    gcd,x1,y1 = gcdExtended(b%a, a)
    x = y1 - (b//a) * x1
    y = x1
    return gcd,x,y
    
def reciprocal(a, n):
    gcd, x, y = gcdExtended(a, n)
    if gcd == 1:
        return((x % n + n) % n)
    else:
        return(-1)
        
def isPrime(x): 
    if (x == 2):
        return(True)
    i = 0
    while(i < 100):
        a = random.randint(0, x)
        if (math.gcd(a, x) != 1):
            return(False)
        if (pow(a, x - 1, x) != 1):
            return(False)
        i += 1
    return(True)
    
def main():
    n = 46783589
    g = 2057523913923961
    l = 11692464
    mu = 39229921
    print("private key n =", n, "g =", g)
    print("public key", l, mu)
    # random open text
    m = 10
    print("open text", m)
    r = random.randint(0, n - 1)
    # r = 30697292
    print("r =", r)
    c = encryption(g, m, r, n)
    c = 1223454382402021
    print("encrypted number", c)
    m1 = decryption(c, n, l, mu)
    if (m == m1):
        print("decrypted number", m1, "\n")
    else:
        print("ERROR \n")
        
main()