const fs = require('fs');
const path = require('path');

console.log('🔍 Verifying Newzeekysocial Repository Structure...\n');

const rootFiles = {
  'apps/mobile/pubspec.yaml': 'Flutter configuration',
  'apps/mobile/pubspec.lock': 'Flutter dependencies (will be regenerated)',
  'apps/web/package.json': 'React web app configuration',
  'netlify.toml': 'Netlify deployment config'
};

Object.entries(rootFiles).forEach(([file, description]) => {
  const exists = fs.existsSync(path.resolve(file));
  console.log(`${exists ? '✅' : '❌'} ${file} - ${description}`);
});

// Check Flutter installation
try {
  require('child_process').execSync('flutter --version', { stdio: 'pipe' });
  console.log('✅ Flutter installed');
} catch {
  console.log('❌ Flutter not installed or not in PATH');
}

console.log('\n📋 Next Steps:');
console.log('1. Run: rm apps/mobile/pubspec.lock');
console.log('2. Run: cd apps/mobile && flutter pub get');
console.log('3. Run: git add apps/mobile/pubspec.lock && git commit -m "Update pubspec.lock"');
console.log('4. Run: git push');
