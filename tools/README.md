# UC Davis Library Keycloak Auth Tester

A local development tool for testing Keycloak authentication and themed pages.

## Purpose

This tool helps developers test Keycloak authentication flows and visualize tokens during local development. It's particularly useful for:

- Testing themed Keycloak login pages
- Debugging authentication flows
- Inspecting JWT tokens and their contents
- Verifying client configuration

## Features

- **ES Module Support**: Uses modern JavaScript import/export syntax
- **Keycloak.js Integration**: Client-side authentication using the official Keycloak JavaScript adapter
- **Token Inspection**: Displays access tokens, refresh tokens, and user information
- **Configurable**: Easily configure Keycloak URL, realm, and client ID
- **Real-time Updates**: Automatic token refresh with live status updates

## Setup

### 1. Install Dependencies

```bash
cd tools
npm install
```

### 2. Configure Keycloak Client

In your Keycloak admin console, create a public client with these settings:

- **Client ID**: `auth-tester` (or customize in config.js)
- **Client Type**: OpenID Connect
- **Client authentication**: Off (public client)
- **Standard flow**: Enabled
- **Direct access grants**: Enabled (optional)
- **Valid redirect URIs**: `http://localhost:3001/*`
- **Web origins**: `http://localhost:3001`

### 3. Environment Configuration

You can configure the application using environment variables:

```bash
# Keycloak configuration
export KC_URL=https://localhost:8443
export KC_REALM=master
export KC_CLIENT_ID=auth-tester

# Server configuration
export PORT=3001
export HOST=localhost
```

Or modify the values directly in `config.js`.

## Usage

### Start the Application

```bash
# Production mode
npm start

# Development mode (with auto-restart)
npm run dev
```

The application will be available at `http://localhost:3001` (or your configured port).

### Testing Authentication

1. Open the application in your browser
2. Review the configuration section to ensure settings are correct
3. Click "Login with Keycloak" to start the authentication flow
4. After successful login, you'll see:
   - User information
   - Access token details
   - Refresh token information
   - Token expiration times

### Features Available

- **Login/Logout**: Standard Keycloak authentication flow
- **Token Display**: View parsed JWT tokens and raw token strings
- **Auto-refresh**: Tokens are automatically refreshed before expiration
- **Error Handling**: Clear error messages for debugging

## Configuration

The application uses the following default configuration:

```javascript
{
  server: {
    port: 3001,
    host: 'localhost'
  },
  keycloak: {
    url: 'https://localhost:8443',
    realm: 'master',
    clientId: 'auth-tester'
  }
}
```

You can override these settings using environment variables or by modifying `config.js`.

## Troubleshooting

### Common Issues

1. **CORS Errors**: Make sure your Keycloak client has the correct web origins configured
2. **Redirect URI Mismatch**: Ensure your redirect URIs include the application URL
3. **SSL Certificate Issues**: For local development, you may need to accept self-signed certificates

### Debug Information

The application provides detailed error messages and logs authentication events to the browser console.

## Development

This tool is built using:

- **Express.js**: Web server framework
- **Keycloak.js**: Official Keycloak JavaScript adapter
- **ES Modules**: Modern JavaScript module syntax

## API Endpoints

- `GET /`: Main application page
- `GET /api/config`: Returns current configuration
- `GET /api/user-info`: Placeholder for user information endpoint
- `GET /health`: Health check endpoint

## License

MIT License - UC Davis Library