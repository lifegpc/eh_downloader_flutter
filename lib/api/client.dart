import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'api_result.dart';
import 'status.dart';
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

@RestApi()
abstract class EHApi {
  factory EHApi(Dio dio, {String baseUrl}) = _EHApi;

  @PUT('/user')
  Future<ApiResult<int>> createUser(
      @Query("name") String name, @Query("password") String password,
      {@Query("is_admin") bool? isAdmin,
      @Query("permissions") int? permissions});
  @GET('/user')
  Future<ApiResult<BUser>> getUser(
      {@Query("id") int? id, @Query("username") String? username});

  @GET('/status')
  Future<ApiResult<ServerStatus>> getStatus();

  @PUT('/token')
  Future<ApiResult<Token>> _createToken(
      {@Query("username") String username,
      @Query("password") String password,
      @Query("t") int t,
      @Query("set_cookie") bool? setCookie,
      @Query("http_only") bool? httpOnly,
      @Query("secure") bool? secure});
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
  @DELETE('/token')
  Future<ApiResult<bool>> deleteToken({@Query("token") String? token});
  @GET('/token')
  Future<ApiResult<Token>> getToken({@Query("token") String? token});
}
