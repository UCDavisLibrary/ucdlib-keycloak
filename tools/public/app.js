// UC Davis Library Keycloak Auth Tester Frontend
import Keycloak from './keycloak.js';

class KeycloakAuthTester {
    constructor() {
        this.keycloak = null;
        this.config = null;
        this.init();
    }

    async init() {
        try {
            // Load configuration from server
            const response = await fetch('/api/config');
            this.config = await response.json();
            
            // Display configuration
            this.displayConfig();
            
            // Initialize Keycloak
            this.keycloak = new Keycloak({
                url: this.config.keycloak.url,
                realm: this.config.keycloak.realm,
                clientId: this.config.keycloak.clientId
            });

            // Initialize Keycloak with specific options
            const authenticated = await this.keycloak.init({
                onLoad: 'check-sso',
                silentCheckSsoRedirectUri: window.location.origin + '/silent-check-sso.html',
                checkLoginIframe: false, // Disable for local development
                pkceMethod: 'S256'
            });

            this.updateAuthStatus(authenticated);
            this.setupEventListeners();
            
            // Set up token refresh
            if (authenticated) {
                this.setupTokenRefresh();
            }
            
        } catch (error) {
            this.displayError('Failed to initialize Keycloak: ' + error.message);
            console.error('Keycloak initialization error:', error);
        }
    }

    displayConfig() {
        const configDiv = document.getElementById('config-display');
        configDiv.innerHTML = `
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

    updateAuthStatus(authenticated) {
        const statusDiv = document.getElementById('auth-status');
        const userInfoDiv = document.getElementById('user-info');
        const loginBtn = document.getElementById('login-btn');
        const logoutBtn = document.getElementById('logout-btn');
        const tokenSection = document.getElementById('token-section');

        if (authenticated) {
            statusDiv.textContent = 'Authenticated';
            statusDiv.className = 'status authenticated';
            
            // Display user information
            const userInfo = this.keycloak.tokenParsed;
            userInfoDiv.innerHTML = `
                <p><strong>Username:</strong> ${userInfo.preferred_username || 'N/A'}</p>
                <p><strong>Email:</strong> ${userInfo.email || 'N/A'}</p>
                <p><strong>Name:</strong> ${userInfo.name || 'N/A'}</p>
                <p><strong>Roles:</strong> ${userInfo.realm_access?.roles?.join(', ') || 'N/A'}</p>
            `;
            userInfoDiv.style.display = 'block';
            
            loginBtn.style.display = 'none';
            logoutBtn.style.display = 'inline-block';
            
            // Show tokens
            this.displayTokens();
            tokenSection.style.display = 'block';
            
        } else {
            statusDiv.textContent = 'Not authenticated';
            statusDiv.className = 'status unauthenticated';
            
            userInfoDiv.style.display = 'none';
            loginBtn.style.display = 'inline-block';
            logoutBtn.style.display = 'none';
            tokenSection.style.display = 'none';
        }
    }

    displayTokens() {
        const tokenDisplay = document.getElementById('token-display');
        
        const accessTokenInfo = this.keycloak.tokenParsed;
        const refreshTokenInfo = this.keycloak.refreshTokenParsed;
        
        tokenDisplay.innerHTML = `
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

    setupEventListeners() {
        document.getElementById('login-btn').addEventListener('click', async () => {
            try {
                await this.keycloak.login({
                    redirectUri: window.location.origin
                });
            } catch (error) {
                this.displayError('Login failed: ' + error.message);
            }
        });

        document.getElementById('logout-btn').addEventListener('click', async () => {
            try {
                await this.keycloak.logout({
                    redirectUri: window.location.origin
                });
            } catch (error) {
                this.displayError('Logout failed: ' + error.message);
            }
        });
    }

    setupTokenRefresh() {
        // Refresh token every 5 minutes
        setInterval(async () => {
            try {
                const refreshed = await this.keycloak.updateToken(70); // Refresh if expires in less than 70 seconds
                if (refreshed) {
                    console.log('Token refreshed');
                    this.displayTokens(); // Update token display
                }
            } catch (error) {
                console.error('Token refresh failed:', error);
                this.displayError('Token refresh failed: ' + error.message);
            }
        }, 60000); // Check every minute
    }

    displayError(message) {
        const errorDiv = document.getElementById('error-display');
        errorDiv.innerHTML = `
            <div class="error-box">
                <strong>Error:</strong> ${message}
            </div>
        `;
        
        // Auto-hide error after 10 seconds
        setTimeout(() => {
            errorDiv.innerHTML = '';
        }, 10000);
    }
}

// Initialize the application when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    new KeycloakAuthTester();
});