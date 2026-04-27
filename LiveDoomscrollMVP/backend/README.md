# Sidescroll LiveKit Token Backend

Small Fastify service that mints short-lived LiveKit participant tokens for the iOS MVP.

## Endpoints

- `GET /health`
- `GET /v1/livekit/config`
- `POST /v1/livekit/token`

Request:

```json
{
  "roomName": "private-room-123",
  "participantName": "Rizhan's iPhone"
}
```

Response:

```json
{
  "liveKitUrl": "wss://your-livekit-host.example.com",
  "token": "jwt",
  "roomName": "doomscroll-private-room-123",
  "identity": "ios_xxx"
}
```

## Required Environment

- `LIVEKIT_URL`: LiveKit websocket URL.
- `LIVEKIT_API_KEY`: LiveKit server API key.
- `LIVEKIT_API_SECRET`: LiveKit server API secret.
- `PORT`: defaults to `3000`.
- `CORS_ORIGIN`: defaults to `*`; set to your app/admin origins later.
- `TOKEN_TTL_SECONDS`: defaults to `7200`.
- `ROOM_PREFIX`: defaults to `doomscroll`.

## Local Run

```bash
cp .env.example .env
npm install
npm run dev
```

## Production Notes

This is intentionally minimal for the MVP. Before opening access beyond trusted testers, add:

- authenticated users
- invite creation and room membership checks
- matchmaking state
- rate limits per user/device/IP
- moderation/reporting workflows
- audit logs for token issuance
