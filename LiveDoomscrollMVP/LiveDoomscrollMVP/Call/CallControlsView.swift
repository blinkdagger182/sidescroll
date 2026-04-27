import SwiftUI

struct CallControlsView: View {
  let isMuted: Bool
  let isCameraEnabled: Bool
  let isScreenShareEnabled: Bool
  let onToggleMic: () -> Void
  let onToggleCamera: () -> Void
  let onToggleScreenShare: () -> Void
  let onReact: () -> Void
  let onEnd: () -> Void

  var body: some View {
    HStack(spacing: 14) {
      controlButton(
        systemName: isMuted ? "mic.slash.fill" : "mic.fill",
        tint: isMuted ? .white.opacity(0.16) : .white.opacity(0.22),
        action: onToggleMic
      )
      .accessibilityLabel(isMuted ? "Unmute microphone" : "Mute microphone")

      controlButton(
        systemName: isCameraEnabled ? "video.fill" : "video.slash.fill",
        tint: isCameraEnabled ? .white.opacity(0.22) : .white.opacity(0.16),
        action: onToggleCamera
      )
      .accessibilityLabel(isCameraEnabled ? "Turn camera off" : "Turn camera on")

      controlButton(
        systemName: isScreenShareEnabled ? "rectangle.slash" : "rectangle.on.rectangle",
        tint: isScreenShareEnabled ? .green.opacity(0.48) : .white.opacity(0.22),
        action: onToggleScreenShare
      )
      .accessibilityLabel(isScreenShareEnabled ? "Stop screen share" : "Start screen share")

      controlButton(systemName: "flame.fill", tint: .orange.opacity(0.72), action: onReact)
        .accessibilityLabel("Send reaction")

      controlButton(systemName: "phone.down.fill", tint: .red, action: onEnd)
        .accessibilityLabel("End call")
    }
    .padding(.horizontal, 18)
    .padding(.vertical, 14)
    .background(.ultraThinMaterial, in: Capsule())
    .overlay {
      Capsule().stroke(.white.opacity(0.12), lineWidth: 1)
    }
  }

  private func controlButton(systemName: String, tint: Color, action: @escaping () -> Void)
    -> some View
  {
    Button(action: action) {
      Image(systemName: systemName)
        .font(.system(size: 18, weight: .semibold))
        .foregroundStyle(.white)
        .frame(width: 48, height: 48)
        .background(tint, in: Circle())
    }
    .buttonStyle(.plain)
  }
}
