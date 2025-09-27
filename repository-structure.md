# Newzeekysocial Monorepo Structure

```
apps/
├── mobile/          # Flutter mobile application
│   ├── lib/
│   ├── pubspec.yaml
│   └── ...
├── web/             # React web application
│   ├── src/
│   ├── package.json
│   └── ...
└── shared/          # Shared assets and configurations (if any)
scripts/
  build-flutter.js
  build-all.js
  verify-structure.js
.github/
  workflows/
    build.yml
```