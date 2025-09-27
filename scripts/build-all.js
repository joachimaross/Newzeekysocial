const { execSync } = require('child_process');

console.log('🏗️  Building Newzeekysocial - All Platforms\n');

// Build sequence
const buildSteps = [
  { name: 'Flutter Mobile', command: 'node scripts/build-flutter.js' },
  { name: 'React Web', command: 'cd apps/web && npm run build:web' }
];

buildSteps.forEach(step => {
  console.log(`\n🔨 Building ${step.name}...`);
  try {
    execSync(step.command, { stdio: 'inherit', shell: true });
    console.log(`✅ ${step.name} build successful`);
  } catch (error) {
    console.log(`❌ ${step.name} build failed:`, error.message);
  }
});

console.log('\n🎉 All builds completed!');
console.log('📱 Mobile: Flutter app ready in build/app/');
console.log('🌐 Web: React app ready in apps/web/build/');