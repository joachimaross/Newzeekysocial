# Development Deployment Guide for Zeeky Social

This guide provides step-by-step instructions for deploying Zeeky Social to Netlify in a development environment.

## 📋 Overview

The development deployment configuration includes:

- **`netlify.dev.toml`** - Development-specific Netlify configuration
- **`netlify.toml`** - Production Netlify configuration (enhanced)
- **`.env.development`** - Development environment variables template
- **`scripts/deploy-dev.sh`** - Automated deployment script
- **`netlify/functions/`** - Development serverless functions

## 🚀 Quick Start

### 1. Environment Setup

1. **Copy environment template:**
   ```bash
   cp .env.example .env.development
   ```

2. **Configure Firebase for development:**
   - Create a separate Firebase project for development
   - Update `.env.development` with your development Firebase configuration
   - Set environment variables in Netlify site settings

3. **Install Netlify CLI:**
   ```bash
   npm install -g netlify-cli
   netlify login
   ```

### 2. Local Development

Start local development server with Netlify functions:

```bash
# Option 1: Using npm script
npm run dev:netlify

# Option 2: Using deployment script
./scripts/deploy-dev.sh local

# Option 3: Direct netlify command
netlify dev --config netlify.dev.toml
```

This will start:
- Flutter development server on port 3000
- Netlify Functions proxy
- Live reloading for code changes

### 3. Deployment Options

#### Draft Deployment (Default)
```bash
# Using script
./scripts/deploy-dev.sh

# Using npm
npm run deploy:dev
```

#### Preview Deployment (Branch-based)
```bash
# Using script
./scripts/deploy-dev.sh preview

# Using npm
npm run deploy:preview
```

#### Production Deployment
```bash
# Using script
./scripts/deploy-dev.sh production

# Using npm
npm run deploy:prod
```

## 🔧 Configuration Details

### netlify.dev.toml Features

- **Debug builds** with source maps for easier debugging
- **Reduced caching** for faster development iteration  
- **CORS headers** configured for development APIs
- **Less restrictive CSP** for development tools
- **Development-specific environment variables**
- **Automatic Netlify Functions support**

### Environment Variables

#### Required for Development

| Variable | Description | Example |
|----------|-------------|---------|
| `FIREBASE_API_KEY` | Development Firebase API key | `AIzaSyDEVELOPMENT_...` |
| `FIREBASE_AUTH_DOMAIN` | Development Auth domain | `myapp-dev.firebaseapp.com` |
| `FIREBASE_PROJECT_ID` | Development project ID | `myapp-dev` |
| `FIREBASE_STORAGE_BUCKET` | Development storage bucket | `myapp-dev.appspot.com` |
| `FIREBASE_MESSAGING_SENDER_ID` | Development sender ID | `123456789012` |
| `FIREBASE_APP_ID` | Development app ID | `1:123:web:abc123` |

#### Development-Specific Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `NODE_ENV` | Environment mode | `development` |
| `FLUTTER_BUILD_MODE` | Flutter build mode | `debug` |
| `FLUTTER_WEB_USE_SKIA` | Web renderer type | `false` |
| `FLUTTER_WEB_DEBUG` | Enable debug features | `true` |
| `ENABLE_DEV_TOOLS` | Show dev tools | `true` |

### Setting Environment Variables in Netlify

1. Go to your Netlify site dashboard
2. Navigate to **Site Settings > Environment Variables**
3. Click **Add Variable** for each required variable
4. Set **Scopes** to appropriate deployment contexts:
   - `dev` for development builds
   - `branch-deploy` for preview deployments  
   - `production` for production builds

## 🛠️ Development Functions

The development environment includes serverless functions for debugging:

### Health Check Function
**Endpoint:** `/.netlify/functions/dev-health`

Returns deployment status and configuration information:
```json
{
  "status": "healthy",
  "environment": "development",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "deployment": {
    "netlifyContext": "dev",
    "region": "us-east-1",
    "buildId": "abc123"
  },
  "config": {
    "nodeEnv": "development",
    "flutterBuildMode": "debug",
    "firebaseProjectId": "myapp-dev"
  },
  "features": {
    "debugMode": true,
    "sourceMaps": true,
    "devTools": true
  }
}
```

### Configuration Validation Function
**Endpoint:** `/.netlify/functions/dev-config`

Validates that all required environment variables are properly configured:
```json
{
  "status": "healthy",
  "environment": "development",
  "validation": {
    "required": {
      "FIREBASE_API_KEY": {
        "configured": true,
        "hasValue": true,
        "placeholder": false
      }
    },
    "optional": {
      "OPENAI_API_KEY": {
        "configured": true,
        "hasValue": true
      }
    }
  },
  "summary": {
    "requiredMissing": 0,
    "optionalMissing": 2,
    "totalConfigured": 8
  }
}
```

## 🔍 Debugging and Troubleshooting

### Common Issues

1. **Build Failures**
   ```bash
   # Check Flutter installation
   flutter doctor
   
   # Clean and rebuild
   flutter clean
   flutter pub get
   flutter build web --debug
   ```

2. **Environment Variable Issues**
   ```bash
   # Test configuration validation
   curl https://yoursite.netlify.app/.netlify/functions/dev-config
   
   # Check health status
   curl https://yoursite.netlify.app/.netlify/functions/dev-health
   ```

3. **Local Development Issues**
   ```bash
   # Check Netlify CLI status
   netlify status
   
   # Restart development server
   netlify dev --clear-cache --config netlify.dev.toml
   ```

### Debug Mode Features

When `FLUTTER_WEB_DEBUG=true`:
- Source maps are enabled for easier debugging
- Debug information is available in browser dev tools
- Performance overlay can be enabled
- Detailed error messages are shown

### Build Analysis

Check build output and analyze bundle size:

```bash
# Build with analysis
flutter build web --analyze-size --debug

# Serve locally to test
python -m http.server 8000 -d build/web
```

## 🚦 Deployment Workflows

### Branch-based Deployment

1. **Feature branches** → Draft deployments for testing
2. **Development branch** → Development environment deployment
3. **Staging branch** → Staging environment (profile builds)
4. **Main branch** → Production environment (release builds)

### Environment Promotion

```bash
# 1. Develop and test locally
npm run dev:netlify

# 2. Deploy draft for review  
npm run deploy:dev

# 3. Deploy to preview environment
npm run deploy:preview

# 4. Deploy to production (after approval)
npm run deploy:prod
```

## 📊 Performance Monitoring

Development builds include performance monitoring:

- **Source maps** for debugging
- **Bundle analysis** for size optimization
- **Development functions** for health checks
- **Environment validation** for configuration issues

## 🔒 Security Considerations

Development deployments include:

- **Separate Firebase project** to avoid affecting production data
- **Test API keys** for external services
- **Development-only functions** that are disabled in production
- **CORS configuration** appropriate for development testing

## 📞 Support

For development deployment issues:

1. Check the **development functions** for configuration status
2. Review **Netlify build logs** for detailed error information  
3. Use **Flutter build analysis** for build-specific issues
4. Consult the main **DEPLOYMENT.md** for general deployment guidance

## 🔄 Updates and Maintenance

To update the development deployment configuration:

1. Modify `netlify.dev.toml` for Netlify-specific settings
2. Update `.env.development` template for new environment variables
3. Enhance `scripts/deploy-dev.sh` for new deployment features
4. Test changes using draft deployments before promoting

---

**Next Steps:** See [DEPLOYMENT.md](./DEPLOYMENT.md) for production deployment instructions.