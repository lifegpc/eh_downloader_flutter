import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'api_result.dart';
import 'user.dart';

part 'client.g.dart';

@RestApi(parser: Parser.FlutterCompute)
abstract class EHApi {
  factory EHApi(Dio dio, {String baseUrl}) = _EHApi;

  @GET('/user')
  Future<ApiResult<BUser>> getUser();
  @GET('/user')
  Future<ApiResult<BUser>> getUserById(@Query("id") int id);
  @GET('/user')
  Future<ApiResult<BUser>> getUserByUsername(
      @Query("username") String username);
}
