# UC Davis Library Keycloak Auth Tester

A local development tool for testing Keycloak authentication and themed pages built with Lit web components.

## Purpose

This tool helps developers test Keycloak authentication flows and visualize tokens during local development. It's particularly useful for:

- Testing themed Keycloak login pages
- Debugging authentication flows
- Inspecting JWT tokens and their contents
- Verifying client configuration

## Features

- **Lit Web Components**: Modern web component architecture with reactive updates
- **Webpack Build**: Bundled application with development and production modes
- **Keycloak.js Integration**: Client-side authentication using the official Keycloak JavaScript adapter
- **Token Inspection**: Displays access tokens, refresh tokens, and user information
- **Configurable**: Easily configure Keycloak URL, realm, and client ID
- **Real-time Updates**: Automatic token refresh with live status updates

## Setup

### 1. Install Dependencies

```bash
cd tools/test-app
npm install
```

### 2. Configure Keycloak Client

In your Keycloak admin console, create or use an existing OIDC public client.

### 3. Environment Configuration

You can configure the application using environment variables.
Take note of the realm, client id, and the port of the redirect url (e.g. 3001 for http://localhost:3001) when setting up in keycloak. You will pass in these variables at run time.

### 4. Trusting Keycloak

The local keycloak instance uses a self-signed cert, so you have to opt in. In your browser, go to https://localhost:8443 and accept the risk and continue if you haven't done that already in the previous step.

## Usage

### Quick Start with Convenience Script

The easiest way to start the application is using the provided convenience script:

```bash
# Basic usage with required arguments
./start.sh <KC_REALM> <KC_CLIENT_ID> [PORT]

# Example:
./start.sh master auth-tester 3001

# With default port (3001):
./start.sh master auth-tester
```

The script will:
- Validate that KC_REALM and KC_CLIENT_ID are provided
- Set the environment variables
- Display the configuration
- Start the application

### Manual Build and Start

You can also build and start the application manually:

```bash
# Build for production and start server
npm run serve

# Or build and start separately
npm run build
npm start

# Development mode (build with watch)
npm run dev
# Then in another terminal:
npm start
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

## Development

This tool is built using:

- **Lit**: Web components library for reactive UIs
- **Webpack**: Module bundler and build system
- **Express.js**: Web server framework
- **Keycloak.js**: Official Keycloak JavaScript adapter
- **ES Modules**: Modern JavaScript module syntax

## Build Commands

- `npm run build`: Build for production
- `npm run dev`: Build for development with watch mode
- `npm start`: Start the Express server
- `npm run serve`: Build and start in one command

## API Endpoints

- `GET /`: Main application page
- `GET /api/config`: Returns current configuration
- `GET /api/user-info`: Placeholder for user information endpoint
- `GET /health`: Health check endpoint

## Troubleshooting

### Common Issues

1. **CORS Errors**: Make sure your Keycloak client has the correct web origins configured
2. **Redirect URI Mismatch**: Ensure your redirect URIs include the application URL
3. **SSL Certificate Issues**: For local development, you may need to accept self-signed certificates
4. **Build Errors**: Make sure all dependencies are installed with `npm install`

### Debug Information

The application provides detailed error messages and logs authentication events to the browser console.

## License

MIT License - UC Davis Library
