# Deployment Quick Start

This section can be added to the main README.md to provide quick deployment information.

## 🚀 Deploy Zeeky Social

Zeeky Social is configured for deployment on multiple platforms. Choose your preferred hosting provider:

### One-Click Deployment

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https://github.com/joachimaross/Newzeekysocial)

[![Deploy to Netlify](https://www.netlify.com/img/deploy/button.svg)](https://app.netlify.com/start/deploy?repository=https://github.com/joachimaross/Newzeekysocial)

### Manual Deployment

For detailed deployment instructions including environment setup and configuration, see [DEPLOYMENT.md](./DEPLOYMENT.md).

### Supported Platforms
- **Vercel** - Zero-config deployment with global CDN
- **Netlify** - JAMstack deployment with built-in CI/CD  
- **Firebase Hosting** - Google's hosting with Firebase integration

### Build Requirements
- Flutter SDK 3.24.0+
- Node.js 16+ (for build scripts)
- Firebase project (for backend services)

### Quick Deploy Commands
```bash
# Vercel
npm install -g vercel
vercel --prod

# Netlify  
npm install -g netlify-cli
netlify deploy --prod

# Firebase
npm install -g firebase-tools
flutter build web --release
firebase deploy --only hosting
```

For environment variables and detailed setup, see the [deployment guide](./DEPLOYMENT.md).