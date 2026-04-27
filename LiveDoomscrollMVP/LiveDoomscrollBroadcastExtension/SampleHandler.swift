import LiveKit
import ReplayKit

#if os(iOS)
  @available(macCatalyst 13.1, *)
  final class SampleHandler: LKSampleHandler {
    override var enableLogging: Bool { true }
  }
#endif
