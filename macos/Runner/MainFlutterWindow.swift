import Cocoa
import FlutterMacOS
import Foundation
import System
import UniformTypeIdentifiers

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

func openFile(result: FlutterResult, fn: String, readOnly: Bool, writeOnly: Bool, append: Bool) {
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
  let path = FilePath(stringLiteral: fn);
  do {
    let fd = try FileDescriptor.open(path, mode, options: opts, permissions: permissions)
    result(NSNumber(value: fd.rawValue))
  } catch {
    result(FlutterError(code: "OEPN_FILE_FAILED", message: nil, details: nil))
  }
}

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)
    
    let safChannel = FlutterMethodChannel(
      name: "lifegpc.eh_downloader_flutter/saf",
      binaryMessenger: flutterViewController.engine.binaryMessenger)
    safChannel.setMethodCallHandler { (call, result) in
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
            let panel = NSSavePanel()
            panel.canCreateDirectories = true
            panel.canSelectHiddenExtension = true
            if let typ = UTType.init(mimeType: mimeType) {
              panel.allowedContentTypes = [typ]
            }
            panel.allowsOtherFileTypes = true
            panel.isExtensionHidden = false
            panel.nameFieldStringValue = fileName + (ext ?? "")
            panel.begin { (res) in
              if res == NSApplication.ModalResponse.OK {
                if let fn = panel.url {
                  if fn.isFileURL {
                    let fp = if #available(macOS 13.0, *) {
                      fn.path(percentEncoded: false)
                    } else {
                      fn.path
                    }
                    return openFile(result: result, fn: fp, readOnly: readOnly.boolValue, writeOnly: writeOnly.boolValue, append: append.boolValue)
                  }
                }
              }
              result(FlutterError(code: "USER_CANCELED", message: nil, details: nil))
            }
          } else {
            let fn = NSString.path(withComponents: [dir, fileName]) + (ext ?? "")
            openFile(result: result, fn: fn, readOnly: readOnly.boolValue, writeOnly: writeOnly.boolValue, append: append.boolValue)
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
        } else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: nil, details: nil))
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    let deviceChannel = FlutterMethodChannel(
      name: "lifegpc.eh_downloader_flutter/device",
      binaryMessenger: flutterViewController.engine.binaryMessenger)
    deviceChannel.setMethodCallHandler { (call, result) in
      switch call.method {
      case "deviceName":
        result(Host.current().localizedName)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    
    RegisterGeneratedPlugins(registry: flutterViewController)
    
    super.awakeFromNib()
  }
}
