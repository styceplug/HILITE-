import AVFoundation
import Flutter

class VideoTrimmer: NSObject, FlutterPlugin {
  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "video_trimmer_native", binaryMessenger: registrar.messenger())
    let instance = VideoTrimmer()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "trimVideo",
          let args = call.arguments as? [String: Any],
          let inputPath = args["inputPath"] as? String,
          let startMs = args["startMs"] as? Int,
          let durationMs = args["durationMs"] as? Int else {
      result(FlutterError(code: "BAD_ARGS", message: "Missing arguments", details: nil))
      return
    }

    let inputURL = URL(fileURLWithPath: inputPath)
    let outputURL = URL(fileURLWithPath: NSTemporaryDirectory())
      .appendingPathComponent("trimmed_\(Int(Date().timeIntervalSince1970 * 1000)).mp4")

    let asset = AVAsset(url: inputURL)
    guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {
      result(FlutterError(code: "EXPORT_FAILED", message: "Could not create export session", details: nil))
      return
    }

    let startTime = CMTime(value: CMTimeValue(startMs), timescale: 1000)
    let duration = CMTime(value: CMTimeValue(durationMs), timescale: 1000)
    exportSession.outputURL = outputURL
    exportSession.outputFileType = .mp4
    exportSession.timeRange = CMTimeRange(start: startTime, duration: duration)

    exportSession.exportAsynchronously {
      DispatchQueue.main.async {
        switch exportSession.status {
        case .completed:
          result(outputURL.path)
        case .failed:
          result(FlutterError(code: "EXPORT_FAILED", message: exportSession.error?.localizedDescription, details: nil))
        case .cancelled:
          result(FlutterError(code: "CANCELLED", message: "Export cancelled", details: nil))
        default:
          result(FlutterError(code: "UNKNOWN", message: "Unknown export status", details: nil))
        }
      }
    }
  }
}