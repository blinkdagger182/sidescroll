import SwiftUI

struct CameraBubbleView: View {
  let slot: LiveKitRoomViewModel.VideoSlot

  var body: some View {
    ParticipantVideoView(slot: slot)
      .frame(width: 132, height: 178)
      .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
      .overlay {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
          .stroke(.white.opacity(0.18), lineWidth: 1)
      }
      .shadow(color: .black.opacity(0.35), radius: 18, y: 10)
  }
}
