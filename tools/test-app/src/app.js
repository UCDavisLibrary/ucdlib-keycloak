import { LitElement, html, css } from 'lit';
import { when } from 'lit/directives/when.js';

class KeycloakAuthTester extends LitElement {
  static styles = css`
    :host {
      display: block;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      max-width: 1200px;
      margin: 0 auto;
      padding: 20px;
      background-color: #f5f5f5;
    }
    
    .container {
      background: white;
      padding: 30px;
      border-radius: 8px;
      box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    }
    
    h1 {
      color: #002855;
      border-bottom: 3px solid #ffbf00;
      padding-bottom: 10px;
    }
    
    .auth-section {
      margin: 30px 0;
      padding: 20px;
      background: #f8f9fa;
      border-radius: 6px;
    }
    
    .config-section {
      margin: 30px 0;
      padding: 20px;
      background: #e9ecef;
      border-radius: 6px;
    }
    
    .token-section {
      margin: 30px 0;
      padding: 20px;
      background: #d4edda;
      border-radius: 6px;
    }
    
    button {
      background: #002855;
      color: white;
      border: none;
      padding: 12px 24px;
      border-radius: 4px;
      cursor: pointer;
      font-size: 16px;
      margin: 10px 10px 10px 0;
    }
    
    button:hover {
      background: #004080;
    }
    
    button:disabled {
      background: #ccc;
      cursor: not-allowed;
    }
    
    .logout-btn {
      background: #dc3545;
    }
    
    .logout-btn:hover {
      background: #c82333;
    }
    
    .info-box {
      background: #d1ecf1;
      border: 1px solid #bee5eb;
      border-radius: 4px;
      padding: 15px;
      margin: 15px 0;
    }
    
    .error-box {
      background: #f8d7da;
      border: 1px solid #f5c6cb;
      border-radius: 4px;
      padding: 15px;
      margin: 15px 0;
    }
    
    .token-display {
      background: #f8f9fa;
      border: 1px solid #dee2e6;
      border-radius: 4px;
      padding: 15px;
      margin: 10px 0;
      font-family: monospace;
      font-size: 12px;
      word-break: break-all;
      white-space: pre-wrap;
    }
    
    .status {
      font-weight: bold;
      margin: 10px 0;
    }
    
    .authenticated {
      color: #28a745;
    }
    
    .unauthenticated {
      color: #dc3545;
    }
    
    .config-item {
      margin: 10px 0;
    }
    
    .config-label {
      font-weight: bold;
      display: inline-block;
      width: 120px;
    }
    
    .config-value {
      font-family: monospace;
      background: #f8f9fa;
      padding: 4px 8px;
      border-radius: 3px;
    }
  `;

  static properties = {
    keycloak: { type: Object },
    config: { type: Object },
    authenticated: { type: Boolean },
    userInfo: { type: Object },
    error: { type: String },
    loading: { type: Boolean }
  };

  constructor() {
    super();
    this.keycloak = null;
    this.config = null;
    this.authenticated = false;
    this.userInfo = null;
    this.error = '';
    this.loading = true;
    this.init();
  }

  async init() {
    try {
      // Load configuration from server
      const response = await fetch('/api/config');
      this.config = await response.json();
      
      // Load Keycloak
      const Keycloak = window.Keycloak;
      if (!Keycloak) {
        throw new Error('Keycloak library not loaded');
      }
      
      // Initialize Keycloak
      this.keycloak = new Keycloak({
        url: this.config.keycloak.url,
        realm: this.config.keycloak.realm,
        clientId: this.config.keycloak.clientId
      });

      // Initialize Keycloak with specific options
      this.authenticated = await this.keycloak.init({
        onLoad: 'check-sso',
        silentCheckSsoRedirectUri: window.location.origin + '/silent-check-sso.html',
        checkLoginIframe: false,
        pkceMethod: 'S256'
      });

      if (this.authenticated) {
        this.userInfo = this.keycloak.tokenParsed;
        this.setupTokenRefresh();
      }

      this.loading = false;
      this.requestUpdate();
      
    } catch (error) {
      this.error = 'Failed to initialize Keycloak: ' + error.message;
      this.loading = false;
      console.error('Keycloak initialization error:', error);
    }
  }

  async handleLogin() {
    try {
      await this.keycloak.login({
        redirectUri: window.location.origin
      });
    } catch (error) {
      this.error = 'Login failed: ' + error.message;
    }
  }

  async handleLogout() {
    try {
      await this.keycloak.logout({
        redirectUri: window.location.origin
      });
    } catch (error) {
      this.error = 'Logout failed: ' + error.message;
    }
  }

