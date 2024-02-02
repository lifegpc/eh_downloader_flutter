#include "my_application.h"

#include <flutter_linux/flutter_linux.h>
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif

#include <fcntl.h>
#include <string>

#include "flutter/generated_plugin_registrant.h"

struct _MyApplication {
  GtkApplication parent_instance;
  char** dart_entrypoint_arguments;
  FlMethodChannel* path_channel;
  FlMethodChannel* saf_channel;
  FlMethodChannel* device_channel;
};

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

static void on_path_channel_call(FlMethodChannel* channel, FlMethodCall* method_call,
                                 gpointer user_data) {
  const gchar* method = fl_method_call_get_name(method_call);
  if (strcmp(method, "getCurrentExe") == 0) {
    g_autoptr(GError) local_err = NULL;
    gchar* exe_path = g_file_read_link("/proc/self/exe", &local_err);
    if (local_err == NULL) {
      fl_method_call_respond(method_call, FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_string(exe_path))), nullptr);
      g_free(exe_path);
    } else {
      fl_method_call_respond_error(method_call, "get_current_exe_error", local_err->message, nullptr, nullptr);
    }
  } else {
    fl_method_call_respond_not_implemented(method_call, nullptr);
  }
}

const gchar* get_filter_name_from_mime_type(const gchar* mime_type) {
  if (g_strcmp0(mime_type, "image/jpeg") == 0) {
    return "JPG File";
  } else if (g_strcmp0(mime_type, "image/png") == 0) {
    return "PNG File";
  } else if (g_strcmp0(mime_type, "image/gif") == 0) {
    return "GIF File";
  } else if (g_strcmp0(mime_type, "application/zip") == 0) {
    return "Zip File";
  } else {
    return nullptr;
  }
}

const gchar* get_ext_from_mime_type(const gchar* mime_type) {
  if (g_strcmp0(mime_type, "image/jpeg") == 0) {
    return ".jpg";
  } else if (g_strcmp0(mime_type, "image/png") == 0) {
    return ".png";
  } else if (g_strcmp0(mime_type, "image/gif") == 0) {
    return ".gif";
  } else if (g_strcmp0(mime_type, "application/zip") == 0) {
    return ".zip";
  } else {
    return nullptr;
  }
}

