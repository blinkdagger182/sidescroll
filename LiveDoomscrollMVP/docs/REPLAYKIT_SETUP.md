# ReplayKit Broadcast Extension Setup

The app now includes a `LiveDoomscrollBroadcastExtension` target in the Xcode project. The main app calls `room.localParticipant.setScreenShare(enabled:)`; on iOS, LiveKit opens the system broadcast picker, waits for the user to start the broadcast, then publishes the ReplayKit frames as a screen-share video track.

## Required Xcode Checks

1. Open `LiveDoomscrollMVP.xcodeproj`.
2. Select the `LiveDoomscrollMVP` app target and confirm signing works for your Apple team.
3. Select the `LiveDoomscrollBroadcastExtension` target and confirm signing works for the same Apple team.
4. Confirm the extension bundle identifier is:
   `com.riskcreatives.sidescroll.broadcast`
5. Confirm App Groups are enabled on both targets:
   `group.com.riskcreatives.sidescroll`
6. Build and run on a physical iPhone. ReplayKit full-device broadcast is not a useful simulator test.

## Product Notes

- iOS broadcast is system-wide after the user starts it. The user chooses `SideScroll Broadcast`, taps `Start Broadcast`, then opens Instagram, YouTube, Safari, or another app. The recipient sees whatever is visible on the broadcaster's device.
- iOS does not expose desktop-style third-party app/window selection to this app. Some apps or protected video content may block capture or show black frames.
- The app button starts LiveKit's iOS screen-share path. Once the Broadcast Upload Extension is installed and signed, iOS presents the broadcast picker/start flow.
- The main app plist already declares `RTCAppGroupIdentifier=group.com.riskcreatives.sidescroll` and `RTCScreenSharingExtension=com.riskcreatives.sidescroll.broadcast` so LiveKit can find the extension.
- A real backend must generate a token that allows publishing camera, microphone, and screen-share tracks into the selected private room.
- Use separate participant identities per phone, for example `host-123` and `viewer-456`.
- Moderation/reporting should be implemented server-side before public release because participants can expose third-party app content through screen sharing.
