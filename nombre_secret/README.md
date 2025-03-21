# Zero-Knowledge Proof of a Secret Number with Noir and Barretenberg

This project demonstrates how to generate and verify a zero-knowledge proof of a secret number, using only SHA-256 as a one-way function to ensure security.

## The Circuit

The circuit proves that we know a secret number `n` which:
- Is in a specific interval [range_min, range_max]
- Produces a specific SHA-256 hash when converted to a byte array

Using SHA-256 as a one-way function ensures that it is computationally impossible to retrieve the original value from the hash, thus ensuring the confidentiality of the secret number.

## Scripts

### Proof for a specific number

To prove that you know a secret number:

```
./prouver_nombre.sh <number>
```

Exemple:
```
./prouver_nombre.sh 42
```

This will:
1. Calculate the SHA-256 hash of the number
2. Generate the Prover.toml file
3. Generate and verify the proof
``