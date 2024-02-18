// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers

class __EHApi implements _EHApi {
  __EHApi(
    this._dio, {
    this.baseUrl,
  });

  final Dio _dio;

  String? baseUrl;

  @override
  Future<ApiResult<int>> createUser(
    String name,
    String password, {
    bool? isAdmin,
    int? permissions,
    CancelToken? cancel,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = FormData();
    _data.fields.add(MapEntry(
      'name',
      name,
    ));
    _data.fields.add(MapEntry(
      'password',
      password,
    ));
    if (isAdmin != null) {
      _data.fields.add(MapEntry(
        'is_admin',
        isAdmin.toString(),
      ));
    }
    if (permissions != null) {
      _data.fields.add(MapEntry(
        'permissions',
        permissions.toString(),
      ));
    }
    final _result = await _dio
        .fetch<Map<String, dynamic>>(_setStreamType<ApiResult<int>>(Options(
      method: 'PUT',
      headers: _headers,
      extra: _extra,
      contentType: 'multipart/form-data',
    )
            .compose(
              _dio.options,
              '/user',
              queryParameters: queryParameters,
              data: _data,
              cancelToken: cancel,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final value = ApiResult<int>.fromJson(
      _result.data!,
      (json) => json as int,
    );
    return value;
  }

  @override
  Future<ApiResult<BUser>> getUser({
    int? id,
    String? username,
    CancelToken? cancel,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'id': id,
      r'username': username,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio
        .fetch<Map<String, dynamic>>(_setStreamType<ApiResult<BUser>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/user',
              queryParameters: queryParameters,
              data: _data,
              cancelToken: cancel,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final value = ApiResult<BUser>.fromJson(
      _result.data!,
      (json) => BUser.fromJson(json as Map<String, dynamic>),
    );
    return value;
  }

  @override
  Future<ApiResult<ServerStatus>> getStatus({CancelToken? cancel}) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<ApiResult<ServerStatus>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/status',
              queryParameters: queryParameters,
              data: _data,
              cancelToken: cancel,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final value = ApiResult<ServerStatus>.fromJson(
      _result.data!,
      (json) => ServerStatus.fromJson(json as Map<String, dynamic>),
    );
    return value;
  }

  @override
  Future<ApiResult<Token>> _createToken({
    required String username,
    required String password,
    required int t,
    bool? setCookie,
    bool? httpOnly,
    bool? secure,
    String? client,
    String? device,
    String? clientVersion,
    String? clientPlatform,
    CancelToken? cancel,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = FormData();
    _data.fields.add(MapEntry(
      'username',
      username,
    ));
    _data.fields.add(MapEntry(
      'password',
      password,
    ));
    _data.fields.add(MapEntry(
      't',
      t.toString(),
    ));
    if (setCookie != null) {
      _data.fields.add(MapEntry(
        'set_cookie',
        setCookie.toString(),
      ));
    }
    if (httpOnly != null) {
      _data.fields.add(MapEntry(
        'http_only',
        httpOnly.toString(),
      ));
    }
    if (secure != null) {
      _data.fields.add(MapEntry(
        'secure',
        secure.toString(),
      ));
    }
    if (client != null) {
      _data.fields.add(MapEntry(
        'client',
        client,
      ));
    }
    if (device != null) {
      _data.fields.add(MapEntry(
        'device',
        device,
      ));
    }
    if (clientVersion != null) {
      _data.fields.add(MapEntry(
        'client_version',
        clientVersion,
      ));
    }
    if (clientPlatform != null) {
      _data.fields.add(MapEntry(
        'client_platform',
        clientPlatform,
      ));
    }
    final _result = await _dio
        .fetch<Map<String, dynamic>>(_setStreamType<ApiResult<Token>>(Options(
      method: 'PUT',
      headers: _headers,
      extra: _extra,
      contentType: 'multipart/form-data',
    )
            .compose(
              _dio.options,
              '/token',
              queryParameters: queryParameters,
              data: _data,
              cancelToken: cancel,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final value = ApiResult<Token>.fromJson(
      _result.data!,
      (json) => Token.fromJson(json as Map<String, dynamic>),
    );
    return value;
  }

  @override
  Future<ApiResult<Token>> updateToken({
    String? token,
    String? client,
    String? device,
    String? clientVersion,
    String? clientPlatform,
    CancelToken? cancel,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = FormData();
    if (token != null) {
      _data.fields.add(MapEntry(
        'token',
        token,
      ));
    }
    if (client != null) {
      _data.fields.add(MapEntry(
        'client',
        client,
      ));
    }
    if (device != null) {
      _data.fields.add(MapEntry(
        'device',
        device,
      ));
    }
    if (clientVersion != null) {
      _data.fields.add(MapEntry(
        'client_version',
        clientVersion,
      ));
    }
    if (clientPlatform != null) {
      _data.fields.add(MapEntry(
        'client_platform',
        clientPlatform,
      ));
    }
    final _result = await _dio
        .fetch<Map<String, dynamic>>(_setStreamType<ApiResult<Token>>(Options(
      method: 'PATCH',
      headers: _headers,
      extra: _extra,
      contentType: 'multipart/form-data',
    )
            .compose(
              _dio.options,
              '/token',
              queryParameters: queryParameters,
              data: _data,
              cancelToken: cancel,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final value = ApiResult<Token>.fromJson(
      _result.data!,
      (json) => Token.fromJson(json as Map<String, dynamic>),
    );
    return value;
  }

  @override
  Future<ApiResult<bool>> deleteToken({
    String? token,
    CancelToken? cancel,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = FormData();
    if (token != null) {
      _data.fields.add(MapEntry(
        'token',
        token,
      ));
    }
    final _result = await _dio
        .fetch<Map<String, dynamic>>(_setStreamType<ApiResult<bool>>(Options(
      method: 'DELETE',
      headers: _headers,
      extra: _extra,
      contentType: 'multipart/form-data',
    )
            .compose(
              _dio.options,
              '/token',
              queryParameters: queryParameters,
              data: _data,
              cancelToken: cancel,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final value = ApiResult<bool>.fromJson(
      _result.data!,
      (json) => json as bool,
    );
    return value;
  }

  @override
  Future<ApiResult<TokenWithUserInfo>> getToken({
    String? token,
    CancelToken? cancel,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'token': token};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<ApiResult<TokenWithUserInfo>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/token',
              queryParameters: queryParameters,
              data: _data,
              cancelToken: cancel,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final value = ApiResult<TokenWithUserInfo>.fromJson(
      _result.data!,
      (json) => TokenWithUserInfo.fromJson(json as Map<String, dynamic>),
    );
    return value;
  }

  @override
  Future<HttpResponse<List<int>>> getFile(
    int id, {
    CancelToken? cancel,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio
        .fetch<List<dynamic>>(_setStreamType<HttpResponse<List<int>>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
      responseType: ResponseType.bytes,
    )
            .compose(
              _dio.options,
              '/file/${id}',
              queryParameters: queryParameters,
              data: _data,
              cancelToken: cancel,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final value = _result.data!.cast<int>();
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<ApiResult<EhFileExtend>> _getFileData(
    int id,
    bool data, {
    CancelToken? cancel,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'data': data};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<ApiResult<EhFileExtend>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/file/${id}',
              queryParameters: queryParameters,
              data: _data,
              cancelToken: cancel,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final value = ApiResult<EhFileExtend>.fromJson(
      _result.data!,
      (json) => EhFileExtend.fromJson(json as Map<String, dynamic>),
    );
    return value;
  }

  @override
  Future<HttpResponse<List<int>>> getRandomFile({
    bool? isNsfw,
    bool? isAd,
    bool? thumb,
    CancelToken? cancel,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'is_nsfw': isNsfw,
      r'is_ad': isAd,
      r'thumb': thumb,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio
        .fetch<List<dynamic>>(_setStreamType<HttpResponse<List<int>>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
      responseType: ResponseType.bytes,
    )
            .compose(
              _dio.options,
              '/file/random',
              queryParameters: queryParameters,
              data: _data,
              cancelToken: cancel,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final value = _result.data!.cast<int>();
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<ApiResult<EhFiles>> _getFiles(
    String token, {
    CancelToken? cancel,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio
        .fetch<Map<String, dynamic>>(_setStreamType<ApiResult<EhFiles>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/files/${token}',
              queryParameters: queryParameters,
              data: _data,
              cancelToken: cancel,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final value = ApiResult<EhFiles>.fromJson(
      _result.data!,
      (json) => EhFiles.fromJson(json as Map<String, dynamic>),
    );
    return value;
  }

  @override
  Future<HttpResponse<List<int>>> getThumbnail(
    int id, {
    int? max,
    int? width,
    int? height,
    int? quality,
    bool? force,
    ThumbnailMethod? method,
    ThumbnailAlign? align,
    CancelToken? cancel,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'max': max,
      r'width': width,
      r'height': height,
      r'quality': quality,
      r'force': force,
      r'method': method?.name,
      r'align': align?.name,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio
        .fetch<List<dynamic>>(_setStreamType<HttpResponse<List<int>>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
      responseType: ResponseType.bytes,
    )
            .compose(
              _dio.options,
              '/thumbnail/${id}',
              queryParameters: queryParameters,
              data: _data,
              cancelToken: cancel,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final value = _result.data!.cast<int>();
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<ApiResult<GalleryData>> getGallery(
    int gid, {
    CancelToken? cancel,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<ApiResult<GalleryData>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/gallery/${gid}',
              queryParameters: queryParameters,
              data: _data,
              cancelToken: cancel,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final value = ApiResult<GalleryData>.fromJson(
      _result.data!,
      (json) => GalleryData.fromJson(json as Map<String, dynamic>),
    );
    return value;
  }

  @override
  Future<ApiResult<List<GMeta>>> listGalleries({
    bool? all,
    int? offset,
    int? limit,
    bool? sortByGid,
    String? uploader,
    String? tag,
    CancelToken? cancel,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'all': all,
      r'offset': offset,
      r'limit': limit,
      r'sort_by_gid': sortByGid,
      r'uploader': uploader,
      r'tag': tag,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<ApiResult<List<GMeta>>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/gallery/list',
              queryParameters: queryParameters,
              data: _data,
              cancelToken: cancel,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final value = ApiResult<List<GMeta>>.fromJson(
      _result.data!,
      (json) => json is List<dynamic>
          ? json
              .map<GMeta>((i) => GMeta.fromJson(i as Map<String, dynamic>))
              .toList()
          : List.empty(),
    );
    return value;
  }

  @override
  Future<ApiResult<Tags>> _getTags(
    String id, {
    CancelToken? cancel,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio
        .fetch<Map<String, dynamic>>(_setStreamType<ApiResult<Tags>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/tag/${id}',
              queryParameters: queryParameters,
              data: _data,
              cancelToken: cancel,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final value = ApiResult<Tags>.fromJson(
      _result.data!,
      (json) => Tags.fromJson(json as Map<String, dynamic>),
    );
    return value;
  }

  @override
  Future<ApiResult<List<Tag>>> getRowTags({CancelToken? cancel}) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<ApiResult<List<Tag>>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/tag/rows',
              queryParameters: queryParameters,
              data: _data,
              cancelToken: cancel,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final value = ApiResult<List<Tag>>.fromJson(
      _result.data!,
      (json) => json is List<dynamic>
          ? json
              .map<Tag>((i) => Tag.fromJson(i as Map<String, dynamic>))
              .toList()
          : List.empty(),
    );
    return value;
  }

  @override
  Future<HttpResponse<dynamic>> exportGalleryZip(
    int gid, {
    bool? jpnTitle,
    int? maxLength,
    bool? exportAd,
    CancelToken? cancel,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'jpn_title': jpnTitle,
      r'max_length': maxLength,
      r'export_ad': exportAd,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
      responseType: ResponseType.stream,
    )
            .compose(
              _dio.options,
              '/export/gallery/zip/${gid}',
              queryParameters: queryParameters,
              data: _data,
              cancelToken: cancel,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<ApiResult<dynamic>> updateGalleryFileMeta(
    int gid, {
    bool? isNsfw,
    bool? isAd,
    String? excludes,
    CancelToken? cancel,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = FormData();
    _data.fields.add(MapEntry(
      'gid',
      gid.toString(),
    ));
    if (isNsfw != null) {
      _data.fields.add(MapEntry(
        'is_nsfw',
        isNsfw.toString(),
      ));
    }
    if (isAd != null) {
      _data.fields.add(MapEntry(
        'is_ad',
        isAd.toString(),
      ));
    }
    if (excludes != null) {
      _data.fields.add(MapEntry(
        'excludes',
        excludes,
      ));
    }
    final _result = await _dio
        .fetch<Map<String, dynamic>>(_setStreamType<ApiResult<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'multipart/form-data',
    )
            .compose(
              _dio.options,
              '/filemeta',
              queryParameters: queryParameters,
              data: _data,
              cancelToken: cancel,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final value = ApiResult<dynamic>.fromJson(
      _result.data!,
      (json) => json as dynamic,
    );
    return value;
  }

  @override
  Future<ApiResult<dynamic>> updateFileMeta(
    String token, {
    bool? isNsfw,
    bool? isAd,
    CancelToken? cancel,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = FormData();
    _data.fields.add(MapEntry(
      'token',
      token,
    ));
    if (isNsfw != null) {
      _data.fields.add(MapEntry(
        'is_nsfw',
        isNsfw.toString(),
      ));
    }
    if (isAd != null) {
      _data.fields.add(MapEntry(
        'is_ad',
        isAd.toString(),
      ));
    }
    final _result = await _dio
        .fetch<Map<String, dynamic>>(_setStreamType<ApiResult<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'multipart/form-data',
    )
            .compose(
              _dio.options,
              '/filemeta',
              queryParameters: queryParameters,
              data: _data,
              cancelToken: cancel,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final value = ApiResult<dynamic>.fromJson(
      _result.data!,
      (json) => json as dynamic,
    );
    return value;
  }

  @override
  Future<ApiResult<dynamic>> updateFilesMeta(
    String tokens, {
    bool? isNsfw,
    bool? isAd,
    CancelToken? cancel,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = FormData();
    _data.fields.add(MapEntry(
      'tokens',
      tokens,
    ));
    if (isNsfw != null) {
      _data.fields.add(MapEntry(
        'is_nsfw',
        isNsfw.toString(),
      ));
    }
    if (isAd != null) {
      _data.fields.add(MapEntry(
        'is_ad',
        isAd.toString(),
      ));
    }
    final _result = await _dio
        .fetch<Map<String, dynamic>>(_setStreamType<ApiResult<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'multipart/form-data',
    )
            .compose(
              _dio.options,
              '/filemeta',
              queryParameters: queryParameters,
              data: _data,
              cancelToken: cancel,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final value = ApiResult<dynamic>.fromJson(
      _result.data!,
      (json) => json as dynamic,
    );
    return value;
  }

  @override
  Future<Config> getConfig({
    bool? current,
    CancelToken? cancel,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'current': current};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result =
        await _dio.fetch<Map<String, dynamic>>(_setStreamType<Config>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/config',
              queryParameters: queryParameters,
              data: _data,
              cancelToken: cancel,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final value = Config.fromJson(_result.data!);
    return value;
  }

  @override
  Future<UpdateConfigResult> updateConfig(
    ConfigOptional cfg, {
    CancelToken? cancel,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(cfg.toJson());
    final _result = await _dio
        .fetch<Map<String, dynamic>>(_setStreamType<UpdateConfigResult>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/config',
              queryParameters: queryParameters,
              data: _data,
              cancelToken: cancel,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final value = UpdateConfigResult.fromJson(_result.data!);
    return value;
  }

  @override
  Future<ApiResult<EHMetaInfo>> getMetaInfo(
    List<int> gids,
    List<String> tokens, {
    CancelToken? cancel,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'gid': gids,
      r'token': tokens,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<ApiResult<EHMetaInfo>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/eh/metadata',
              queryParameters: queryParameters,
              data: _data,
              cancelToken: cancel,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final value = ApiResult<EHMetaInfo>.fromJson(
      _result.data!,
      (json) => EHMetaInfo.fromJson(json as Map<String, dynamic>),
    );
    return value;
  }

  @override
  Future<ApiResult<Task>> createDownloadTask(
    int gid,
    String token, {
    DownloadConfig? cfg,
    String t = "download",
    CancelToken? cancel,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = FormData();
    _data.fields.add(MapEntry(
      'gid',
      gid.toString(),
    ));
    _data.fields.add(MapEntry(
      'token',
      token,
    ));
    _data.fields.add(MapEntry(
      'cfg',
      jsonEncode(cfg ?? <String, dynamic>{}),
    ));
    _data.fields.add(MapEntry(
      'type',
      t,
    ));
    final _result = await _dio
        .fetch<Map<String, dynamic>>(_setStreamType<ApiResult<Task>>(Options(
      method: 'PUT',
      headers: _headers,
      extra: _extra,
      contentType: 'multipart/form-data',
    )
            .compose(
              _dio.options,
              '/task',
              queryParameters: queryParameters,
              data: _data,
              cancelToken: cancel,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final value = ApiResult<Task>.fromJson(
      _result.data!,
      (json) => Task.fromJson(json as Map<String, dynamic>),
    );
    return value;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }

  String _combineBaseUrls(
    String dioBaseUrl,
    String? baseUrl,
  ) {
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      return dioBaseUrl;
    }

    final url = Uri.parse(baseUrl);

    if (url.isAbsolute) {
      return url.toString();
    }

    return Uri.parse(dioBaseUrl).resolveUri(url).toString();
  }
}
