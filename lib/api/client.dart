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
      @Part(name: "permissions") int? permissions,
      @CancelRequest() CancelToken? cancel});
  @GET('/user')
  Future<ApiResult<BUser>> getUser(
      {@Query("id") int? id,
      @Query("username") String? username,
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
      @CancelRequest() CancelToken? cancel});
  @DELETE('/token')
  @MultiPart()
  Future<ApiResult<bool>> deleteToken(
      {@Part(name: "token") String? token,
      @CancelRequest() CancelToken? cancel});
  @GET('/token')
  Future<ApiResult<TokenWithUserInfo>> getToken(
      {@Query("token") String? token, @CancelRequest() CancelToken? cancel});

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
      @Query("method") ThumbnailMethod? method,
      @Query("align") ThumbnailAlign? align,
      @CancelRequest() CancelToken? cancel});

  @GET('/gallery/{gid}')
  Future<ApiResult<GalleryData>> getGallery(@Path("gid") int gid,
      {@CancelRequest() CancelToken? cancel});
  @GET('/gallery/list')
  Future<ApiResult<List<GMeta>>> listGalleries(
      {@Query("all") bool? all,
      @Query("offset") int? offset,
      @Query("limit") int? limit,
      @CancelRequest() CancelToken? cancel});

  @GET('/tag/{id}')
  // ignore: unused_element
  Future<ApiResult<Tags>> _getTags(@Path("id") String id,
      // ignore: unused_element
      {@CancelRequest() CancelToken? cancel});
  @GET('/tag/rows')
  Future<ApiResult<List<Tag>>> getRowTags(
      {@CancelRequest() CancelToken? cancel});
}

class EHApi extends __EHApi {
  EHApi(Dio dio, {required String baseUrl}) : super(dio, baseUrl: baseUrl);
  Future<ApiResult<Token>> createToken(
      {required String username,
      required String password,
      bool? setCookie,
      bool? httpOnly,
      bool? secure,
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
        cancel: cancel);
  }

  Future<ApiResult<EhFileExtend>> getFileData(int id, {CancelToken? cancel}) {
    return _getFileData(id, true, cancel: cancel);
  }

  Future<ApiResult<EhFiles>> getFiles(List<String> tokens,
      {CancelToken? cancel}) {
    return _getFiles(tokens.join(","), cancel: cancel);
  }

  Future<ApiResult<Tags>> getTags(List<int> ids, {CancelToken? cancel}) {
    return _getTags(ids.join(","), cancel: cancel);
  }
}
