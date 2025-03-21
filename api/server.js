const express = require('express');
const bodyParser = require('body-parser');
const { exec } = require('child_process');
const path = require('path');
const fs = require('fs');

const app = express();
const port = 3000;

// Middleware
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Endpoint to execute the prouver_nombre.sh script
app.get('/generate/:n', (req, res) => {
  const number = req.params.n;
  
  // Parameter validation
  if (!number || !/^\d+$/.test(number)) {
    return res.status(400).json({ error: 'Please provide a valid number' });
  }
  
  const scriptPath = path.join(__dirname, '..', 'prouver_nombre.sh');
  
  // Check if script exists
  if (!fs.existsSync(scriptPath)) {
    return res.status(500).json({ error: 'Script not found' });
  }
  
  // Ensure target directory exists
  const targetDir = path.join(__dirname, '..', 'target');
  if (!fs.existsSync(targetDir)) {
    console.log(`Creating target directory: ${targetDir}`);
    try {
      fs.mkdirSync(targetDir, { recursive: true });
    } catch (err) {
      console.error(`Failed to create target directory: ${err}`);
      return res.status(500).json({ error: 'Failed to create target directory', details: err.message });
    }
  }
  
  console.log(`Executing script with number: ${number}`);
  
  // Execute script
  exec(`bash ${scriptPath} ${number}`, (error, stdout, stderr) => {
    // Always check for Prover.toml file first, as it's created even if there are non-fatal errors
    const proverPath = path.join(__dirname, '..', 'Prover.toml');
    let proverContent = null;
    
    if (fs.existsSync(proverPath)) {
      try {
        proverContent = fs.readFileSync(proverPath, 'utf8');
      } catch (err) {
        console.error(`Error reading Prover.toml file: ${err}`);
      }
    }

    // Check if the proof file was created (despite potential warnings)
    const proofPath = path.join(__dirname, '..', 'target', 'proof');
    let proofContent = null;
    
    if (fs.existsSync(proofPath)) {
      try {
        proofContent = fs.readFileSync(proofPath);
        // Return proof as buffer since it might be binary data
        return res.json({
          success: true,
          number: number,
          proof: proofContent.toString('base64'),
          proverContent: proverContent,
          scriptOutput: stdout,
          scriptWarnings: stderr
        });
      } catch (err) {
        console.error(`Error reading proof file: ${err}`);
      }
    }
    
    // Analyze the errors
    const fileErrors = [];
    if (stderr && stderr.includes('Could not open file ./target/nombre_secret.json')) {
      fileErrors.push('Missing or inaccessible file: nombre_secret.json');
    }
    if (stderr && stderr.includes('gzip: stdin: unexpected end of file')) {
      fileErrors.push('gzip error: Unexpected end of file');
    }
    if (stderr && stderr.includes('Unable to open file: ./target/vk')) {
      fileErrors.push('Missing or inaccessible file: vk');
    }
    
    // Check if there are missing commands in stderr
    const missingCommands = [];
    if (stderr && stderr.includes('nargo : commande introuvable')) {
      missingCommands.push('nargo');
    }
    if (stderr && stderr.includes('bb : commande introuvable')) {
      missingCommands.push('bb');
    }
    
    // Prepare a detailed response
    return res.status(500).json({
      success: false,
      number: number,
      error: error ? error.message : 'Proof generation failed',
      fileErrors: fileErrors.length > 0 ? fileErrors : undefined,
      missingCommands: missingCommands.length > 0 ? missingCommands : undefined,
      scriptOutput: stdout,
      scriptErrors: stderr,
      proverContent: proverContent
    });
  });
});

// Default route
app.get('/', (req, res) => {
  res.send('ZK Proof Server active. Use /generate/{number} to generate a proof.');
});

// Start server
app.listen(port, '0.0.0.0', () => {
  console.log(`Server started on http://localhost:${port}`);
}); 