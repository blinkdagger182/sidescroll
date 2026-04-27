import SwiftUI

struct CallRoomView: View {
  @StateObject private var viewModel = LiveKitRoomViewModel()

  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()

      if case .connected = viewModel.callState {
        inCallLayout
      } else {
        joinLayout
      }

      if let reaction = viewModel.lastReaction {
        Text(reaction)
          .font(.system(size: 72))
          .transition(.scale.combined(with: .opacity))
          .padding(.bottom, 150)
      }
    }
    .animation(.spring(response: 0.32, dampingFraction: 0.82), value: viewModel.lastReaction)
  }

  private var joinLayout: some View {
    VStack(spacing: 20) {
      VStack(spacing: 8) {
        Text("Live Doomscroll")
          .font(.system(size: 34, weight: .bold))
          .foregroundStyle(.white)

        Text(viewModel.callState.label)
          .font(.callout.weight(.medium))
          .foregroundStyle(.white.opacity(0.68))
          .multilineTextAlignment(.center)
      }

      VStack(spacing: 12) {
        TextField("Room name", text: $viewModel.roomName)
          .textInputAutocapitalization(.never)
          .autocorrectionDisabled()
          .foregroundStyle(.white)
          .padding(.horizontal, 16)
          .frame(height: 52)
          .background(
            .white.opacity(0.1), in: RoundedRectangle(cornerRadius: 12, style: .continuous)
          )
          .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
              .stroke(.white.opacity(0.14), lineWidth: 1)
          }

        Button {
          viewModel.joinRoom()
        } label: {
          HStack {
            Image(systemName: "video.fill")
            Text("Join Room")
          }
          .font(.headline)
          .foregroundStyle(.black)
          .frame(maxWidth: .infinity)
          .frame(height: 52)
          .background(.white, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .disabled(viewModel.roomName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
      }
      .frame(maxWidth: 420)
    }
    .padding(24)
  }

  private var inCallLayout: some View {
    ZStack(alignment: .bottom) {
      if let screenShareSlot = viewModel.screenShareSlot {
        ScreenShareView(slot: screenShareSlot)
      } else {
        normalVideoLayout
      }

      VStack(spacing: 18) {
        if let statusMessage = viewModel.statusMessage {
          Text(statusMessage)
            .font(.caption.weight(.medium))
            .foregroundStyle(.white.opacity(0.78))
            .lineLimit(2)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.white.opacity(0.12), in: Capsule())
        }

        cameraBubbles

        CallControlsView(
          isMuted: !viewModel.isMicrophoneEnabled,
          isCameraEnabled: viewModel.isCameraEnabled,
          isScreenShareEnabled: viewModel.isScreenShareEnabled,
          onToggleMic: viewModel.toggleMicrophone,
          onToggleCamera: viewModel.toggleCamera,
          onToggleScreenShare: viewModel.toggleScreenShare,
          onReact: { viewModel.sendReaction() },
          onEnd: viewModel.leaveRoom
        )
      }
      .padding(.horizontal, 16)
      .padding(.bottom, 18)
    }
    .overlay(alignment: .topLeading) {
      Text(viewModel.callState.label)
        .font(.caption.weight(.semibold))
        .foregroundStyle(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.green.opacity(0.55), in: Capsule())
        .padding(.top, 16)
        .padding(.leading, 16)
    }
  }

  private var normalVideoLayout: some View {
    GeometryReader { proxy in
      let columns = viewModel.cameraSlots.count > 1 ? 2 : 1
      LazyVGrid(
        columns: Array(repeating: GridItem(.flexible(), spacing: 1), count: columns), spacing: 1
      ) {
        ForEach(viewModel.cameraSlots) { slot in
          ParticipantVideoView(slot: slot)
            .frame(height: max(260, proxy.size.height / CGFloat(columns)))
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .overlay {
      if viewModel.cameraSlots.isEmpty {
        VStack(spacing: 10) {
          Image(systemName: "video.slash")
            .font(.system(size: 34, weight: .semibold))
          Text("Waiting for camera video")
            .font(.headline)
        }
        .foregroundStyle(.white.opacity(0.7))
      }
    }
  }

  private var cameraBubbles: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 12) {
        ForEach(viewModel.cameraSlots) { slot in
          CameraBubbleView(slot: slot)
        }
      }
      .padding(.horizontal, 8)
    }
    .frame(height: 188)
  }
}

#Preview {
  CallRoomView()
}
