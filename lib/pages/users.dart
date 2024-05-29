import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import '../api/user.dart';
import '../components/user_card.dart';
import '../globals.dart';

final _log = Logger("UsersPage");

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  static const String routeName = '/users';

  @override
  State<UsersPage> createState() => _UsersPage();
}

class _UsersPage extends State<UsersPage> with ThemeModeWidget, IsTopWidget2 {
  List<BUser>? _users;
  bool _isLoading = false;
  CancelToken? _cancel;
  CancelToken? _cancel2;
  Object? _error;
  Future<void> _fetchData() async {
    _cancel2?.cancel();
    try {
      _cancel = CancelToken();
      _isLoading = true;
      final users = (await api.getUsers(all: true, cancel: _cancel)).unwrap();
      if (!_cancel!.isCancelled) {
        setState(() {
          _users = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!_cancel!.isCancelled) {
        _log.severe("Failed to load user list:", e);
        setState(() {
          _error = e;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!tryInitApi(context)) {
      return Container();
    }
    if (auth.isAdmin == false) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        context.go("/");
      });
      return Container();
    }
    final isLoading = _users == null && _error == null;
    if (isLoading && !_isLoading) _fetchData();
    final i18n = AppLocalizations.of(context)!;
    final th = Theme.of(context);
    if (isTop(context)) {
      setCurrentTitle(i18n.userManagemant, th.primaryColor.value);
    }
    return Scaffold(
        appBar: _users == null
            ? AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    context.canPop() ? context.pop() : context.go("/");
                  },
                ),
                title: Text(i18n.userManagemant),
                actions: [
                  buildThemeModeIcon(context),
                  buildMoreVertSettingsButon(context),
                ],
              )
            : null,
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : _users != null
                ? _buildMain(context)
                : Center(
                    child: Text("Error: $_error"),
                  ));
  }

  Widget _buildMain(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(children: [
      _buildUserList(context),
      Positioned(
          bottom: size.height / 10,
          right: size.width / 10,
          child: _buildIconList(context)),
    ]);
  }

  Widget _buildAddIcon(BuildContext context) {
    final i18n = AppLocalizations.of(context)!;
    return IconButton(
        onPressed: () {
          context.push("/dialog/user/new");
        },
        tooltip: i18n.create,
        icon: const Icon(Icons.add));
  }

  Widget _buildIconList(BuildContext context) {
    return Row(children: [
      _buildAddIcon(context),
    ]);
  }

  Widget _buildUserList(BuildContext context) {
    final i18n = AppLocalizations.of(context)!;
    return CustomScrollView(slivers: [
      SliverAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.canPop() ? context.pop() : context.go("/");
          },
        ),
        title: Text(i18n.userManagemant),
        actions: [
          buildThemeModeIcon(context),
          buildMoreVertSettingsButon(context),
        ],
        floating: true,
      ),
      _buildSliverGrid(context),
    ]);
  }

  Widget _buildSliverGrid(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 360.0,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        mainAxisExtent: 80.0,
      ),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return UserCard(_users![index]!);
        },
        childCount: _users!.length,
      ),
    );
  }

  @override
  void dispose() {
    _cancel?.cancel();
    _cancel2?.cancel();
    listener.removeEventListener("new_user", _onNewUser);
    listener.removeEventListener("update_user", _onUpdateUser);
    listener.removeEventListener("delete_user", _onDeleteUser);
    super.dispose();
  }

  @override
  void initState() {
    listener.on("new_user", _onNewUser);
    listener.on("update_user", _onUpdateUser);
    listener.on("delete_user", _onDeleteUser);
    super.initState();
  }

  void _onNewUser(dynamic arg) async {
    int uid = arg as int;
    try {
      _cancel2 = CancelToken();
      final u = (await api.getUser(id: uid, cancel: _cancel2)).unwrap();
      if (!_cancel2!.isCancelled) {
        setState(() {
          _users?.add(u);
        });
      }
    } catch (e) {
      if (!_cancel2!.isCancelled) {
        _log.severe("Failed to load user $uid:", e);
        setState(() {
          _error = e;
        });
      }
    }
  }

  void _onUpdateUser(dynamic arg) {
    final user = arg as BUser;
    if (_users == null) return;
    final index = _users!.indexWhere((v) => v.id == user.id);
    setState(() {
      if (index == -1) {
        _users?.add(user);
      } else {
        _users![index] = user;
      }
    });
  }

  void _onDeleteUser(dynamic arg) {
    final uid = arg as int;
    if (_users == null) return;
    final index = _users!.indexWhere((v) => v.id == uid);
    if (index > -1) {
      setState(() {
        _users!.removeAt(index);
      });
    }
  }
}
