// Development health check function for Netlify
// This function helps verify that the development environment is working correctly

export const handler = async (event, context) => {
  // Development-specific headers
  const headers = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    'Content-Type': 'application/json',
    'Cache-Control': 'no-cache, no-store, must-revalidate'
  };

  // Handle CORS preflight
  if (event.httpMethod === 'OPTIONS') {
    return {
      statusCode: 200,
      headers,
      body: JSON.stringify({ message: 'CORS preflight success' })
    };
  }

  try {
    const response = {
      status: 'healthy',
      environment: 'development',
      timestamp: new Date().toISOString(),
      deployment: {
        netlifyContext: context.clientContext || 'unknown',
        region: process.env.AWS_REGION || 'unknown',
        buildId: process.env.BUILD_ID || 'local'
      },
      config: {
        nodeEnv: process.env.NODE_ENV || 'unknown',
        flutterBuildMode: process.env.FLUTTER_BUILD_MODE || 'unknown',
        firebaseProjectId: process.env.FIREBASE_PROJECT_ID || 'not-configured'
      },
      features: {
        debugMode: process.env.FLUTTER_WEB_DEBUG === 'true',
        sourceMaps: process.env.FLUTTER_WEB_BUILD_WITH_SOURCEMAPS === 'true',
        devTools: process.env.ENABLE_DEV_TOOLS === 'true'
      }
    };

    return {
      statusCode: 200,
      headers,
      body: JSON.stringify(response, null, 2)
    };
  } catch (error) {
    console.error('Health check error:', error);
    
    return {
      statusCode: 500,
      headers,
      body: JSON.stringify({
        status: 'error',
        environment: 'development',
        timestamp: new Date().toISOString(),
        error: error.message
      })
    };
  }
};