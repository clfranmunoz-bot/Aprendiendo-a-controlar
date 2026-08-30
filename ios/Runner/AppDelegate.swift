import Flutter
import UIKit
import Photos

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    
    if let controller = window?.rootViewController as? FlutterViewController {
      let galleryChannel = FlutterMethodChannel(name: "com.example.aprender_a_controlar/gallery",
                                                binaryMessenger: controller.binaryMessenger)
      
      galleryChannel.setMethodCallHandler({
        (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        if call.method == "saveImage" {
          guard let args = call.arguments as? [String: Any],
                let imagePath = args["path"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Path argument is missing", details: nil))
            return
          }
          
          self.saveImageToGallery(path: imagePath, result: result)
        } else {
          result(FlutterMethodNotImplemented)
        }
      })
    }
    
    return result
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
  
  private func saveImageToGallery(path: String, result: @escaping FlutterResult) {
    let url = URL(fileURLWithPath: path)
    
    let status = PHPhotoLibrary.authorizationStatus()
    if status == .authorized {
      self.performSave(url: url, result: result)
    } else if status == .notDetermined {
      PHPhotoLibrary.requestAuthorization { newStatus in
        if newStatus == .authorized {
          self.performSave(url: url, result: result)
        } else {
          result(FlutterError(code: "PERMISSION_DENIED", message: "Photo library access denied", details: nil))
        }
      }
    } else {
      result(FlutterError(code: "PERMISSION_DENIED", message: "Photo library access denied", details: nil))
    }
  }
  
  private func performSave(url: URL, result: @escaping FlutterResult) {
    PHPhotoLibrary.shared().performChanges({
      PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: url)
    }) { success, error in
      if success {
        result(true)
      } else {
        result(FlutterError(code: "SAVE_FAILED", message: error?.localizedDescription ?? "Failed to save image", details: nil))
      }
    }
  }
}
