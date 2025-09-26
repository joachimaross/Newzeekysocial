# Zeeky Social

**Creator: Joa’Chima Ross**

Zeeky Social is a next-generation AI-powered social and messaging platform that unites communication, creativity, and community into one seamless ecosystem. It blends the best of Apple iMessage, Google Messages, and modern social networks, then reimagines them with AI at the core.

At the heart of the platform is Zeeky—an intelligent AI assistant who is more than a chatbot: he’s a partner, a creator, and a collaborator.

This is not just another app. Zeeky Social is the blueprint for the future of digital interaction.

## 📋 Table of Contents
- [🚀 Core Features](#-core-features)
- [🛠️ Tech Stack](#️-tech-stack)
- [📦 Quick Start](#-quick-start)
- [🧪 Testing & Beta Guide](#-testing--beta-guide)
  - [📋 Local Development Setup](#-local-development-setup)
  - [🚀 Running the App](#-running-the-app)  
  - [🧪 Feature Testing Guide](#-feature-testing-guide)
  - [🛠️ Test Accounts & Mock Credentials](#️-test-accounts--mock-credentials)
  - [🚨 Troubleshooting](#-troubleshooting-common-issues)
  - [🧪 Beta Testing Guidelines](#-beta-testing-guidelines)
- [🚀 Deployment](#-deployment)
- [🌍 Vision](#-vision)
- [🤝 Contributing](#-contributing)

---

## 🚀 Core Features

- **Unified Messaging Hub**
  - SMS, MMS, RCS, and encrypted chat support.
  - Rich media messaging, reactions, read receipts, and seamless syncing across devices.

- **Zeeky AI Assistant**
  - Personal assistant, content creator, and conversation partner.
  - Helps draft posts, replies, and stories.
  - Generates music, videos, and art.
  - Handles scheduling, reminders, and productivity tasks.

- **Social Media Reimagined**
  - AI-enhanced posts (auto-captions, smart hashtags, creative filters).
  - Public and private communities.
  - Dynamic interactive feed designed for connection, not noise.

- **Business + Productivity Integration**
  - Smart scheduling and task management.
  - Auto social posting with AI-generated captions.
  - Deep integration with calendar, notes, and files.

- **Entertainment + Creativity**
  - AI-driven music, story, and video generation.
  - Interactive content sharing and remix culture.
  - Community-driven creative challenges.

- **Security + Trust**
  - End-to-end encryption by default.
  - Multi-factor authentication.
  - Continuous auditing for performance, privacy, and resilience.

---

## 🛠️ Tech Stack
- **Frontend**: Flutter (cross-platform mobile + web) / React Native
- **Backend**: Firebase + Node.js microservices
- **Database**: Firestore + Realtime DB
- **AI/ML**: OpenAI API + custom models for personalization and media generation
- **Hosting & Infrastructure**: Firebase Hosting, Vercel, Cloudflare, optional Docker deployment
- **Version Control**: GitHub

---

## 📦 Quick Start

**For Developers & Beta Testers:** See the comprehensive [🧪 Testing & Beta Guide](#-testing--beta-guide) below for detailed setup instructions, testing guidelines, and troubleshooting.

**Quick Setup:**
1. Clone: `git clone https://github.com/joachimaross/Newzeekysocial.git`
2. Install: `flutter pub get && npm install`
3. Configure: Copy `.env.example` to `.env.local` and add Firebase config
4. Run: `flutter run -d web-server` or `npm run dev:netlify`

**Beta Testing:** Visit [beta.zeeky.social](https://beta.zeeky.social) or request mobile beta access at `beta@zeeky.social`

---

## 🧪 Testing & Beta Guide

### 📋 Local Development Setup

#### Prerequisites
- **Flutter SDK**: 3.24.0+ ([Install Flutter](https://docs.flutter.dev/get-started/install))
- **Node.js**: 16+ ([Install Node.js](https://nodejs.org/))
- **Firebase CLI**: `npm install -g firebase-tools`
- **Git**: Latest version
- **IDE**: VS Code, Android Studio, or IntelliJ

#### Initial Setup
1. **Clone and Navigate**:
   ```bash
   git clone https://github.com/joachimaross/Newzeekysocial.git
   cd Newzeekysocial
   ```

2. **Install Dependencies**:
   ```bash
   # Install Flutter dependencies
   flutter pub get
   
   # Install Node.js dependencies
   npm install
   ```

3. **Firebase Setup**:
   ```bash
   # Login to Firebase
   firebase login
   
   # Configure Flutter Fire
   flutterfire configure
   ```

4. **Environment Configuration**:
   ```bash
   # Copy environment template
   cp .env.example .env.local
   
   # Edit .env.local with your Firebase config
   # See "Test Credentials" section below for development values
   ```

#### Platform-Specific Setup

##### 🌐 Web Development
```bash
# Start web development server
flutter run -d web-server --web-port=3000

# Or with Netlify dev environment
npm run dev:netlify
```

##### 📱 Mobile Development (Android)
```bash
# Ensure Android emulator is running
flutter emulators --launch <emulator_id>

# Start mobile development
flutter run
```

##### 📱 Mobile Development (iOS)
```bash
# Requires macOS and Xcode
flutter run -d ios
```

### 🚀 Running the App

#### Development Mode
- **Purpose**: Full debugging, hot reload, development tools enabled
- **Firebase**: Uses development project with test data
- **AI Features**: Limited rate limits, development keys

```bash
# Web development
flutter run -d web-server --web-port=3000

# Mobile development
flutter run --debug

# With Netlify dev server
npm run dev:netlify
```

#### Beta/Profile Mode
- **Purpose**: Performance testing, near-production behavior
- **Firebase**: Uses staging project with realistic data
- **AI Features**: Production rate limits, staging keys

```bash
# Web beta build
flutter build web --profile --web-renderer html

# Mobile beta build
flutter run --profile

# Deploy beta to Netlify
npm run deploy:preview
```

### 🧪 Feature Testing Guide

#### 1. 🔐 Social Login Testing

**Available Test Providers:**
- **Google OAuth**: Use test Google account (see credentials below)
- **Email/Password**: Create test accounts on the fly
- **Anonymous Auth**: No credentials required

**Test Steps:**
1. Open app in browser/emulator
2. Click "Sign In" button
3. Select provider (Google, Email, or Anonymous)
4. For Google: Use test account `testuser@zeeky-dev.com` / `TestPass123!`
5. Verify user profile loads correctly
6. Test logout and re-login

**Expected Results:**
- ✅ Successful authentication
- ✅ User profile data synced
- ✅ Proper navigation to main app
- ✅ Session persistence

#### 2. 🤖 AI Assistant (Zeeky) Testing

**Test Scenarios:**
1. **Chat with Zeeky**
   - Navigate to AI Chat screen
   - Send message: "Hello Zeeky, help me write a post"
   - Verify AI response is contextual and helpful

2. **Content Generation**
   - Go to Create Post screen
   - Click "AI Assist" button
   - Enter topic: "weekend plans"
   - Verify generated content includes hashtags and emojis

3. **Smart Replies**
   - Open any conversation
   - Long-press on received message
   - Select "Smart Reply"
   - Verify 3 contextual reply options appear

**Expected Results:**
- ✅ AI responses in <3 seconds
- ✅ Contextually appropriate content
- ✅ No offensive or inappropriate responses
- ✅ Proper error handling for API failures

#### 3. 📝 Social Posting Testing

**Test Content Types:**
1. **Text Posts**
   ```
   Test message with #hashtags and @mentions
   Include emojis: 🚀✨🎉
   ```

2. **Media Posts**
   - Upload test images (JPG, PNG, WebP)
   - Upload test videos (MP4, max 10MB)
   - Test camera capture (mobile only)

3. **AI-Enhanced Posts**
   - Use AI content generation
   - Test auto-hashtag suggestions
   - Verify caption enhancement

**Test Steps:**
1. Click "Create Post" (+) button
2. Add content/media
3. Select privacy settings (Public/Friends/Private)
4. Add location (optional)
5. Publish post
6. Verify post appears in feed
7. Test interactions (like, comment, share)

#### 4. 🔄 Cross-Platform Integration Testing

**Sync Testing:**
1. Login on web browser
2. Create a post
3. Open mobile app with same account
4. Verify post appears on mobile
5. Test real-time updates (like/comment from one device, see on other)

**Features to Test:**
- ✅ Post synchronization
- ✅ Message synchronization
- ✅ Profile updates
- ✅ Notification sync
- ✅ Media uploads/downloads

#### 5. 💬 Messaging Testing

**Test Scenarios:**
1. **Direct Messages**
   - Find user via search
   - Send text message
   - Send media attachments
   - Test message encryption indicators

2. **Group Chats**
   - Create group with 3+ members
   - Test group naming/photo
   - Test member management
   - Verify message delivery to all members

3. **Message Features**
   - Test message reactions (👍❤️😂)
   - Test message replies/threads
   - Test message deletion
   - Test read receipts

### 🛠️ Test Accounts & Mock Credentials

#### Firebase Test Environment
```bash
# Development Firebase Project
FIREBASE_API_KEY=AIzaSyBExampleDevelopmentKey123
FIREBASE_PROJECT_ID=zeeky-social-dev
FIREBASE_AUTH_DOMAIN=zeeky-social-dev.firebaseapp.com
```

#### Test User Accounts
| Email | Password | Role | Features |
|-------|----------|------|----------|
| `testuser@zeeky-dev.com` | `TestPass123!` | Standard User | All features |
| `beta@zeeky-dev.com` | `BetaTest456!` | Beta Tester | Early features |
| `moderator@zeeky-dev.com` | `ModTest789!` | Content Moderator | Admin features |

#### API Test Keys
```bash
# Development OpenAI (limited usage)
OPENAI_API_KEY=sk-dev-test-key-for-zeeky-development

# Development Gemini (limited usage)  
GEMINI_API_KEY=AIzaSyDEV-Gemini-Test-Key-123
```

### 🔧 Firebase Emulators for Safe Testing

**Setup Local Firebase Emulators:**
```bash
# Install emulator suite
firebase init emulators

# Start all emulators
firebase emulators:start

# Available services:
# - Authentication: http://localhost:9099
# - Firestore: http://localhost:8080  
# - Storage: http://localhost:9199
# - Functions: http://localhost:5001
```

**Benefits:**
- ✅ No cost for testing
- ✅ Isolated test data
- ✅ Reset data anytime
- ✅ Offline development

### 🚨 Troubleshooting Common Issues

#### Build Issues

**Flutter Build Fails:**
```bash
# Clean build cache
flutter clean
flutter pub get

# Verify Flutter installation
flutter doctor

# Fix common issues
flutter upgrade
```

**Node.js/NPM Issues:**
```bash
# Clear npm cache
npm cache clean --force

# Delete and reinstall
rm -rf node_modules package-lock.json
npm install
```

#### Runtime Issues

**Firebase Connection Failed:**
- ✅ Check internet connection
- ✅ Verify Firebase project configuration in `firebase.json`
- ✅ Ensure API keys are correctly set in environment variables
- ✅ Check Firebase project status at [Firebase Console](https://console.firebase.google.com)

**AI Features Not Working:**
- ✅ Verify API keys are configured
- ✅ Check API quota/usage limits
- ✅ Test with development keys first
- ✅ Monitor browser console for error messages

**Authentication Issues:**
```bash
# Reset local auth state
flutter clean
rm -rf .dart_tool

# Clear browser storage (for web)
# Open DevTools > Application > Storage > Clear site data
```

**Performance Issues:**
```bash
# Web: Use HTML renderer for better initial load
flutter run -d web-server --web-renderer html

# Mobile: Enable profile mode for performance testing
flutter run --profile
```

#### Platform-Specific Issues

**Android:**
- ✅ Enable USB debugging
- ✅ Accept RSA key fingerprint
- ✅ Check minimum SDK version (API 21+)
- ✅ Verify Google Play services

**iOS:**
- ✅ Valid development certificate
- ✅ Proper bundle identifier
- ✅ iOS 11.0+ required
- ✅ Xcode 14+ for building

**Web:**
- ✅ Enable HTTPS for location services
- ✅ Clear browser cache for updates
- ✅ Disable ad blockers for development
- ✅ Check CORS configuration

### 🧪 Beta Testing Guidelines

#### How to Join Beta Testing

1. **Request Beta Access**
   - Email: `beta@zeeky.social`
   - Include: Name, email, preferred platform (web/mobile)
   - Specify: Android/iOS device details if testing mobile

2. **Beta Environment**
   - **Web**: https://beta.zeeky.social
   - **Mobile**: TestFlight (iOS) / Internal Testing (Android)
   - **Features**: Latest features, may include bugs
   - **Data**: Separate from production, safe to experiment

#### What to Test

**Priority Features:**
1. **🔥 New AI Features**: Latest Zeeky assistant capabilities
2. **🚀 Cross-Platform Sync**: Real-time synchronization
3. **💬 Enhanced Messaging**: New message types and features
4. **📱 Mobile Experience**: Touch gestures, camera integration
5. **🎨 UI/UX Updates**: New designs and interactions

**Test Methodology:**
1. **Exploratory Testing**: Use app naturally, report anything unusual
2. **Feature Testing**: Test specific features against expected behavior  
3. **Compatibility Testing**: Test on different devices/browsers
4. **Performance Testing**: Note slow loading, crashes, battery drain

#### Reporting Bugs & Feedback

**Bug Report Template:**
```markdown
**Environment:**
- Platform: Web/Android/iOS
- Device: [e.g., iPhone 14, Chrome Browser]
- App Version: [found in Settings > About]

**Issue Description:**
- What happened?
- What did you expect?
- Steps to reproduce?

**Severity:**
- Critical (app crash/data loss)
- High (feature doesn't work)
- Medium (inconvenient but workable)
- Low (cosmetic/suggestion)

**Screenshots/Videos:**
- [Attach if possible]
```

**How to Report:**
- **GitHub Issues**: [Create Issue](https://github.com/joachimaross/Newzeekysocial/issues/new)
- **Email**: `bugs@zeeky.social`
- **Beta Slack**: `#beta-testing` channel
- **In-App**: Settings > Report Bug

**Response Times:**
- Critical bugs: Within 24 hours
- High priority: Within 3 days  
- Medium/Low: Next release cycle

#### Beta Feedback Categories

**🎯 Feature Requests:**
- New capabilities you'd like to see
- Improvements to existing features
- Integration suggestions

**🎨 Design Feedback:**
- UI/UX improvements
- Accessibility concerns
- Visual consistency issues

**⚡ Performance:**
- Loading times
- Battery usage
- Memory consumption
- Network efficiency

**🔒 Security/Privacy:**
- Data handling concerns
- Permission requests
- Encryption verification

---

## 🚀 Deployment

**Quick Deploy:** 
- [![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https://github.com/joachimaross/Newzeekysocial)
- [![Deploy to Netlify](https://www.netlify.com/img/deploy/button.svg)](https://app.netlify.com/start/deploy?repository=https://github.com/joachimaross/Newzeekysocial)

**Manual Deployment:**
- **Production**: See [DEPLOYMENT.md](./DEPLOYMENT.md) for complete production setup
- **Development**: See [DEVELOPMENT_DEPLOYMENT.md](./DEVELOPMENT_DEPLOYMENT.md) for dev environment
- **Quick Start**: See [DEPLOYMENT_QUICKSTART.md](./DEPLOYMENT_QUICKSTART.md) for platform commands

**Supported Platforms:** Vercel, Netlify, Firebase Hosting, Docker

---

## 🌍 Vision

Zeeky Social is more than software—it’s a movement.

We’re creating a living digital ecosystem where AI isn’t just a tool, but a companion:
- A partner in communication.
- A collaborator in business and creativity.
- A connector across communities, cultures, and platforms.

The goal: build the first Fortune 500–level AI-powered social platform that redefines how humans and AI coexist, communicate, and create together.

This is the future of social.

---

## 🤝 Contributing

We welcome innovators, developers, designers, and dreamers.
1. Fork the repo.
2. Create your feature branch (`git checkout -b feature/amazing-feature`).
3. Commit changes (`git commit -m 'Add amazing feature'`).
4. Push to branch (`git push origin feature/amazing-feature`).
5. Submit a Pull Request.

---

## 📜 License

This project is licensed under the MIT License – see the `LICENSE` file for details.

---

### ⚡ Zeeky Social — Where AI Meets Humanity.
