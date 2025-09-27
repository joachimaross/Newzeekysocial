const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

console.log('🔄 Regenerating Flutter dependencies...');

const flutterDir = path.join(__dirname, '../apps/mobile');

try {
  // Check if Flutter is available
  execSync('flutter --version', { stdio: 'inherit' });

  process.chdir(flutterDir);

  // Clean Flutter build
  execSync('flutter clean', { stdio: 'inherit' });

  // Get dependencies
  execSync('flutter pub get', { stdio: 'inherit' });

  // Analyze code
  execSync('flutter analyze', { stdio: 'inherit' });

  // Generate new pubspec.lock
  if (fs.existsSync('pubspec.lock')) {
    console.log('✅ pubspec.lock regenerated successfully');
  } else {
    console.log('❌ pubspec.lock generation failed');
  }

  // Test build for different platforms
  console.log('🧪 Testing Flutter builds...');
  execSync('flutter build apk --debug', { stdio: 'inherit' });
  if (process.platform === 'darwin') {
    execSync('flutter build ios --debug', { stdio: 'inherit' });
  } else {
    console.log('⚠️  Skipping iOS build: not running on macOS.');
  }

} catch (error) {
  console.error('❌ Flutter setup failed:', error.message);
  process.exit(1);
}