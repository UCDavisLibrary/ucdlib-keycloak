// Configuration for the Keycloak auth tester
export const config = {
  // Server configuration
  server: {
    port: process.env.PORT || 3000,
    host: process.env.HOST || 'localhost'
  },

  // Default Keycloak configuration
  keycloak: {
    url: process.env.KC_URL || 'https://localhost:8443',
    realm: process.env.KC_REALM || 'master',
    clientId: process.env.KC_CLIENT_ID || 'auth-tester',
    // For local development, often you'll want to create a public client
    // in your Keycloak admin console with these settings:
    // - Client ID: auth-tester
    // - Client Type: OpenID Connect
    // - Capability config: Standard flow enabled
    // - Valid redirect URIs: http://localhost:3000/*
    // - Web origins: http://localhost:3000
  },

  // UI configuration
  ui: {
    title: 'UC Davis Library Keycloak Auth Tester',
    description: 'Local development tool for testing Keycloak authentication and themed pages'
  }
};
