# ZK Proof API

A simple API to generate ZK (Zero-Knowledge) proofs from a secret number.

## Installation

```bash
# Install dependencies
npm install
```

## Starting the server

```bash
# Start the server
npm start

# Alternative: start with nodemon for development
# npm install -g nodemon   # if nodemon is not installed
npm run dev
```

The server will start on http://localhost:3000.

## API Usage

### Generate a ZK Proof

```
GET /generate/{number}
```

Replace `{number}` with the secret number for which you want to generate a proof.

Example:
```
GET /generate/42
```

### Response

#### Successful Response
If the proof generation is successful, the response will be in JSON format and will contain:
- `success`: `true` indicating the operation succeeded
- `number`: the provided number
- `proof`: the content of the generated proof file (base64 encoded)
- `proverContent`: the content of the Prover.toml file
- `scriptOutput`: the complete output of the script
- `scriptWarnings`: any warnings from the script execution

#### Error Response
If the proof generation fails, the response will include:
- `success`: `false`
- `number`: the provided number
- `error`: error message describing what went wrong
- `fileErrors`: list of file access or creation errors (if applicable)
- `missingCommands`: list of missing commands needed for proof generation (if applicable)
- `scriptOutput`: the complete output of the script
- `scriptErrors`: any errors from the script execution
- `proverContent`: the content of the Prover.toml file (if it was created)

## Limitations

The number must be between 1 and 1,000,000, as defined in the prouver_nombre.sh script.

## Requirements

The API requires the underlying ZK proof tools to be properly installed and accessible in the system path:
- `nargo`: Used for compiling the circuit and generating the witness
- `bb`: Used for proof generation and verification

If these tools are not installed, the API will indicate which commands are missing in the error response.

## Troubleshooting

### File Access Errors

If you encounter file access errors:

1. **Missing target directory**: The server will automatically attempt to create the target directory if it doesn't exist.

2. **Missing or inaccessible files**: If you see errors related to `nombre_secret.json`, `proof`, or `vk` files:
   - Ensure the `src` directory contains the necessary circuit files
   - Make sure the current user has write permissions to the target directory
   - Check that the ZK tools (nargo, bb) are correctly installed and working

3. **gzip errors**: These typically indicate problems with the input data format or size.

### Command Not Found Errors

If you see "command not found" errors:

1. Install the required tools:
   ```bash
   # Install nargo and bb (specific instructions depend on your system)
   # Please refer to the official documentation for these tools
   ```

2. Ensure the tools are in your PATH:
   ```bash
   # Check if the commands are accessible
   which nargo
   which bb
   ``` 