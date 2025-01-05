import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:eh_downloader_flutter/api/token.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import '../api/user.dart';
import '../../components/labeled_checkbox.dart';
import '../components/session_card.dart';
import '../globals.dart';
import '../platform/media_query.dart';
import '../utils.dart';

final _log = Logger("SessionsPage");

class SessionsPage extends StatefulWidget {
  const SessionsPage({super.key});

  static const String routeName = '/sessions';

  @override
  State<SessionsPage> createState() => _SessionsPage();
}

class _SessionsPage extends State<SessionsPage>
    with ThemeModeWidget, IsTopWidget2 {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final _formKey = GlobalKey<FormState>();
  int? _uid;
  bool _allUser = false;
  List<BUser>? _users;
  List<TokenWithoutToken>? _tokens;
  bool _isLoading = false;
  bool _isLoadingUsers = false;
  CancelToken? _cancel;
  CancelToken? _cancel2;
  Object? _error;
  Future<void> _fetchUserData() async {
    try {
      _cancel = CancelToken();
      _isLoadingUsers = true;
      final users = (await api.getUsers(all: true, cancel: _cancel)).unwrap();
      if (!_cancel!.isCancelled) {
        setState(() {
          _users = users;
          _isLoadingUsers = false;
        });
      }
    } catch (e) {
      if (!_cancel!.isCancelled) {
        _log.severe("Failed to load user list:", e);
        setState(() {
          _error = e;
          _isLoadingUsers = false;
        });
      }
    }
  }

  Future<void> _fetchData() async {
    try {
      _cancel2 = CancelToken();
      _isLoading = true;
      final tokens =
          (await api.getTokens(uid: _uid, allUser: _allUser, cancel: _cancel2))
              .unwrap();
      if (!_cancel2!.isCancelled) {
        setState(() {
          _tokens = tokens;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!_cancel2!.isCancelled) {
        _log.severe("Failed to load token list:", e);
        setState(() {
          _error = e;
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    listener.on("user_logined", _onStateChanged);
    listener.on("auth_token_updated", _onStateChanged);
    listener.on("delete_session", _onDeleteSession);
    super.initState();
  }

  @override
  void dispose() {
    _cancel?.cancel();
    _cancel2?.cancel();
    listener.removeEventListener("user_logined", _onStateChanged);
    listener.removeEventListener("auth_token_updated", _onStateChanged);
    listener.removeEventListener("delete_session", _onDeleteSession);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!tryInitApi(context)) {
      return Container();
    }
    final isLoadingUsers =
        auth.isAdmin == true && _users == null && _error == null;
    if (isLoadingUsers && !_isLoadingUsers) _fetchUserData();
    final isLoading = _tokens == null && _error == null;
    if (isLoading && !_isLoading) _fetchData();
    final i18n = AppLocalizations.of(context)!;
    if (isTop(context)) {
      setCurrentTitle(i18n.sessionManagemant);
    }
    return Scaffold(
        appBar: _tokens == null && (auth.isAdmin != true || _users == null)
            ? AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    context.canPop() ? context.pop() : context.go("/");
                  },
                ),
                title: Text(i18n.sessionManagemant),
                actions: [
                  buildThemeModeIcon(context),
                  buildMoreVertSettingsButon(context),
                ],
              )
            : null,
        body: isLoading || isLoadingUsers
            ? const Center(child: CircularProgressIndicator())
            : _tokens != null
                ? _buildMain(context)
                : Center(
                    child: Text("Error: $_error"),
                  ));
  }

  Widget _buildMain(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(children: [
      RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: () async {
            return await _fetchData();
          },
          child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.trackpad,
                },
              ),
              child: _buildTokenList(context))),
      Positioned(
          bottom: size.height / 10,
          right: size.width / 10,
          child: _buildIconList(context)),
    ]);
  }

  Widget _buildRefreshIcon(BuildContext context) {
    final i18n = AppLocalizations.of(context)!;
    return IconButton(
        onPressed: () {
          _refreshIndicatorKey.currentState?.show();
        },
        tooltip: i18n.refresh,
        icon: const Icon(Icons.refresh));
  }

  Widget _buildIconList(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
        color: cs.surface,
        child: Row(children: [
          isDesktop || (kIsWeb && pointerIsMouse)
              ? _buildRefreshIcon(context)
              : Container(),
        ]));
  }

  Widget _buildTokenList(BuildContext context) {
    final i18n = AppLocalizations.of(context)!;
    return CustomScrollView(slivers: [
      SliverAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.canPop() ? context.pop() : context.go("/");
          },
        ),
        title: Text(i18n.sessionManagemant),
        actions: [
          buildThemeModeIcon(context),
          buildMoreVertSettingsButon(context),
        ],
        floating: true,
      ),
      _buildUserSelect(context),
      _buildSliverGrid(context),
    ]);
  }

  Widget _buildAllUserCheckbox(BuildContext context) {
    if (auth.isRoot != true) return Container();
    final i18n = AppLocalizations.of(context)!;
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        constraints: const BoxConstraints(maxWidth: 200),
        child: LabeledCheckbox(
            label: Text(i18n.allUser),
            value: _allUser,
            onChanged: (v) {
              if (v != null) {
                setState(() {
                  _allUser = v;
                  _fetchData();
                });
              }
            }));
  }

  Widget _buildUserSelectBox(BuildContext context) {
    var userList = _users!;
    if (auth.isRoot != true) {
      userList.removeWhere((e) => e.isAdmin);
    }
    var items = userList
        .map((e) => DropdownMenuItem(value: e.id, child: Text(e.username)))
        .toList();
    final i18n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      constraints: const BoxConstraints(maxWidth: 500),
      child: DropdownButtonFormField<int>(
          items: items,
          onChanged: (v) {
            setState(() {
              _uid = v;
              _fetchData();
            });
          },
          value: _uid ?? auth.user?.id,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: i18n.user,
          )),
    );
  }

  Widget _buildUserSelect(BuildContext context) {
    if (auth.isAdmin != true || _users == null) {
      return SliverToBoxAdapter(child: Container());
    }
    final cs = Theme.of(context).colorScheme;
    final maxWidth = MediaQuery.of(context).size.width;
    return PinnedHeaderSliver(
        child: Container(
            color: cs.surface,
            child: Form(
                key: _formKey,
                child: auth.isRoot != true || maxWidth >= 500
                    ? Row(children: [
                        _buildAllUserCheckbox(context),
                        Expanded(child: _buildUserSelectBox(context)),
                      ])
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            _buildAllUserCheckbox(context),
                            _buildUserSelectBox(context),
                          ]))));
  }

  Widget _buildSliverGrid(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 370.0,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        mainAxisExtent: 200.0,
      ),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final token = _tokens![index]!;
          if (_allUser || (_uid != null && _uid != auth.user?.id)) {
            final ind = _users?.indexWhere((e) => e.id == token.uid);
            if (ind != null && ind > -1) {
              return SessionCard(token, user: _users![ind!]);
            }
          }
          return SessionCard(token);
        },
        childCount: _tokens!.length,
      ),
    );
  }

  void _onStateChanged(dynamic _) {
    setState(() {});
  }

  void _onDeleteSession(dynamic arg) {
    final id = arg as int;
    setState(() {
      _tokens?.removeWhere((e) => e.id == id);
    });
  }
}
