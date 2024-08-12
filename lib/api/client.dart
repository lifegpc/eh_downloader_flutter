import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:retrofit/retrofit.dart';

import 'api_result.dart';
import 'config.dart';
import 'eh.dart';
import 'file.dart';
import 'gallery.dart';
import 'status.dart';
import 'tags.dart';
import 'task.dart';
import 'token.dart';
import 'user.dart';
import '../globals.dart';

part 'client.g.dart';

final _pbkdf2a = Pbkdf2(
  macAlgorithm: Hmac.sha512(),
  iterations: 210000,
  bits: 512,
);

final _pbkdf2b = Pbkdf2(
  macAlgorithm: Hmac.sha512(),
  iterations: 1000,
  bits: 512,
);

const _utf8Encoder = Utf8Encoder();
final _salt = _utf8Encoder.convert("eh-downloader-salt");

enum ThumbnailGenMethod {
  unknown,
  cover,
  contain,
  fill;

  String localText(BuildContext context) {
    final i18n = AppLocalizations.of(context)!;
    switch (this) {
      case ThumbnailGenMethod.unknown:
        return i18n.default0;
      case ThumbnailGenMethod.cover:
        return i18n.thumbnailCover;
      case ThumbnailGenMethod.contain:
        return i18n.thumbnailContain;
      case ThumbnailGenMethod.fill:
        return i18n.thumbnailFill;
    }
  }
}

enum ThumbnailAlign {
  left,
  center,
  right;

  static const top = left;
  static const bottom = right;
  String localText(BuildContext context) {
    final i18n = AppLocalizations.of(context)!;
    switch (this) {
      case ThumbnailAlign.left:
        return i18n.leftOrTop;
      case ThumbnailAlign.center:
        return i18n.center;
      case ThumbnailAlign.right:
        return i18n.rightOrBottom;
    }
  }
}

enum SortByGid {
  none,
  asc,
  desc;

  bool? toBool() {
    switch (this) {
      case SortByGid.asc:
        return true;
      case SortByGid.desc:
        return false;
      default:
        return null;
    }
  }
}

@RestApi()
abstract class _EHApi {
  factory _EHApi(Dio dio, {required String baseUrl}) = __EHApi;

  @POST('/user/change_name')
  @MultiPart()
  Future<ApiResult<BUser>> changeUserName(
      @Part(name: "username") String username,
      {@CancelRequest() CancelToken? cancel});
  @POST('/user/change_password')
  @MultiPart()
  // ignore: unused_element
  Future<ApiResult<dynamic>> _changeUserPassword(
      @Part(name: "old") String oldPassword,
      @Part(name: "t") int t,
      @Part(name: "new") String newPassword,
      // ignore: unused_element
      {@CancelRequest() CancelToken? cancel});
  @PUT('/user')
  @MultiPart()
  Future<ApiResult<int>> createUser(
      @Part(name: "name") String name, @Part(name: "password") String password,
      {@Part(name: "is_admin") bool? isAdmin,
      @Part(name: "permissions") int? permissions,
      @CancelRequest() CancelToken? cancel});
  @DELETE('/user')
  @MultiPart()
  Future<ApiResult<dynamic>> deleteUser(
      {@Part(name: "id") int? id,
      @Part(name: "username") String? username,
      @CancelRequest() CancelToken? cancel});
  @GET('/user')
  Future<ApiResult<BUser>> getUser(
      {@Query("id") int? id,
      @Query("username") String? username,
      @CancelRequest() CancelToken? cancel});
  @GET('/user/list')
  Future<ApiResult<List<BUser>>> getUsers(
      {@Query("all") bool? all,
      @Query("offset") int? offset,
      @Query("limit") int? limit,
      @CancelRequest() CancelToken? cancel});
  @PATCH('/user')
  @MultiPart()
  Future<ApiResult<BUser>> updateUser(
      {@Part(name: "id") int? id,
      @Part(name: "username") String? username,
      @Part(name: "password") String? password,
      @Part(name: "is_admin") bool? isAdmin,
      @Part(name: "revoke_token") bool? revokeToken,
      @Part(name: "permissions") int? permissions,
      @CancelRequest() CancelToken? cancel});

  @GET('/status')
  Future<ApiResult<ServerStatus>> getStatus(
      {@CancelRequest() CancelToken? cancel});

