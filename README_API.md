# Jacameno API – Developer Portal

This is the official OpenAPI v3.1 specification for the Jacameno API.  
You can use this file to:
- Generate interactive docs (Swagger UI, Redoc, etc)
- Generate SDKs for Python, Node, Swift, etc
- Import into Postman/Insomnia for exploration and testing
- Validate your implementation and use as a contract for clients

## Key Features

- **REST-first, GraphQL-augmented API**
- OAuth2/OIDC with PKCE, SAML SSO, and fine-grained scopes
- Multi-tenant with strong privacy and audit guarantees
- Strong security: mTLS (service-to-service), short-lived tokens, RBAC
- Rich automation, media, and content endpoints
- Webhooks, event catalog, and admin moderation

## Using this OpenAPI Spec

### 1. Preview as Interactive Docs
- Use [Swagger Editor](https://editor.swagger.io/) or [Redocly](https://redocly.com/docs/redoc/) to view this file.

### 2. Generate SDKs
- Use [openapi-generator](https://openapi-generator.tech/) or [Swagger Codegen](https://swagger.io/tools/swagger-codegen/) to generate client libraries in your language of choice.

### 3. Import to Postman/Insomnia
- Import `openapi.yaml` directly to Postman/Insomnia for quick endpoint testing.

### 4. CI/CD and Linting
- Validate with [openapi-cli](https://www.npmjs.com/package/@redocly/openapi-cli):
  ```
  npx @redocly/openapi-cli lint openapi.yaml
  ```

### 5. PR/Issue Templates
- See `API_TERMS.md`, `PRIVACY_POLICY.md`, `AUP.md`, `MODERATION.md`, `SECURITY.md` for policy and compliance.

## Authentication

- OAuth2/OIDC via `/v1/oauth/token` (PKCE for public clients)
- API key via `X-API-Key` header for server-to-server (short TTL)
- Roles: owner, admin, editor, developer, viewer
- Scopes: see `openapi.yaml` security section

## Example: Exchange Code for Token

```bash
curl -X POST "https://api.jacameno.com/v1/oauth/token" \
  -d "grant_type=authorization_code&code=AUTH_CODE&redirect_uri=...&client_id=CLIENT_ID&code_verifier=VERIFIER"
```

## Example: Create a Shortcut

```bash
curl -X POST "https://api.jacameno.com/v1/shortcuts" \
  -H "Authorization: Bearer ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"My Shortcut","payload":...,"metadata":{}}'
```

## Maintainers

- Jacameno platform engineering
- Contact: security@jacameno.com

---

For support, feature requests, or to contribute, open an issue or PR in this repository.
