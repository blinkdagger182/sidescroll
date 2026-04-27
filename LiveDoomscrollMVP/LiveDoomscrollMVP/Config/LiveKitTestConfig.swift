import Foundation

enum LiveKitTestConfig {
  static let defaultRoomName = "doomscroll-test-room"

  // Replace SIDESCROLL_BACKEND_URL in the target build settings after deploying
  // the backend in ../backend, for example https://api.sidescroll.example.com.
  static let backendURL: String = {
    let value = Bundle.main.object(forInfoDictionaryKey: "SIDESCROLL_BACKEND_URL") as? String
    return value ?? ""
  }()
}
