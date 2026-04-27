@preconcurrency import LiveKit
import SwiftUI

struct ParticipantVideoView: View {
  let slot: LiveKitRoomViewModel.VideoSlot
  var layoutMode: VideoView.LayoutMode = .fill

  var body: some View {
    ZStack(alignment: .bottomLeading) {
      SwiftUIVideoView(
        slot.track,
        layoutMode: layoutMode,
        mirrorMode: slot.isLocal && !slot.isScreenShare ? .mirror : .off
      )
      .background(Color.black)

      Text(slot.name)
        .font(.caption.weight(.semibold))
        .foregroundStyle(.white)
        .lineLimit(1)
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(.black.opacity(0.55), in: Capsule())
        .padding(8)
    }
    .accessibilityLabel(slot.name)
  }
}
