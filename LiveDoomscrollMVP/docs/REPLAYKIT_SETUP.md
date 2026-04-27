# ReplayKit Broadcast Extension Setup

The main app source is wired to call `room.localParticipant.setScreenShare(enabled:)`. For full-device sharing while the user opens Instagram, YouTube, Safari, or other apps, finish the Broadcast Upload Extension setup in Xcode.

## Required Xcode Steps

1. Open `LiveDoomscrollMVP.xcodeproj`.
2. Add a new target: `File > New > Target > Broadcast Upload Extension`.
3. Name it `LiveDoomscrollBroadcastExtension`.
4. Set its bundle identifier to:
   `com.riskcreatives.sidescroll.broadcast`
5. Replace the generated `SampleHandler.swift` with:
   `LiveDoomscrollBroadcastExtension/SampleHandler.swift`
6. Add the same LiveKit Swift Package dependency to the extension target:
   `https://github.com/livekit/client-sdk-swift.git`
7. Add App Groups to both targets:
   `group.com.riskcreatives.sidescroll`
8. In the main app target, add the App Group entitlement with the same group.
9. In the extension target, add the App Group entitlement with the same group.
10. Build and run on physical iPhones. ReplayKit full-device broadcast is not a useful simulator test.

## Product Notes

- The app button starts LiveKit's iOS screen-share path. Once the Broadcast Upload Extension is installed and signed, iOS presents the broadcast picker/start flow.
- The main app plist already declares `RTCAppGroupIdentifier=group.com.riskcreatives.sidescroll` and `RTCScreenSharingExtension=com.riskcreatives.sidescroll.broadcast` so LiveKit can find the extension.
- A real backend must generate a token that allows publishing camera, microphone, and screen-share tracks into the selected private room.
- Use separate participant identities per phone, for example `host-123` and `viewer-456`.
- Moderation/reporting should be implemented server-side before public release because participants can expose third-party app content through screen sharing.
