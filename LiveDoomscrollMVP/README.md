# Live Doomscroll Rooms MVP

Native SwiftUI iOS MVP for two-person LiveKit rooms with camera bubbles and ReplayKit screen sharing.

## Current Workspace Inspection

- App type before this change: no existing app/project in `/Users/rizhanruslan/sidescroll`.
- Project structure before this change: only `sidescroll.code-workspace`.
- UI framework before this change: none.
- Call/video code before this change: none.
- Package manager before this change: none.

This MVP is isolated under `LiveDoomscrollMVP`.

## Run

1. Open `LiveDoomscrollMVP.xcodeproj` in Xcode.
2. Set a development team/signing identity.
3. Edit `LiveDoomscrollMVP/Config/LiveKitTestConfig.swift`.
4. Build `LiveDoomscrollMVP` on two physical iPhones.
5. Use tokens for two different participant identities in the same LiveKit room.

## Required Values

- `LiveKitTestConfig.backendURL`: token backend URL. The current Coolify MVP URL is `http://pqiqkehqtiwtl8dqbt90usbn.5.223.92.119.sslip.io`.
- Backend env: `LIVEKIT_URL`, `LIVEKIT_API_KEY`, `LIVEKIT_API_SECRET`.

The backend is in `backend/` and is ready for Coolify Dockerfile deployment.