  @PUT('/token')
  @MultiPart()
  // ignore: unused_element
  Future<ApiResult<Token>> _createToken(
      {@Part(name: "username") required String username,
      @Part(name: "password") required String password,
      @Part(name: "t") required int t,
      // ignore: unused_element
      @Part(name: "set_cookie") bool? setCookie,
      // ignore: unused_element
      @Part(name: "http_only") bool? httpOnly,
      // ignore: unused_element
      @Part(name: "secure") bool? secure,
      // ignore: unused_element
      @Part(name: "client") String? client,
      // ignore: unused_element
      @Part(name: "device") String? device,
      // ignore: unused_element
      @Part(name: "client_version") String? clientVersion,
      // ignore: unused_element
      @Part(name: "client_platform") String? clientPlatform,
      // ignore: unused_element
      @CancelRequest() CancelToken? cancel});
  @PATCH('/token')
  @MultiPart()
  Future<ApiResult<Token>> updateToken(
      {@Part(name: "token") String? token,
      @Part(name: "client") String? client,
      @Part(name: "device") String? device,
      @Part(name: "client_version") String? clientVersion,
      @Part(name: "client_platform") String? clientPlatform,
      @CancelRequest() CancelToken? cancel});
  @DELETE('/token')
  @MultiPart()
  Future<ApiResult<bool>> deleteToken(
      {@Part(name: "token") String? token,
      @CancelRequest() CancelToken? cancel});
  @GET('/token')
  Future<ApiResult<TokenWithUserInfo>> getToken(
      {@Query("token") String? token, @CancelRequest() CancelToken? cancel});
  @GET('/shared_token')
  Future<ApiResult<SharedToken>> getSharedToken(
      {@CancelRequest() CancelToken? cancel});

  @GET('/file/{id}')
  @DioResponseType(ResponseType.bytes)
  Future<HttpResponse<List<int>>> getFile(@Path("id") int id,
      {@CancelRequest() CancelToken? cancel});
  @GET('/file/{id}')
  // ignore: unused_element
  Future<ApiResult<EhFileExtend>> _getFileData(
      @Path("id") int id, @Query("data") bool data,
      // ignore: unused_element
      {@CancelRequest() CancelToken? cancel});
  @GET('/file/random')
  @DioResponseType(ResponseType.bytes)
  Future<HttpResponse<List<int>>> getRandomFile(
      {@Query("is_nsfw") bool? isNsfw,
      @Query("is_ad") bool? isAd,
      @Query("thumb") bool? thumb,
      @CancelRequest() CancelToken? cancel});
  @GET('/files/{token}')
  // ignore: unused_element
  Future<ApiResult<EhFiles>> _getFiles(@Path("token") String token,
      // ignore: unused_element
      {@CancelRequest() CancelToken? cancel});
  @GET('/thumbnail/{id}')
  @DioResponseType(ResponseType.bytes)
  Future<HttpResponse<List<int>>> getThumbnail(@Path("id") int id,
      {@Query("max") int? max,
      @Query("width") int? width,
      @Query("height") int? height,
      @Query("quality") int? quality,
      @Query("force") bool? force,
      @Query("method") ThumbnailGenMethod? method,
      @Query("align") ThumbnailAlign? align,
      @CancelRequest() CancelToken? cancel});

  @GET('/gallery/{gid}')
  Future<ApiResult<GalleryData>> getGallery(@Path("gid") int gid,
      {@CancelRequest() CancelToken? cancel});
  @GET('/gallery/meta/{gids}')
  // ignore: unused_element
  Future<ApiResult<GMetaInfos>> _getGalleriesMeta(@Path("gids") String gids,
      // ignore: unused_element
      {@CancelRequest() CancelToken? cancel});
  @GET('/gallery/list')
  Future<ApiResult<List<GMeta>>> listGalleries(
      {@Query("all") bool? all,
      @Query("offset") int? offset,
      @Query("limit") int? limit,
      @Query("sort_by_gid") bool? sortByGid,
      @Query("uploader") String? uploader,
      @Query("tag") String? tag,
      @Query("category") String? category,
      @CancelRequest() CancelToken? cancel});
  @PUT('/shared_token')
  @MultiPart()
  Future<ApiResult<SharedTokenWithUrl>> shareGallery(@Part(name: "gid") int gid,
      {@Part(name: "expired") int? expired,
      @Part(name: "type") String type = "gallery",
      @CancelRequest() CancelToken? cancel});

