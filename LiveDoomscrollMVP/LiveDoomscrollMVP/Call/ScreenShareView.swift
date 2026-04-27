import SwiftUI

struct ScreenShareView: View {
  let slot: LiveKitRoomViewModel.VideoSlot

  var body: some View {
    ParticipantVideoView(slot: slot, layoutMode: .fit)
      .ignoresSafeArea()
      .overlay(alignment: .topLeading) {
        HStack(spacing: 8) {
          Image(systemName: "rectangle.on.rectangle")
          Text(slot.name)
        }
        .font(.footnote.weight(.semibold))
        .foregroundStyle(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.black.opacity(0.5), in: Capsule())
        .padding(.top, 16)
        .padding(.leading, 16)
      }
  }
}
