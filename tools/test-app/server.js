import express from 'express';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import { config } from './config.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const app = express();

// Serve static files from dist directory
app.use(express.static(join(__dirname, 'dist')));

// API endpoint to get configuration
app.get('/api/config', (req, res) => {
  res.json({
    keycloak: config.keycloak,
    ui: config.ui
  });
});

// API endpoint to display token information (called after successful auth)
app.get('/api/user-info', (req, res) => {
  // In a real implementation, this would validate the token
  // For now, this is just a placeholder that returns instructions
  res.json({
    message: 'This endpoint would normally validate and display token information',
    instructions: 'Token information is displayed on the client side for security'
  });
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Default route - serve the main page
app.get('/', (req, res) => {
  res.sendFile(join(__dirname, 'dist', 'index.html'));
});

// Start the server
const { port, host } = config.server;
app.listen(port, host, () => {
  console.log(`UC Davis Library Keycloak Auth Tester`);
  console.log(`Server running at http://${host}:${port}`);
  console.log(`Keycloak URL: ${config.keycloak.url}`);
  console.log(`Realm: ${config.keycloak.realm}`);
  console.log(`Client ID: ${config.keycloak.clientId}`);
  console.log(`\nMake sure to configure a public client in your Keycloak admin console`);
  console.log(`with redirect URI: http://${host}:${port}/*`);
});