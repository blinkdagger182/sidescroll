@preconcurrency import LiveKit
import SwiftUI

@MainActor
final class LiveKitRoomViewModel: NSObject, ObservableObject {
  enum CallState: Equatable {
    case idle
    case connecting
    case connected
    case disconnecting
    case failed(String)

    var label: String {
      switch self {
      case .idle: "Ready"
      case .connecting: "Joining..."
      case .connected: "Live"
      case .disconnecting: "Ending..."
      case .failed(let message): message
      }
    }
  }

  struct VideoSlot: Identifiable, Equatable {
    let id: String
    let name: String
    let isLocal: Bool
    let isScreenShare: Bool
    let track: VideoTrack

    static func == (lhs: VideoSlot, rhs: VideoSlot) -> Bool {
      lhs.id == rhs.id && lhs.isScreenShare == rhs.isScreenShare
    }
  }

  @Published var roomName = LiveKitTestConfig.defaultRoomName
  @Published private(set) var callState: CallState = .idle
  @Published private(set) var cameraSlots: [VideoSlot] = []
  @Published private(set) var screenShareSlot: VideoSlot?
  @Published private(set) var isMicrophoneEnabled = false
  @Published private(set) var isCameraEnabled = false
  @Published private(set) var isScreenShareEnabled = false
  @Published private(set) var lastReaction: String?
  @Published private(set) var statusMessage: String?

  private let room: Room
  private let tokenProvider: RoomTokenProviding

  init(room: Room = Room(), tokenProvider: RoomTokenProviding = RoomTokenProvider()) {
    self.room = room
    self.tokenProvider = tokenProvider
    super.init()
    room.add(delegate: self)
  }

  deinit {
    room.remove(delegate: self)
  }

  func joinRoom() {
    guard case .connecting = callState else {
      Task { await connect() }
      return
    }
  }

  func leaveRoom() {
    Task {
      callState = .disconnecting
      await room.disconnect()
      cameraSlots = []
      screenShareSlot = nil
      isMicrophoneEnabled = false
      isCameraEnabled = false
      isScreenShareEnabled = false
      callState = .idle
    }
  }

  func toggleMicrophone() {
    Task {
      do {
        try await room.localParticipant.setMicrophone(enabled: !isMicrophoneEnabled)
        refreshTracks()
      } catch {
        callState = .failed("Mic error: \(error.localizedDescription)")
      }
    }
  }

  func toggleCamera() {
    Task {
      do {
        try await room.localParticipant.setCamera(enabled: !isCameraEnabled)
        refreshTracks()
      } catch {
        callState = .failed("Camera error: \(error.localizedDescription)")
      }
    }
  }

  func toggleScreenShare() {
    Task {
      do {
        // On iOS this triggers LiveKit's ReplayKit flow. For full-device capture
        // outside this app, add the Broadcast Upload Extension described in docs.
        if isScreenShareEnabled {
          #if os(iOS)
            BroadcastManager.shared.requestStop()
          #endif
          try await room.localParticipant.setScreenShare(enabled: false)
        } else {
          try await room.localParticipant.setScreenShare(enabled: true)
        }
        refreshTracks()
      } catch {
        callState = .failed("Screen share error: \(error.localizedDescription)")
      }
    }
  }

  func sendReaction(_ emoji: String = "🔥") {
    lastReaction = emoji
    Task {
      try? await Task.sleep(for: .seconds(1.4))
      if lastReaction == emoji {
        lastReaction = nil
      }
    }

    // Backend TODO: publish reactions via LiveKit data packets or an app server so
    // reactions are synchronized and moderation/reporting can inspect abuse.
  }

  private func connect() async {
    do {
      callState = .connecting
      let credentials = try await tokenProvider.credentials(for: roomName)

      try await room.connect(
        url: credentials.url,
        token: credentials.token,
        connectOptions: ConnectOptions(enableMicrophone: true),
        roomOptions: RoomOptions(
          defaultScreenShareCaptureOptions: ScreenShareCaptureOptions(appAudio: true)
        )
      )
      callState = .connected

      do {
        try await room.localParticipant.setMicrophone(enabled: true)
      } catch {
        statusMessage = "Mic unavailable: \(error.localizedDescription)"
      }

      do {
        try await room.localParticipant.setCamera(enabled: true)
      } catch {
        // iOS Simulator commonly has no camera capture device. Keep the
        // participant connected so it can still receive remote video.
        statusMessage = "Camera unavailable: \(error.localizedDescription)"
      }

      refreshTracks()
    } catch {
      callState = .failed(error.localizedDescription)
      await room.disconnect()
      refreshTracks()
    }
  }

