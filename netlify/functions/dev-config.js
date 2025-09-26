// Development configuration validation function
// Helps validate that all required environment variables are properly configured

export const handler = async (event, context) => {
  const headers = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    'Content-Type': 'application/json',
    'Cache-Control': 'no-cache'
  };

  if (event.httpMethod === 'OPTIONS') {
    return { statusCode: 200, headers, body: '' };
  }

  // Only allow in development environment
  if (process.env.NODE_ENV === 'production') {
    return {
      statusCode: 403,
      headers,
      body: JSON.stringify({ error: 'Config validation not available in production' })
    };
  }

  const requiredVars = [
    'FIREBASE_API_KEY',
    'FIREBASE_AUTH_DOMAIN',
    'FIREBASE_PROJECT_ID',
    'FIREBASE_STORAGE_BUCKET',
    'FIREBASE_MESSAGING_SENDER_ID',
    'FIREBASE_APP_ID'
  ];

  const optionalVars = [
    'OPENAI_API_KEY',
    'GEMINI_API_KEY',
    'GOOGLE_ANALYTICS_ID',
    'SENTRY_DSN',
    'NETLIFY_SITE_ID'
  ];

  const configStatus = {
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'unknown',
    validation: {
      required: {},
      optional: {},
      flutter: {},
      netlify: {}
    },
    summary: {
      requiredMissing: 0,
      optionalMissing: 0,
      totalConfigured: 0
    }
  };

  // Check required variables
  requiredVars.forEach(varName => {
    const isSet = !!process.env[varName];
    configStatus.validation.required[varName] = {
      configured: isSet,
      hasValue: isSet && process.env[varName].length > 0,
      placeholder: !isSet || process.env[varName].includes('your_') || process.env[varName].includes('REPLACE_ME')
    };
    
    if (!isSet) {
      configStatus.summary.requiredMissing++;
    } else {
      configStatus.summary.totalConfigured++;
    }
  });

  // Check optional variables
  optionalVars.forEach(varName => {
    const isSet = !!process.env[varName];
    configStatus.validation.optional[varName] = {
      configured: isSet,
      hasValue: isSet && process.env[varName].length > 0
    };
    
    if (!isSet) {
      configStatus.summary.optionalMissing++;
    } else {
      configStatus.summary.totalConfigured++;
    }
  });

  // Check Flutter-specific configuration
  configStatus.validation.flutter = {
    buildMode: process.env.FLUTTER_BUILD_MODE || 'not-set',
    webRenderer: process.env.FLUTTER_WEB_USE_SKIA || 'not-set',
    debug: process.env.FLUTTER_WEB_DEBUG === 'true',
    sourceMaps: process.env.FLUTTER_WEB_BUILD_WITH_SOURCEMAPS === 'true'
  };

  // Check Netlify-specific configuration
  configStatus.validation.netlify = {
    siteId: !!process.env.NETLIFY_SITE_ID,
    isDev: process.env.NETLIFY_DEV === 'true',
    branch: process.env.NETLIFY_BRANCH || 'not-set',
    buildId: process.env.BUILD_ID || 'not-set'
  };

  // Determine overall status
  const isHealthy = configStatus.summary.requiredMissing === 0;
  const statusCode = isHealthy ? 200 : 400;

  configStatus.status = isHealthy ? 'healthy' : 'configuration-issues';
  configStatus.message = isHealthy 
    ? 'All required configuration variables are set'
    : `${configStatus.summary.requiredMissing} required variables are missing`;

  return {
    statusCode,
    headers,
    body: JSON.stringify(configStatus, null, 2)
  };
};