import Flutter
import UIKit

public class M3u8Player: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "m3u8_player", binaryMessenger: registrar.messenger())
    let instance = M3u8Player()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }
  
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    // Implement your functionality here
    result(FlutterMethodNotImplemented)
  }
}