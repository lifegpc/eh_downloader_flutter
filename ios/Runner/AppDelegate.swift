import UIKit
import Flutter
import Foundation
import System

var urlMaps: [CInt: URL] = [:]

func openFile(result: FlutterResult, url: URL, readOnly: Bool, writeOnly: Bool, append: Bool, isSecure: Bool) {
  let mode = if readOnly && writeOnly {
    FileDescriptor.AccessMode.readWrite
  } else if readOnly {
    FileDescriptor.AccessMode.readOnly
  } else if writeOnly {
    FileDescriptor.AccessMode.writeOnly
  } else {
    FileDescriptor.AccessMode.readWrite
  }
  var opts = FileDescriptor.OpenOptions.init()
  if writeOnly {
    opts.insert(FileDescriptor.OpenOptions.create)
    if !readOnly {
      opts.insert(FileDescriptor.OpenOptions.truncate)
    }
  }
  if append {
    opts.insert(FileDescriptor.OpenOptions.append)
  }
  let permissions = FilePermissions(rawValue: 0o644);
  let uPath = if #available(iOS 16.0, *) {
    url.path(percentEncoded: false)
  } else {
    url.path
  }
  let path = FilePath(stringLiteral: uPath);
  do {
    let fd = try FileDescriptor.open(path, mode, options: opts, permissions: permissions)
    result(NSNumber(value: fd.rawValue))
    if isSecure {
      urlMaps[fd.rawValue] = url
    }
  } catch {
    result(FlutterError(code: "OEPN_FILE_FAILED", message: nil, details: nil))
    url.stopAccessingSecurityScopedResource()
  }
}

func extFromMimetype(mimeType: String) -> String? {
  switch (mimeType) {
  case "image/jpeg":
    return ".jpg"
  case "image/png":
    return ".png"
  case "image/webp":
    return ".webp"
  case "application/zip":
    return ".zip"
  default:
    return nil
  }
}

class FilePickerDelegate: NSObject, UIDocumentPickerDelegate {
  let readOnly: Bool
  let writeOnly: Bool
  let append: Bool
  let url: URL
  let result: FlutterResult
  init(readOnly: Bool, writeOnly: Bool, append: Bool, url: URL, result: @escaping FlutterResult) {
    self.readOnly = readOnly
    self.writeOnly = writeOnly
    self.append = append
    self.url = url
    self.result = result
  }

  func pickFile() {
    guard let viewController = UIApplication.shared.keyWindow?.rootViewController else {
      result(FlutterError(code: "fatal",
                          message: "Getting rootViewController failed",
                          details: nil))
      return
    }
    let con = UIDocumentPickerViewController(forExporting: [self.url])
    con.delegate = self
    viewController.present(con, animated: true, completion: nil)
    print("pickFile")
  }

  func handleUrl(_ url: URL) {
    if !url.isFileURL {
      result(FlutterError(code: "NOT_FILE_URL", message: nil, details: nil))
      return
    }
    if !url.startAccessingSecurityScopedResource() {
      result(FlutterError(code: "FAILED_TO_ACCESS_SECURITY_SCOPED_RESOURCE", message: nil, details: nil))
      return
    }
    openFile(result: result, url: url, readOnly: readOnly, writeOnly: writeOnly, append: append, isSecure: true)
  }

  func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    print("documentPicker")
    if let url = urls.first {
      handleUrl(url)
    } else {
      result(FlutterError(code: "USER_CANCELLED", message: nil, details: nil))}
  }

  func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
    print("documentPicker")
    handleUrl(url)
  }
  
  func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    result(FlutterError(code: "USER_CANCELLED", message: nil, details: nil))
    controller.dismiss(animated: true, completion: nil)
    print("documentPickerWasCancelled")
    try? FileManager.default.removeItem(at: url);
  }
}

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  var filePickerDelegate: FilePickerDelegate?
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let safChannel = FlutterMethodChannel(name: "lifegpc.eh_downloader_flutter/saf",
                                          binaryMessenger: controller.binaryMessenger)
    safChannel.setMethodCallHandler{(call, result) in
      switch call.method {
      case "openFile":
        if let args = call.arguments as? Array<Any>,
           let fileName = args[0] as? String,
           let dir = args[1] as? String,
           let mimeType = args[2] as? String,
           let readOnly = args[3] as? NSNumber,
           let writeOnly = args[4] as? NSNumber,
           let append = args[5] as? NSNumber,
           let saveAs = args[6] as? NSNumber {
            let ext = extFromMimetype(mimeType: mimeType)
            if saveAs.boolValue {
              let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last
              if path == nil {
                result(FlutterError(code: "FAILED_TO_GET_CACHE_DIRERCTORY", message: nil, details: nil))
                return
              }
              let dUrl = if #available(iOS 16.0, *) {
                URL.init(filePath: path!)
              } else {
                URL.init(fileURLWithPath: path!)
              }
              let url = dUrl.appendingPathComponent(fileName + (ext ?? ""))
              let uPath = if #available(iOS 16.0, *) {
                url.path(percentEncoded: false)
              } else {
                url.path
              }
              if !FileManager.default.createFile(atPath: uPath, contents: nil) {
                result(FlutterError(code: "FAILED_TO_CREATE_FILE", message: nil, details: nil))
                return
              }
              self.filePickerDelegate = FilePickerDelegate(readOnly: readOnly.boolValue, writeOnly: writeOnly.boolValue, append: append.boolValue, url: url, result: result)
              self.filePickerDelegate!.pickFile()
            } else {
              result(FlutterMethodNotImplemented)
            }
           } else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: nil, details: nil))
           }
      case "writeFile":
        if let args = call.arguments as? Array<Any>,
           let fd = args[0] as? NSNumber,
           let data = args[1] as? FlutterStandardTypedData {
          let fD = FileDescriptor(rawValue: fd.int32Value)
          do {
            let readed = try data.data.withUnsafeBytes{ (re) in
              try fD.write(re)
            }
            result(NSNumber(value: readed))
          } catch {
            result(FlutterError(code: "WRITE_FILE_FAILED", message: nil, details: nil))
          }
        } else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: nil, details: nil))
        }
      case "closeFile":
        if let args = call.arguments as? Array<Any>,
           let fd = args[0] as? NSNumber {
          let fD = FileDescriptor(rawValue: fd.int32Value)
          do {
            try fD.close()
            result(nil)
          } catch {
            result(FlutterError(code: "CLOSE_FILE_FAILED", message: nil, details: nil))
          }
          if let url = urlMaps[fd.int32Value] {
            url.stopAccessingSecurityScopedResource()
            urlMaps.removeValue(forKey: fd.int32Value)
          }
        } else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: nil, details: nil))
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