  setupTokenRefresh() {
    setInterval(async () => {
      try {
        const refreshed = await this.keycloak.updateToken(70);
        if (refreshed) {
          console.log('Token refreshed');
          this.requestUpdate();
        }
      } catch (error) {
        console.error('Token refresh failed:', error);
        this.error = 'Token refresh failed: ' + error.message;
      }
    }, 60000);
  }

  clearError() {
    this.error = '';
  }

  renderConfig() {
    if (!this.config) return html`Loading configuration...`;
    
    return html`
      <div class="config-item">
        <span class="config-label">Keycloak URL:</span>
        <span class="config-value">${this.config.keycloak.url}</span>
      </div>
      <div class="config-item">
        <span class="config-label">Realm:</span>
        <span class="config-value">${this.config.keycloak.realm}</span>
      </div>
      <div class="config-item">
        <span class="config-label">Client ID:</span>
        <span class="config-value">${this.config.keycloak.clientId}</span>
      </div>
    `;
  }

  renderUserInfo() {
    if (!this.userInfo) return '';
    
    return html`
      <p><strong>Username:</strong> ${this.userInfo.preferred_username || 'N/A'}</p>
      <p><strong>Email:</strong> ${this.userInfo.email || 'N/A'}</p>
      <p><strong>Name:</strong> ${this.userInfo.name || 'N/A'}</p>
      <p><strong>Roles:</strong> ${this.userInfo.realm_access?.roles?.join(', ') || 'N/A'}</p>
    `;
  }

  renderTokens() {
    if (!this.authenticated || !this.keycloak) return '';
    
    const accessTokenInfo = this.keycloak.tokenParsed;
    const refreshTokenInfo = this.keycloak.refreshTokenParsed;
    
    return html`
      <h3>Access Token</h3>
      <div class="token-display">${JSON.stringify(accessTokenInfo, null, 2)}</div>
      
      <h3>Raw Access Token</h3>
      <div class="token-display">${this.keycloak.token}</div>
      
      <h3>Refresh Token Info</h3>
      <div class="token-display">${JSON.stringify(refreshTokenInfo, null, 2)}</div>
      
      <h3>Token Timing</h3>
      <div class="token-display">
Token expires in: ${Math.round(this.keycloak.tokenParsed.exp - Date.now() / 1000)} seconds
Token expires at: ${new Date(this.keycloak.tokenParsed.exp * 1000).toLocaleString()}
Refresh token expires in: ${Math.round(this.keycloak.refreshTokenParsed.exp - Date.now() / 1000)} seconds
      </div>
    `;
  }

  render() {
    if (this.loading) {
      return html`
        <div class="container">
          <h1>UC Davis Library Keycloak Auth Tester</h1>
          <p>Loading...</p>
        </div>
      `;
    }

    return html`
      <div class="container">
        <h1>UC Davis Library Keycloak Auth Tester</h1>
        
        <div class="info-box">
          <p><strong>Purpose:</strong> This tool is designed for local development testing of Keycloak authentication and themed pages.</p>
          <p><strong>Setup:</strong> Make sure you have a public client configured in your Keycloak admin console with the redirect URI set to this application's URL.</p>
        </div>

        <div class="auth-section">
          <h2>Authentication Status</h2>
          <div class="status ${this.authenticated ? 'authenticated' : 'unauthenticated'}">
            ${this.authenticated ? 'Authenticated' : 'Not authenticated'}
          </div>
          
          ${when(this.authenticated, () => html`
            <div>${this.renderUserInfo()}</div>
          `)}
          
          <div>
            ${when(!this.authenticated, () => html`
              <button @click="${this.handleLogin}">Login with Keycloak</button>
            `)}
            ${when(this.authenticated, () => html`
              <button class="logout-btn" @click="${this.handleLogout}">Logout</button>
            `)}
          </div>
        </div>

        <div class="config-section">
          <h2>Configuration</h2>
          ${this.renderConfig()}
        </div>

        ${when(this.authenticated, () => html`
          <div class="token-section">
            <h2>Token Information</h2>
            ${this.renderTokens()}
          </div>
        `)}

        ${when(this.error, () => html`
          <div class="error-box">
            <strong>Error:</strong> ${this.error}
            <button @click="${this.clearError}" style="margin-left: 10px; padding: 5px 10px; font-size: 12px;">Dismiss</button>
          </div>
        `)}
      </div>
    `;
  }
}

customElements.define('keycloak-auth-tester', KeycloakAuthTester);

// Initialize the application when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
  const app = document.createElement('keycloak-auth-tester');
  document.body.appendChild(app);
});