static void on_saf_channel_call(FlMethodChannel* channel, FlMethodCall* method_call,
                                gpointer user_data) {
  const gchar* method = fl_method_call_get_name(method_call);
  if (g_strcmp0(method, "openFile") == 0) {
    auto args = fl_method_call_get_args(method_call);
    auto fileName = fl_value_get_string(fl_value_get_list_value(args, 0));
    auto dir = fl_value_get_string(fl_value_get_list_value(args, 1));
    auto mimeType = fl_value_get_string(fl_value_get_list_value(args, 2));
    auto readOnly = fl_value_get_bool(fl_value_get_list_value(args, 3));
    auto writeOnly = fl_value_get_bool(fl_value_get_list_value(args, 4));
    auto append = fl_value_get_bool(fl_value_get_list_value(args, 5));
    auto saveAs = fl_value_get_bool(fl_value_get_list_value(args, 6));
    std::string filename;
    if (!fileName || !dir || !mimeType) {
      fl_method_call_respond_error(method_call, "INVALID_ARGUMENTS", "Invalid arguments", nullptr, nullptr);
      return;
    }
    if (saveAs) {
      auto dialog = gtk_file_chooser_dialog_new("Save File", nullptr, GTK_FILE_CHOOSER_ACTION_SAVE,
                                              "_Cancel", GTK_RESPONSE_CANCEL,
                                              "_Save", GTK_RESPONSE_ACCEPT,
                                              nullptr);
      gtk_file_chooser_set_do_overwrite_confirmation(GTK_FILE_CHOOSER(dialog), TRUE);
      auto ext = get_ext_from_mime_type(mimeType);
      if (ext) {
        auto gstr = g_string_new(fileName);
        g_string_append(gstr, ext);
        gtk_file_chooser_set_current_name(GTK_FILE_CHOOSER(dialog), gstr->str);
        g_string_free(gstr, TRUE);
      } else {
        gtk_file_chooser_set_current_name(GTK_FILE_CHOOSER(dialog), fileName);
      }
      gtk_file_chooser_set_current_folder(GTK_FILE_CHOOSER(dialog), dir);
      auto filter = gtk_file_filter_new();
      gtk_file_filter_add_mime_type(filter, mimeType);
      gtk_file_filter_set_name(filter, get_filter_name_from_mime_type(mimeType));
      gtk_file_chooser_add_filter(GTK_FILE_CHOOSER(dialog), filter);
      filter = gtk_file_filter_new();
      gtk_file_filter_add_pattern(filter, "*");
      gtk_file_filter_set_name(filter, "All files");
      gtk_file_chooser_add_filter(GTK_FILE_CHOOSER(dialog), filter);
      auto res = gtk_dialog_run(GTK_DIALOG(dialog));
      if (res == GTK_RESPONSE_ACCEPT) {
        filename = gtk_file_chooser_get_filename(GTK_FILE_CHOOSER(dialog));
      } else {
        fl_method_call_respond_error(method_call, "USER_CANCELED", "User canceled", nullptr, nullptr);
        gtk_widget_destroy(dialog);
        return;
      }
      gtk_widget_destroy(dialog);
    } else {
      filename = dir;
      filename += "/";
      filename += fileName;
      auto ext = get_ext_from_mime_type(mimeType);
      if (ext) {
        filename += ext;
      }
    }
    int flags = 0;
    if (readOnly && writeOnly) {
      flags |= O_RDWR | O_CREAT;
    } else if (readOnly) {
      flags |= O_RDONLY;
    } else if (writeOnly) {
      flags |= O_WRONLY | O_TRUNC | O_CREAT;
    }
    if (append) {
      flags |= O_APPEND;
    }
    int fd = open(filename.c_str(), flags, 0644);
    if (fd != -1) {
      fl_method_call_respond_success(method_call, fl_value_new_int(fd), nullptr);
    } else {
      fl_method_call_respond_error(method_call, "OPEN_FILE_ERROR", g_strerror(errno), nullptr, nullptr);
    }
  } else if (g_strcmp0(method, "writeFile") == 0) {
    auto args = fl_method_call_get_args(method_call);
    auto fd = fl_value_get_int(fl_value_get_list_value(args, 0));
    auto odata = fl_value_get_list_value(args, 1);
    auto data = fl_value_get_uint8_list(odata);
    auto dataLen = fl_value_get_length(odata);
    if (!data) {
      fl_method_call_respond_error(method_call, "INVALID_ARGUMENTS", "Invalid arguments", nullptr, nullptr);
      return;
    }
    auto count = write(fd, data, dataLen);
    if (count != (ssize_t)-1) {
      fl_method_call_respond_success(method_call, fl_value_new_int(count), nullptr);
    } else {
      fl_method_call_respond_error(method_call, "WRITE_FILE_ERROR", g_strerror(errno), nullptr, nullptr);
    }
  } else if (g_strcmp0(method, "closeFile") == 0) {
    auto args = fl_method_call_get_args(method_call);
    auto fd = fl_value_get_int(fl_value_get_list_value(args, 0));
    int err = close(fd);
    if (!err) {
      fl_method_call_respond_success(method_call, nullptr, nullptr);
    } else {
      fl_method_call_respond_error(method_call, "CLOSE_FILE_ERROR", g_strerror(errno), nullptr, nullptr);
    }
  } else if (g_strcmp0(method, "readFile") == 0) {
    auto args = fl_method_call_get_args(method_call);
    auto fd = fl_value_get_int(fl_value_get_list_value(args, 0));
    auto maxLen = fl_value_get_int(fl_value_get_list_value(args, 1));
    auto data = g_malloc(maxLen);
    if (!data) {
      fl_method_call_respond_error(method_call, "OUT_OF_MEMORY", "Out of memory", nullptr, nullptr);
      return;
    }
    auto count = read(fd, data, maxLen);
    if (count != (ssize_t)-1) {
      fl_method_call_respond_success(method_call, fl_value_new_uint8_list((const uint8_t*)data, count), nullptr);
    } else {
      fl_method_call_respond_error(method_call, "READ_FILE_ERROR", g_strerror(errno), nullptr, nullptr);
    }
    g_free(data);
  } else {
    fl_method_call_respond_not_implemented(method_call, nullptr);
  }
}

static void on_device_channel_call(FlMethodChannel* channel, FlMethodCall* method_call,
                                   gpointer user_data) {
  const gchar* method = fl_method_call_get_name(method_call);
  if (g_strcmp0(method, "deviceName") == 0) {
    const gchar* name = g_get_host_name();
    if (name) {
      fl_method_call_respond_success(method_call, fl_value_new_string(name), nullptr);
    } else {
      fl_method_call_respond_success(method_call, fl_value_new_null(), nullptr);
    }
  } else {
    fl_method_call_respond_not_implemented(method_call, nullptr);
  }
}

