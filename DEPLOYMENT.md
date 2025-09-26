# Deployment Guide for Zeeky Social

This guide provides instructions for deploying the Zeeky Social Flutter web application to various hosting platforms.

> **📖 For Development-Specific Deployment:** See [DEVELOPMENT_DEPLOYMENT.md](./DEVELOPMENT_DEPLOYMENT.md) for detailed development environment setup and deployment instructions.

## 🚀 Supported Platforms

### Vercel
- ✅ Configuration: `vercel.json`
- ✅ Auto-deployment from GitHub
- ✅ Built-in CDN and SSL
- ✅ SPA routing support

### Netlify  
- ✅ Configuration: `netlify.toml` (production) / `netlify.dev.toml` (development)
- ✅ Auto-deployment from GitHub
- ✅ Built-in CDN and SSL
- ✅ SPA routing support
- ✅ Development functions for debugging

### Firebase Hosting
- ✅ Configuration: `firebase.json` (hosting section)
- ✅ Native Firebase integration
- ✅ Global CDN and SSL
- ✅ SPA routing support

## 📋 Prerequisites

### Development Environment
- Flutter SDK 3.24.0+ installed
- Node.js 16+ (for build scripts)
- Firebase project configured
- Git repository connected to hosting platform

### Firebase Configuration
Ensure your Firebase configuration is properly set up:
1. `firebase.json` - Firebase hosting configuration (already present)
2. `lib/firebase_options.dart` - Generated Firebase config (already present)
3. Environment variables for production (see below)

## 🔧 Environment Variables

For both Vercel and Netlify, configure these environment variables in your platform dashboard:

### Required Variables
```bash
# Firebase Configuration
FIREBASE_API_KEY=your_api_key_here
FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_STORAGE_BUCKET=your_project.appspot.com
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_APP_ID=your_app_id

# Build Configuration
NODE_ENV=production
FLUTTER_BUILD_MODE=release
FLUTTER_WEB_USE_SKIA=false
```

## 🚀 Deployment Instructions

### Vercel Deployment

#### Option 1: Automatic (Recommended)
1. Connect your GitHub repository to Vercel
2. Import the project in Vercel dashboard
3. Vercel will automatically detect the configuration from `vercel.json`
4. Add environment variables in Vercel dashboard
5. Deploy!

#### Option 2: Manual
```bash
# Install Vercel CLI
npm i -g vercel

# Login and deploy
vercel login
vercel --prod
```

### Netlify Deployment

#### Option 1: Automatic (Recommended)
1. Connect your GitHub repository to Netlify
2. Netlify will automatically detect the configuration from `netlify.toml`
3. Add environment variables in Netlify dashboard
4. Deploy!

#### Option 2: Manual
```bash
# Install Netlify CLI
npm install -g netlify-cli

# Login and deploy
netlify login
netlify deploy --prod
```

### Firebase Hosting Deployment

#### Option 1: Automatic (GitHub Actions)
Set up GitHub Actions workflow (already included) and connect Firebase to GitHub.

#### Option 2: Manual
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login and deploy
firebase login
flutter build web --release
firebase deploy --only hosting
```

## 🛠️ Build Process

The build process for both platforms:

1. **Install Flutter SDK** (handled by platform)
2. **Get Dependencies**: `flutter pub get`
3. **Build Web App**: `flutter build web --release --web-renderer html`
4. **Deploy**: Static files from `build/web/` directory

## 📁 Build Output

After successful build, the following structure will be created in `build/web/`:
```
build/web/
├── index.html
├── main.dart.js
├── flutter_service_worker.js
├── manifest.json
├── assets/
├── icons/
└── canvaskit/ (if using CanvasKit renderer)
```

## 🔍 Troubleshooting

### Common Issues

#### Build Failures
- Ensure Flutter SDK version compatibility
- Check `pubspec.yaml` for dependency conflicts
- Verify Firebase configuration is valid

#### Runtime Errors
- Check browser console for JavaScript errors
- Verify Firebase project settings match configuration
- Ensure all environment variables are set correctly

#### Performance Issues
- Consider using CanvasKit renderer for better performance: `flutter build web --web-renderer canvaskit`
- Enable compression in hosting platform settings
- Optimize images and assets

### Platform-Specific Issues

#### Vercel
- Functions timeout after 30 seconds (configured in `vercel.json`)
- Check build logs in Vercel dashboard
- Ensure Node.js version is compatible

#### Netlify
- Build time limit of 15 minutes
- Check deploy logs in Netlify dashboard
- Verify redirect rules for SPA routing

## 📊 Performance Optimization

### Recommendations
1. **Use HTML renderer** for better initial load times
2. **Enable compression** in hosting platform
3. **Optimize assets** - compress images, use WebP format
4. **Implement caching** - already configured in deployment files
5. **Monitor Core Web Vitals** using platform analytics

### Asset Optimization
```bash
# Optimize images before building
flutter build web --tree-shake-icons
```

## 🔒 Security

Both configurations include security headers:
- `X-Frame-Options: DENY`
- `X-XSS-Protection: 1; mode=block`
- `X-Content-Type-Options: nosniff`
- `Referrer-Policy: strict-origin-when-cross-origin`

## 📈 Monitoring

### Platform Analytics
- **Vercel**: Built-in analytics available
- **Netlify**: Built-in analytics available
- **Firebase**: Use Firebase Analytics for user behavior

### Custom Monitoring
Consider integrating:
- Google Analytics 4
- Firebase Crashlytics
- Performance monitoring tools

## 🚀 Next Steps

After successful deployment:
1. Configure custom domain (optional)
2. Set up SSL certificate (automatic on both platforms)
3. Configure Firebase security rules
4. Set up continuous deployment workflows
5. Monitor application performance and user analytics

## 📞 Support

For deployment issues:
- Check platform-specific documentation
- Review build logs for errors
- Verify Firebase console configuration
- Test locally with `flutter run -d web-server`

---

**Happy Deploying! 🎉**