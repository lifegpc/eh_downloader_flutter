#include "flutter_window.h"
#include <flutter/event_channel.h>
#include <flutter/event_sink.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <windows.h>

#include <optional>

#include "flutter/generated_plugin_registrant.h"

#include <fcntl.h>
#include <io.h>
#include <regex>
#include <memory>
#include "err.h"
#include "fileop.h"
#include "wchar_util.h"

using namespace std;

#define MAX_PATH_SIZE 32768

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

void filterFilename(std::wstring& fileName) {
    const static std::wregex re(L"[/\\\\:\\*\\?\"\\<\\>\\|]");
    fileName = std::regex_replace(fileName, re, L"_");
}

void filterDirname(std::string& dirName) {
    const static std::regex re("[:\\*\\?\"\\<\\>\\|]");
    dirName = std::regex_replace(dirName, re, "_");
}

void updateDataFromMimeType(std::wstring& defExt, std::wstring& filter, std::string mimeType) {
  if (mimeType == "image/jpeg") {
    filter.append(std::wstring(L"JPEG File(*.jpg)\0*.jpg\0", 23));
    defExt = L"jpg";
  } else if (mimeType == "image/png") {
    filter.append(std::wstring(L"PNG File(*.png)\0*.png\0", 22));
    defExt = L"png";
  } else if (mimeType == "image/gif") {
    filter.append(std::wstring(L"GIF File(*.gif)\0*.gif\0", 22));
    defExt = L"gif";
  } else if (mimeType == "application/zip") {
    filter.append(std::wstring(L"ZIP File(*.zip)\0*.zip\0", 22));
    defExt = L"zip";
  }
}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());

  flutter::MethodChannel<> channel(
      flutter_controller_->engine()->messenger(), "lifegpc.eh_downloader_flutter/path",
      &flutter::StandardMethodCodec::GetInstance());
  channel.SetMethodCallHandler(
      [](const flutter::MethodCall<>& call,
         std::unique_ptr<flutter::MethodResult<>> result) {
        if (call.method_name() == "getCurrentExe") {
          std::string current;
          wchar_t tmp[MAX_PATH_SIZE];
          if (!GetModuleFileNameW(nullptr, tmp, MAX_PATH_SIZE)) {
            result->Error("UNAVAILABLE", "Failed to get module file name.");
            return;
          }
          if (!wchar_util::wstr_to_str(current, tmp, CP_UTF8)) {
            result->Error("UNAVAILABLE", "Failed to convert module file name to UTF-8.");
            return;
          }
          result->Success(current);
        } else {
          result->NotImplemented();
        }
      });
  flutter::MethodChannel<> saf(flutter_controller_->engine()->messenger(), "lifegpc.eh_downloader_flutter/saf",
      &flutter::StandardMethodCodec::GetInstance());
  saf.SetMethodCallHandler([&](const flutter::MethodCall<>& call, std::unique_ptr<flutter::MethodResult<>> result) {
          if (call.method_name() == "closeFile") {
            auto args = std::get_if<flutter::EncodableList>(call.arguments());
            auto fd = std::get_if<int>(&args->at(0));
            if (!fd) {
              result->Error("INVALID_ARGUMENT", "Invalid arguments.");
              return;
            }
            fileop::close(*fd);
            result->Success();
          } else if (call.method_name() == "openFile") {
            auto args = std::get_if<flutter::EncodableList>(call.arguments());
            auto fileName = std::get_if<std::string>(&args->at(0));
            auto dir = std::get_if<std::string>(&args->at(1));
            auto mimeType = std::get_if<std::string>(&args->at(2));
            auto readOnly = std::get_if<bool>(&args->at(3));
            auto writeOnly = std::get_if<bool>(&args->at(4));
            auto append = std::get_if<bool>(&args->at(5));
            auto saveAs = std::get_if<bool>(&args->at(6));
            if (!fileName || !dir || !mimeType || !readOnly || !writeOnly || !append || !saveAs) {
              result->Error("INVALID_ARGUMENT", "Invalid arguments.");
              return;
            }
            std::string fn;
            if (saveAs) {
              std::wstring wFileName;
              if (!wchar_util::str_to_wstr(wFileName, *fileName, CP_UTF8)) {
                result->Error("ERROR", "Failed to convert file name to wstring.");
                return;
              }
              filterFilename(wFileName);
              std::wstring wDir;
              if (!dir->empty() && !wchar_util::str_to_wstr(wDir, *dir, CP_UTF8)) {
                result->Error("ERROR", "Failed to convert dir to wstring.");
                return;
              }
              OPENFILENAMEW ofn;
              ZeroMemory(&ofn, sizeof(ofn));
              ofn.lStructSize = sizeof(ofn);
              ofn.hwndOwner = Win32Window::GetHandle();
              std::wstring filter;
              std::wstring defExt;
              updateDataFromMimeType(defExt, filter, *mimeType);
              filter.append(std::wstring(L"All Files\0*.*\0\0", 15));
              ofn.lpstrFilter = filter.c_str();
              ofn.lpstrDefExt = defExt.empty() ? nullptr : defExt.c_str();
              wchar_t wFileNameBuf[MAX_PATH_SIZE];
              memcpy(wFileNameBuf, wFileName.c_str(), (wFileName.size() + 1) * sizeof(wchar_t));
              ofn.lpstrFile = wFileNameBuf;
              ofn.nMaxFile = MAX_PATH_SIZE;
              ofn.lpstrInitialDir = wDir.empty() ? nullptr : wDir.c_str();
              ofn.Flags = OFN_DONTADDTORECENT | OFN_NONETWORKBUTTON | OFN_NOREADONLYRETURN | OFN_OVERWRITEPROMPT;
              if (!GetSaveFileNameW(&ofn)) {
                result->Error("ERROR", "Failed to get file name.");
                return;
              }
              if (!wchar_util::wstr_to_str(fn, wFileNameBuf, CP_UTF8)) {
                result->Error("ERROR", "Failed to convert file name to UTF-8.");
                return;
              }
            } else {
              fn = fileop::join(*dir, *fileName);
              filterDirname(fn);
            }
            int fd = 0;
            int flags = _O_BINARY;
            if (*readOnly && *writeOnly) {
              flags |= _O_RDWR | _O_CREAT;
            } else if (*readOnly) {
              flags |= _O_RDONLY;
            } else if (*writeOnly) {
              flags |= _O_WRONLY | _O_CREAT | _O_TRUNC;
            }
            if (*append) {
              flags |= _O_APPEND;
            }
            int e = fileop::open(fn, fd, flags, _SH_DENYRW, _S_IREAD | _S_IWRITE);
            if (e) {
              std::string errmsg;
              if (!err::get_errno_message(errmsg, e)) {
                errmsg = "Unknown error.";
              }
              result->Error("ERROR", "Failed to open file: " + errmsg);
              return;
            }
            result->Success(fd);
          } else if (call.method_name() == "writeFile") {
            auto args = std::get_if<flutter::EncodableList>(call.arguments());
            auto fd = std::get_if<int>(&args->at(0));
            auto data = std::get_if<std::vector<uint8_t>>(&args->at(1));
            if (!fd || !data) {
              result->Error("INVALID_ARGUMENT", "Invalid arguments.");
              return;
            }
            int num = _write(*fd, data->data(), (unsigned int)data->size());
            if (num == -1) {
              std::string errmsg;
              if (!err::get_errno_message(errmsg, errno)) {
                errmsg = "Unknown error.";
              }
              result->Error("ERROR", "Failed to write file:" + errmsg);
              return;
            }
            result->Success(num);
          } else if (call.method_name() == "readFile") {
            auto args = std::get_if<flutter::EncodableList>(call.arguments());
            auto fd = std::get_if<int>(&args->at(0));
            auto maxlen = std::get_if<int>(&args->at(1));
            std::vector<uint8_t> data;
            if (!fd || !maxlen) {
              result->Error("INVALID_ARGUMENT", "Invalid arguments.");
              return;
            }
            uint8_t* buf = new uint8_t[*maxlen];
            if (!buf) {
              result->Error("ERROR", "Failed to allocate memory.");
              return;
            }
            int num = _read((int)*fd, buf, (int)*maxlen);
            if (num == -1) {
              std::string errmsg;
              if (!err::get_errno_message(errmsg, errno)) {
                errmsg = "Unknown error.";
              }
              delete[] buf;
              result->Error("ERROR", "Failed to read file:" + errmsg);
              return;
            }
            for (auto i = 0; i < num; i++) data.push_back(buf[i]);
            delete[] buf;
            result->Success(flutter::EncodableValue(data));
          } else {
            result->NotImplemented();
          }
         }); 
  flutter::MethodChannel<> display(flutter_controller_->engine()->messenger(), "lifegpc.eh_downloader_flutter/display",
      &flutter::StandardMethodCodec::GetInstance());
  display.SetMethodCallHandler([&](const flutter::MethodCall<>& call, std::unique_ptr<flutter::MethodResult<>> result) {
    if (call.method_name() == "enableProtect") {
      if (!SetWindowDisplayAffinity(Win32Window::GetHandle(), WDA_EXCLUDEFROMCAPTURE)) {
        result->Error("ERROR", "Failed to enable protect.");
        return;
      }
      result->Success();
    } else if (call.method_name() == "disableProtect") {
      if (!SetWindowDisplayAffinity(Win32Window::GetHandle(), WDA_NONE)) {
        result->Error("ERROR", "Failed to disable protect.");
        return;
      }
      result->Success();
    } else {
      result->NotImplemented();
    }
  });
  flutter::MethodChannel<> device(flutter_controller_->engine()->messenger(), "lifegpc.eh_downloader_flutter/device",
      &flutter::StandardMethodCodec::GetInstance());
  device.SetMethodCallHandler([&](const flutter::MethodCall<>& call, std::unique_ptr<flutter::MethodResult<>> result) {
    if (call.method_name() == "deviceName") {
      wchar_t name[MAX_COMPUTERNAME_LENGTH + 1];
      DWORD size = 0;
      if (!GetComputerNameW(name, &size)) {
        result->Success();
        return;
      }
      std::wstring tmp(name, size);
      std::string deviceName;
      if (!wchar_util::wstr_to_str(deviceName, tmp, CP_UTF8)) {
        result->Error("ERROR", "Failed to convert device name to UTF-8.");
        return;
      }
      result->Success(deviceName);
    } else {
      result->NotImplemented();
    }
  });

  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
