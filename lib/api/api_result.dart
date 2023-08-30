import 'package:json_annotation/json_annotation.dart';

part 'api_result.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class ApiResult<T> {
  const ApiResult({
    required this.ok,
    required this.status,
    this.data,
    this.error,
  });
  factory ApiResult.fromJson(
          Map<String, dynamic> json, T Function(Object?) fromJsonT) =>
      _$ApiResultFromJson(json, fromJsonT);
  final bool ok;
  final int status;
  final T? data;
  final String? error;
  Map<String, dynamic> toJson(Object? Function(T) toJsonT) =>
      _$ApiResultToJson(this, toJsonT);
  T unwrap() {
    if (ok) {
      return data!;
    } else {
      return throw error!;
    }
  }
  (int, String) unwrapErr() {
    if (ok) {
      return throw 'unwrap_err called on ok ApiResult';
    } else {
      return (status, error!);
    }
  }
}