// Implements GApplication::activate.
static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);
  GtkWindow* window =
      GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));

  // Use a header bar when running in GNOME as this is the common style used
  // by applications and is the setup most users will be using (e.g. Ubuntu
  // desktop).
  // If running on X and not using GNOME then just use a traditional title bar
  // in case the window manager does more exotic layout, e.g. tiling.
  // If running on Wayland assume the header bar will work (may need changing
  // if future cases occur).
  gboolean use_header_bar = TRUE;
#ifdef GDK_WINDOWING_X11
  GdkScreen* screen = gtk_window_get_screen(window);
  if (GDK_IS_X11_SCREEN(screen)) {
    const gchar* wm_name = gdk_x11_screen_get_window_manager_name(screen);
    if (g_strcmp0(wm_name, "GNOME Shell") != 0) {
      use_header_bar = FALSE;
    }
  }
#endif
  if (use_header_bar) {
    GtkHeaderBar* header_bar = GTK_HEADER_BAR(gtk_header_bar_new());
    gtk_widget_show(GTK_WIDGET(header_bar));
    gtk_header_bar_set_title(header_bar, "eh_downloader_flutter");
    gtk_header_bar_set_show_close_button(header_bar, TRUE);
    gtk_window_set_titlebar(window, GTK_WIDGET(header_bar));
  } else {
    gtk_window_set_title(window, "eh_downloader_flutter");
  }

  gtk_window_set_default_size(window, 1280, 720);
  gtk_widget_show(GTK_WIDGET(window));

  g_autoptr(FlDartProject) project = fl_dart_project_new();
  fl_dart_project_set_dart_entrypoint_arguments(project, self->dart_entrypoint_arguments);

  FlView* view = fl_view_new(project);
  gtk_widget_show(GTK_WIDGET(view));
  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));

  fl_register_plugins(FL_PLUGIN_REGISTRY(view));
  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  self->path_channel = fl_method_channel_new(
      fl_engine_get_binary_messenger(fl_view_get_engine(view)), "lifegpc.eh_downloader_flutter/path",
      FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(self->path_channel, on_path_channel_call, self, nullptr);
  self->saf_channel = fl_method_channel_new(
      fl_engine_get_binary_messenger(fl_view_get_engine(view)), "lifegpc.eh_downloader_flutter/saf",
      FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(self->saf_channel, on_saf_channel_call, self, nullptr);
  self->device_channel = fl_method_channel_new(
      fl_engine_get_binary_messenger(fl_view_get_engine(view)), "lifegpc.eh_downloader_flutter/device",
      FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(self->device_channel, on_device_channel_call, self, nullptr);

  gtk_widget_grab_focus(GTK_WIDGET(view));
}

// Implements GApplication::local_command_line.
static gboolean my_application_local_command_line(GApplication* application, gchar*** arguments, int* exit_status) {
  MyApplication* self = MY_APPLICATION(application);
  // Strip out the first argument as it is the binary name.
  self->dart_entrypoint_arguments = g_strdupv(*arguments + 1);

  g_autoptr(GError) error = nullptr;
  if (!g_application_register(application, nullptr, &error)) {
     g_warning("Failed to register: %s", error->message);
     *exit_status = 1;
     return TRUE;
  }

  g_application_activate(application);
  *exit_status = 0;

  return TRUE;
}

// Implements GObject::dispose.
static void my_application_dispose(GObject* object) {
  MyApplication* self = MY_APPLICATION(object);
  g_clear_pointer(&self->dart_entrypoint_arguments, g_strfreev);
  g_clear_object(&self->path_channel);
  g_clear_object(&self->saf_channel);
  g_clear_object(&self->device_channel);
  G_OBJECT_CLASS(my_application_parent_class)->dispose(object);
}

static void my_application_class_init(MyApplicationClass* klass) {
  G_APPLICATION_CLASS(klass)->activate = my_application_activate;
  G_APPLICATION_CLASS(klass)->local_command_line = my_application_local_command_line;
  G_OBJECT_CLASS(klass)->dispose = my_application_dispose;
}

static void my_application_init(MyApplication* self) {}

MyApplication* my_application_new() {
  return MY_APPLICATION(g_object_new(my_application_get_type(),
                                     "application-id", APPLICATION_ID,
                                     "flags", G_APPLICATION_NON_UNIQUE,
                                     nullptr));
}