  @GET('/tag/{id}')
  // ignore: unused_element
  Future<ApiResult<Tags>> _getTags(@Path("id") String id,
      // ignore: unused_element
      {@CancelRequest() CancelToken? cancel});
  @GET('/tag/rows')
  Future<ApiResult<List<Tag>>> getRowTags(
      {@CancelRequest() CancelToken? cancel});

  @GET('/export/gallery/zip/{gid}')
  @DioResponseType(ResponseType.stream)
  Future<HttpResponse> exportGalleryZip(@Path("gid") int gid,
      {@Query("jpn_title") bool? jpnTitle,
      @Query("max_length") int? maxLength,
      @Query("export_ad") bool? exportAd,
      @CancelRequest() CancelToken? cancel});

  @POST('/filemeta')
  @MultiPart()
  Future<ApiResult<dynamic>> updateGalleryFileMeta(@Part(name: "gid") int gid,
      {@Part(name: "is_nsfw") bool? isNsfw,
      @Part(name: "is_ad") bool? isAd,
      @Part(name: "excludes") String? excludes,
      @CancelRequest() CancelToken? cancel});
  @POST('/filemeta')
  @MultiPart()
  Future<ApiResult<dynamic>> updateFileMeta(@Part(name: "token") String token,
      {@Part(name: "is_nsfw") bool? isNsfw,
      @Part(name: "is_ad") bool? isAd,
      @CancelRequest() CancelToken? cancel});
  @POST('/filemeta')
  @MultiPart()
  Future<ApiResult<dynamic>> updateFilesMeta(
      @Part(name: "tokens") String tokens,
      {@Part(name: "is_nsfw") bool? isNsfw,
      @Part(name: "is_ad") bool? isAd,
      @CancelRequest() CancelToken? cancel});

  @GET('/config')
  Future<Config> getConfig(
      {@Query("current") bool? current, @CancelRequest() CancelToken? cancel});
  @POST('/config')
  Future<UpdateConfigResult> updateConfig(
      @Body(nullToAbsent: false) ConfigOptional cfg,
      {@CancelRequest() CancelToken? cancel});

  @GET('/eh/metadata')
  Future<ApiResult<EHMetaInfo>> getMetaInfo(
      @Query("gid") List<int> gids, @Query("token") List<String> tokens,
      {@CancelRequest() CancelToken? cancel});

  @PUT('/task')
  @MultiPart()
  Future<ApiResult<Task>> createDownloadTask(
    @Part(name: "gid") int gid,
    @Part(name: "token") String token, {
    @Part(name: "cfg") DownloadConfig? cfg,
    @Part(name: "type") String t = "download",
    @CancelRequest() CancelToken? cancel,
  });
  @PUT('/task')
  @MultiPart()
  Future<ApiResult<Task>> createExportZipTask(@Part(name: "gid") int gid,
      {@Part(name: 'cfg') ExportZipConfig? cfg,
      @Part(name: "type") String t = "export_zip",
      @CancelRequest() CancelToken? cancel});
  @PUT('/task')
  @MultiPart()
  Future<ApiResult<Task>> createImportTask(
    @Part(name: "gid") int gid,
    @Part(name: "token") String token, {
    @Part(name: "cfg") ImportConfig? cfg,
    @Part(name: "type") String t = "import",
    @CancelRequest() CancelToken? cancel,
  });
  @GET('/task/download_cfg')
  Future<ApiResult<DownloadConfig>> getDefaultDownloadConfig(
      {@CancelRequest() CancelToken? cancel});
  @GET('/task/export_zip_cfg')
  Future<ApiResult<ExportZipConfig>> getDefaultExportZipConfig(
      {@CancelRequest() CancelToken? cancel});
  @GET('/task/import_cfg')
  Future<ApiResult<DefaultImportConfig>> getDefaultImportConfig(
      {@CancelRequest() CancelToken? cancel});
}