  private func refreshTracks() {
    isMicrophoneEnabled = room.localParticipant.isMicrophoneEnabled()
    isCameraEnabled = room.localParticipant.isCameraEnabled()
    isScreenShareEnabled = room.localParticipant.isScreenShareEnabled()

    var cameras: [VideoSlot] = []

    if let localCamera = room.localParticipant.firstCameraVideoTrack {
      cameras.append(
        VideoSlot(
          id: "local-camera",
          name: "You",
          isLocal: true,
          isScreenShare: false,
          track: localCamera
        )
      )
    }

    var primaryShare: VideoSlot?
    if let localShare = room.localParticipant.firstScreenShareVideoTrack {
      primaryShare = VideoSlot(
        id: "local-screen",
        name: "Your screen",
        isLocal: true,
        isScreenShare: true,
        track: localShare
      )
    }

    for participant in room.remoteParticipants.values.sorted(by: {
      ($0.identity?.stringValue ?? "") < ($1.identity?.stringValue ?? "")
    }) {
      let displayName = participant.name ?? participant.identity?.stringValue ?? "Guest"

      if let remoteShare = participant.firstScreenShareVideoTrack {
        primaryShare = VideoSlot(
          id: "\(participant.sid?.stringValue ?? displayName)-screen",
          name: "\(displayName)'s screen",
          isLocal: false,
          isScreenShare: true,
          track: remoteShare
        )
      }

      if let remoteCamera = participant.firstCameraVideoTrack {
        cameras.append(
          VideoSlot(
            id: "\(participant.sid?.stringValue ?? displayName)-camera",
            name: displayName,
            isLocal: false,
            isScreenShare: false,
            track: remoteCamera
          )
        )
      }
    }

    cameraSlots = cameras
    screenShareSlot = primaryShare
  }
}

extension LiveKitRoomViewModel: RoomDelegate {
  nonisolated func room(
    _: Room, didUpdateConnectionState connectionState: ConnectionState,
    from _: ConnectionState
  ) {
    Task { @MainActor in
      switch connectionState {
      case .disconnected:
        self.callState = .idle
      case .connecting:
        self.callState = .connecting
      case .reconnecting:
        self.callState = .connecting
      case .connected:
        self.callState = .connected
      case .disconnecting:
        self.callState = .disconnecting
      @unknown default:
        self.callState = .failed("Unknown connection state")
      }
      self.refreshTracks()
    }
  }

  nonisolated func room(_: Room, didDisconnectWithError error: LiveKitError?) {
    Task { @MainActor in
      if let error {
        self.callState = .failed("Disconnected: \(error.localizedDescription)")
      } else {
        self.callState = .idle
      }
      self.refreshTracks()
    }
  }

  nonisolated func room(
    _: Room, participant _: LocalParticipant, didPublishTrack _: LocalTrackPublication
  ) {
    Task { @MainActor in self.refreshTracks() }
  }

  nonisolated func room(
    _: Room, participant _: LocalParticipant, didUnpublishTrack _: LocalTrackPublication
  ) {
    Task { @MainActor in self.refreshTracks() }
  }

  nonisolated func room(
    _: Room, participant _: RemoteParticipant, didSubscribeTrack _: RemoteTrackPublication
  ) {
    Task { @MainActor in self.refreshTracks() }
  }

  nonisolated func room(
    _: Room, participant _: RemoteParticipant, didUnsubscribeTrack _: RemoteTrackPublication
  ) {
    Task { @MainActor in self.refreshTracks() }
  }

  nonisolated func room(
    _: Room, participant _: RemoteParticipant, didPublishTrack _: RemoteTrackPublication
  ) {
    Task { @MainActor in self.refreshTracks() }
  }

  nonisolated func room(
    _: Room, participant _: RemoteParticipant, didUnpublishTrack _: RemoteTrackPublication
  ) {
    Task { @MainActor in self.refreshTracks() }
  }

  nonisolated func room(_: Room, participantDidConnect _: RemoteParticipant) {
    Task { @MainActor in self.refreshTracks() }
  }

  nonisolated func room(_: Room, participantDidDisconnect _: RemoteParticipant) {
    Task { @MainActor in self.refreshTracks() }
  }
}
