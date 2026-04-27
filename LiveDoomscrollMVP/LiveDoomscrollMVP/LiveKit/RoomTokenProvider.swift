import Foundation
import UIKit

struct RoomCredentials: Equatable {
  let url: String
  let token: String
}

protocol RoomTokenProviding {
  func credentials(for roomName: String) async throws -> RoomCredentials
}

struct RoomTokenProvider: RoomTokenProviding {
  enum TokenError: LocalizedError {
    case missingBackendURL
    case invalidBackendURL
    case backendError(String)
    case invalidResponse(Int?)

    var errorDescription: String? {
      switch self {
      case .missingBackendURL:
        "Set LiveKitTestConfig.backendURL before joining."
      case .invalidBackendURL:
        "LiveKitTestConfig.backendURL is not a valid URL."
      case .backendError(let message):
        message
      case .invalidResponse(let statusCode):
        if let statusCode {
          "The token backend returned HTTP \(statusCode)."
        } else {
          "The token backend returned an invalid response."
        }
      }
    }
  }

  private struct TokenRequest: Encodable {
    let roomName: String
    let participantName: String
  }

  private struct TokenResponse: Decodable {
    let liveKitUrl: String
    let token: String
  }

  private struct ErrorResponse: Decodable {
    let error: String
  }

  func credentials(for roomName: String) async throws -> RoomCredentials {
    let backendURLString = LiveKitTestConfig.backendURL.trimmingCharacters(
      in: .whitespacesAndNewlines
    )
    guard !backendURLString.contains("$("),
      !backendURLString.contains("<#"),
      !backendURLString.isEmpty
    else {
      throw TokenError.missingBackendURL
    }
    guard let backendURL = URL(string: backendURLString) else {
      throw TokenError.invalidBackendURL
    }

    var request = URLRequest(url: backendURL.appending(path: "v1/livekit/token"))
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try JSONEncoder().encode(
      TokenRequest(
        roomName: roomName,
        participantName: UIDevice.current.name
      )
    )

    let (data, response) = try await URLSession.shared.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse else {
      throw TokenError.invalidResponse(nil)
    }

    guard (200..<300).contains(httpResponse.statusCode) else {
      if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
        throw TokenError.backendError(errorResponse.error)
      }
      throw TokenError.invalidResponse(httpResponse.statusCode)
    }

    let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
    return RoomCredentials(url: tokenResponse.liveKitUrl, token: tokenResponse.token)
  }
}