class EHApi extends __EHApi {
  EHApi(super.dio, {required String super.baseUrl});
  Future<ApiResult<Token>> createToken(
      {required String username,
      required String password,
      bool? setCookie,
      bool? httpOnly,
      bool? secure,
      String? client,
      String? device,
      String? clientVersion,
      String? clientPlatform,
      CancelToken? cancel}) async {
    int t = DateTime.now().millisecondsSinceEpoch;
    final p =
        await _pbkdf2a.deriveKeyFromPassword(password: password, nonce: _salt);
    final p2 = await _pbkdf2b.deriveKey(
        secretKey: p, nonce: _utf8Encoder.convert(t.toString()));
    final p3 = base64Encode(await p2.extractBytes());
    return await _createToken(
        username: username,
        password: p3,
        t: t,
        setCookie: setCookie,
        httpOnly: httpOnly,
        secure: secure,
        client: client,
        device: device,
        clientVersion: clientVersion,
        clientPlatform: clientPlatform,
        cancel: cancel);
  }

  Future<ApiResult<EhFileExtend>> getFileData(int id, {CancelToken? cancel}) {
    return _getFileData(id, true, cancel: cancel);
  }

  Future<ApiResult<EhFiles>> getFiles(List<String> tokens,
      {CancelToken? cancel}) {
    return _getFiles(tokens.join(","), cancel: cancel);
  }

  Future<ApiResult<GMetaInfos>> getGalleriesMeta(List<int> gids,
      {@CancelRequest() CancelToken? cancel}) {
    return _getGalleriesMeta(gids.join(","), cancel: cancel);
  }

  Future<ApiResult<Tags>> getTags(List<int> ids, {CancelToken? cancel}) {
    return _getTags(ids.join(","), cancel: cancel);
  }

  Future<ApiResult<Tags>> getTags2(List<String> ids, {CancelToken? cancel}) {
    return _getTags(ids.join(","), cancel: cancel);
  }

  String getFileUrl(int id) {
    final uri = Uri.parse(_combineBaseUrls(_dio.options.baseUrl, baseUrl));
    final newUri = uri.resolve("file/$id");
    return newUri.toString();
  }

  Uri getTaskUrl() {
    final uri = Uri.parse(_combineBaseUrls(_dio.options.baseUrl, baseUrl));
    final nuri = uri.resolve("task");
    return Uri(
      scheme: uri.scheme == "https" ? "wss" : "ws",
      userInfo: nuri.userInfo,
      host: nuri.host,
      port: nuri.port,
      path: nuri.path,
      query: nuri.query,
    );
  }

  String getThumbnailUrl(int id,
      {int? max,
      int? width,
      int? height,
      int? quality,
      bool? force,
      ThumbnailGenMethod? method,
      ThumbnailAlign? align}) {
    final uri = Uri.parse(_combineBaseUrls(_dio.options.baseUrl, baseUrl));
    final queryParameters = <String, dynamic>{
      r'max': max?.toString(),
      r'width': width?.toString(),
      r'height': height?.toString(),
      r'quality': quality?.toString(),
      r'force': force?.toString(),
      r'method': method?.name,
      r'align': align?.name,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final newUri =
        uri.resolve("thumbnail/$id").replace(queryParameters: queryParameters);
    return newUri.toString();
  }

  String exportGalleryZipUrl(int gid,
      {bool? jpnTitle, int? maxLength, bool? exportAd}) {
    final uri = Uri.parse(_combineBaseUrls(_dio.options.baseUrl, baseUrl));
    var queries = {
      "jpn_title": jpnTitle?.toString(),
      "max_length": maxLength?.toString(),
      "export_ad": exportAd?.toString(),
      "share": shareToken,
    };
    queries.removeWhere((key, value) => value == null);
    final newUri = uri
        .resolve("export/gallery/zip/$gid")
        .replace(queryParameters: queries);
    return newUri.toString();
  }

  Future<ApiResult<dynamic>> changeUserPassword(
      String oldPassword, String newPassword,
      {CancelToken? cancel}) async {
    int t = DateTime.now().millisecondsSinceEpoch;
    final p = await _pbkdf2a.deriveKeyFromPassword(
        password: oldPassword, nonce: _salt);
    final p2 = await _pbkdf2b.deriveKey(
        secretKey: p, nonce: _utf8Encoder.convert(t.toString()));
    final p3 = base64Encode(await p2.extractBytes());
    return await _changeUserPassword(p3, t, newPassword, cancel: cancel);
  }
}
