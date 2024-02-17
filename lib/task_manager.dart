import 'package:enum_flag/enum_flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'globals.dart';

enum TaskStatusFilterFlag with EnumFlag {
  wait,
  running,
  finished,
  failed;

  String localText(BuildContext context) {
    final i18n = AppLocalizations.of(context)!;
    switch (this) {
      case TaskStatusFilterFlag.wait:
        return i18n.waiting;
      case TaskStatusFilterFlag.running:
        return i18n.running;
      case TaskStatusFilterFlag.finished:
        return i18n.finished;
      case TaskStatusFilterFlag.failed:
        return i18n.failed;
    }
  }
}

const taskStatusFilterFlagAll = 15;

class TaskStatusFilter {
  TaskStatusFilter({this.code = taskStatusFilterFlagAll});
  int code;
  bool has(TaskStatusFilterFlag flag) => code.hasFlag(flag);
  bool get isAll => code == taskStatusFilterFlagAll;
  void add(TaskStatusFilterFlag flag) {
    code |= flag.value;
  }

  void remove(TaskStatusFilterFlag flag) {
    code &= ~flag.value;
  }
}

class TaskManagerPage extends StatefulWidget {
  const TaskManagerPage({super.key});

  static const String routeName = '/task_manager';

  @override
  State<TaskManagerPage> createState() => _TaskManagerPage();
}

class _TaskManagerPage extends State<TaskManagerPage>
    with ThemeModeWidget, IsTopWidget2 {
  late TaskStatusFilter _filter;
  @override
  void initState() {
    _filter = TaskStatusFilter();
    super.initState();
  }

  Widget _buildChips() {
    final i18n = AppLocalizations.of(context)!;
    var list = <FilterChip>[
      FilterChip(
        label: Text(i18n.allTasks),
        selected: _filter.isAll,
        onSelected: (bool value) {
          setState(() {
            if (value) {
              _filter.code = taskStatusFilterFlagAll;
            } else {
              _filter.code = 0;
            }
          });
        },
      )
    ];
    for (var flag in TaskStatusFilterFlag.values) {
      list.add(FilterChip(
        label: Text(flag.localText(context)),
        selected: _filter.has(flag),
        onSelected: (bool value) {
          setState(() {
            if (value) {
              _filter.add(flag);
            } else {
              _filter.remove(flag);
            }
          });
        },
      ));
    }
    return SliverToBoxAdapter(
        child: Wrap(
      spacing: 5.0,
      children: list,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context)!;
    if (isTop(context)) {
      setCurrentTitle(i18n.taskManager, Theme.of(context).primaryColor.value);
    }
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                context.canPop() ? context.pop() : context.go("/");
              },
            ),
            title: Text(i18n.taskManager),
            actions: [
              buildThemeModeIcon(context),
              buildMoreVertSettingsButon(context),
            ],
            floating: true,
          ),
          _buildChips(),
        ],
      ),
    );
  }
}
