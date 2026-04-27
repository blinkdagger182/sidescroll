# Coolify Deployment

Deploy `LiveDoomscrollMVP/backend` as a Dockerfile application in Coolify.

## Coolify App Settings

- Build Pack: Dockerfile
- Dockerfile Location: `LiveDoomscrollMVP/backend/Dockerfile`
- Base Directory: repository root, or `LiveDoomscrollMVP/backend` if you deploy this folder directly
- Port: `3000`
- Health Check Path: `/health`

## Environment Variables

```bash
NODE_ENV=production
PORT=3000
CORS_ORIGIN=*
LIVEKIT_URL=wss://your-livekit-host.example.com
LIVEKIT_API_KEY=your_livekit_api_key
LIVEKIT_API_SECRET=your_livekit_api_secret
TOKEN_TTL_SECONDS=7200
ROOM_PREFIX=doomscroll
```

After deployment, set `LiveKitTestConfig.backendURL` in the iOS app to the public HTTPS URL Coolify assigns to this service.

## Coolify MCP

Coolify MCP is connected in this Codex session. The currently exposed tools can list apps/resources/deployments, read logs, trigger deploys, and create/update env vars for an existing app UUID.

The exposed tools do not currently include a create-application/project operation, so the first Coolify app still needs to be created in the Coolify UI or through a broader Coolify API tool. After that, provide the application UUID and I can set env vars, deploy, and inspect logs through MCP.

## MCP Follow-up Once App Exists

Use the app UUID with:

- `coolify_createEnv` / `coolify_updateEnv` for the values above.
- `coolify_deploy` to trigger a deploy.
- `coolify_getLogs` and `coolify_listAppDeployments` to debug startup.
