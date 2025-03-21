#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <number>"
    echo "Example: $0 42"
    exit 1
fi

nombre=$1

if ! [[ "$nombre" =~ ^[0-9]+$ ]]; then
    echo "Error: Please enter a natural number"
    exit 1
fi

range_min=1
range_max=1000000

if [ $nombre -lt $range_min ] || [ $nombre -gt $range_max ]; then
    echo "Error: The number must be in the interval [$range_min, $range_max]"
    exit 1
fi

echo -n -e "$(printf "\\x%02x" $nombre)" > nombre.bin
dd if=/dev/zero bs=1 count=31 >> nombre.bin 2>/dev/null

hash_hex=$(sha256sum nombre.bin | awk '{print $1}')
echo "Hash SHA-256 of the number $nombre: $hash_hex"

hash_toml="["
for (( i=0; i<${#hash_hex}; i+=2 )); do
    decimal=$((16#${hash_hex:$i:2}))
    hash_toml+="\"$decimal\", "
done
hash_toml=${hash_toml%, }
hash_toml+="]"

cat > Prover.toml << EOL
n = "$nombre"
range_min = "$range_min"
range_max = "$range_max"
hash_result = $hash_toml
EOL

echo "File Prover.toml created successfully"

echo "Compiling the circuit..."
nargo check

echo "Generating the witness..."
nargo execute

echo "Generating the proof..."
bb prove -b ./target/nombre_secret.json -w ./target/nombre_secret.gz -o ./target/proof

echo "Generating the verification key..."
bb write_vk -b ./target/nombre_secret.json -o ./target/vk

echo "Verifying the proof..."
bb verify -k ./target/vk -p ./target/proof

rm nombre.bin

echo "Proof generated and verified successfully for the number $nombre"

echo -e "\nPublic values:"
echo "Interval: [$range_min, $range_max]"
echo "Hash SHA-256: Value known only by the verifier"
echo -e "\nWith only this information, it is computationally impossible to retrieve the secret number." 