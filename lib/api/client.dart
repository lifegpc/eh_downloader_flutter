import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:dio/dio.dart';
import 'package:eh_downloader_flutter/api/file.dart';
import 'package:retrofit/retrofit.dart';
import 'api_result.dart';
import 'gallery.dart';
import 'status.dart';
import 'tags.dart';
import 'token.dart';
import 'user.dart';

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

enum ThumbnailMethod {
  unknown,
  cover,
  contain,
  fill;
}

enum ThumbnailAlign {
  left,
  center,
  right;

  static const top = left;
  static const bottom = right;
}

@RestApi()
abstract class _EHApi {
  factory _EHApi(Dio dio, {required String baseUrl}) = __EHApi;

  @PUT('/user')
  @MultiPart()
  Future<ApiResult<int>> createUser(
      @Part(name: "name") String name, @Part(name: "password") String password,
      {@Part(name: "is_admin") bool? isAdmin,
      @Part(name: "permissions") int? permissions});
  @GET('/user')
  Future<ApiResult<BUser>> getUser(
      {@Query("id") int? id, @Query("username") String? username});

  @GET('/status')
  Future<ApiResult<ServerStatus>> getStatus();

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
      @Part(name: "secure") bool? secure});
  @DELETE('/token')
  @MultiPart()
  Future<ApiResult<bool>> deleteToken({@Part(name: "token") String? token});
  @GET('/token')
  Future<ApiResult<TokenWithUserInfo>> getToken(
      {@Query("token") String? token});

  @GET('/file/{id}')
  @DioResponseType(ResponseType.bytes)
  Future<HttpResponse<List<int>>> getFile(@Path("id") int id);
  @GET('/file/{id}')
  // ignore: unused_element
  Future<ApiResult<EhFileExtend>> _getFileData(
      @Path("id") int id, @Query("data") bool data);
  @GET('/file/random')
  @DioResponseType(ResponseType.bytes)
  Future<HttpResponse<List<int>>> getRandomFile(
      {@Query("is_nsfw") bool? isNsfw,
      @Query("is_ad") bool? isAd,
      @Query("thumb") bool? thumb});
  @GET('/files/{token}')
  // ignore: unused_element
  Future<ApiResult<EhFiles>> _getFiles(@Path("token") String token);
  @GET('/thumbnail/{id}')
  @DioResponseType(ResponseType.bytes)
  Future<HttpResponse<List<int>>> getThumbnail(@Path("id") int id,
      {@Query("max") int? max,
      @Query("width") int? width,
      @Query("height") int? height,
      @Query("quality") int? quality,
      @Query("force") bool? force,
      @Query("method") ThumbnailMethod? method,
      @Query("align") ThumbnailAlign? align});

  @GET('/gallery/{gid}')
  Future<ApiResult<GalleryData>> getGallery(@Path("gid") int gid);
  @GET('/gallery/list')
  Future<ApiResult<List<GMeta>>> listGalleries(
      {@Query("all") bool? all,
      @Query("offset") int? offset,
      @Query("limit") int? limit});

  @GET('/tag/{id}')
  // ignore: unused_element
  Future<ApiResult<Tags>> _getTags(@Path("id") String id);
  @GET('/tag/rows')
  Future<ApiResult<List<Tag>>> getRowTags();
}

class EHApi extends __EHApi {
  EHApi(Dio dio, {required String baseUrl}) : super(dio, baseUrl: baseUrl);
  Future<ApiResult<Token>> createToken(
      {required String username,
      required String password,
      bool? setCookie,
      bool? httpOnly,
      bool? secure}) async {
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
        secure: secure);
  }

  Future<ApiResult<EhFileExtend>> getFileData(int id) {
    return _getFileData(id, true);
  }

  Future<ApiResult<EhFiles>> getFiles(List<String> tokens) {
    return _getFiles(tokens.join(","));
  }

  Future<ApiResult<Tags>> getTags(List<int> ids) {
    return _getTags(ids.join(","));
  }
}
