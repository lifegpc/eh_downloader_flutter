import 'dart:ui';
import 'package:enum_flag/enum_flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'api/task.dart';
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

  bool filter(TaskStatus status) {
    if (isAll) return true;
    switch (status) {
      case TaskStatus.wait:
        return has(TaskStatusFilterFlag.wait);
      case TaskStatus.running:
        return has(TaskStatusFilterFlag.running);
      case TaskStatus.finished:
        return has(TaskStatusFilterFlag.finished);
      case TaskStatus.failed:
        return has(TaskStatusFilterFlag.failed);
    }
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
    listener.on("task_list_changed", _onStateChanged);
    super.initState();
  }

  @override
  void dispose() {
    listener.removeEventListener("task_list_changed", _onStateChanged);
    super.dispose();
  }

  void _onStateChanged(dynamic _) {
    setState(() {});
  }

  Widget _buildItem(BuildContext context, int index) {
    final task = tasks.tasks[tasks.tasksList[index]];
    if (task == null) {
      return Container(key: ValueKey("unknown_$index"));
    }
    if (!_filter.filter(task.status)) {
      return Container(key: ValueKey("filtered_task_${task.base.id}"));
    }
    return Padding(
        padding: const EdgeInsets.all(8),
        key: ValueKey("task_${task.base.id}"),
        child: Text("TODO ${task.base.id}"));
  }

  Widget _proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double animValue = Curves.easeInOut.transform(animation.value);
        final double elevation = lerpDouble(0, 6, animValue)!;
        return Material(
          elevation: elevation,
          child: child,
        );
      },
      child: child,
    );
  }

  void _onReorder(int oldIndex, int newIndex) {}

  Widget _buildList(BuildContext context) {
    return SliverReorderableList(
        itemBuilder: _buildItem,
        itemCount: tasks.tasksList.length,
        onReorder: _onReorder,
        proxyDecorator: _proxyDecorator);
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

  Widget _buildView(BuildContext context) {
    final i18n = AppLocalizations.of(context)!;
    return CustomScrollView(
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
        _buildList(context),
      ],
    );
  }

  Widget _buildAddMenu(BuildContext context) {
    return PopupMenuButton(
        icon: const Icon(Icons.add),
        itemBuilder: (context) {
          return [
            PopupMenuItem(
              value: TaskType.download,
              child: Text(AppLocalizations.of(context)!.createDownloadTask),
            )
          ];
        },
        onSelected: (TaskType type) {
          if (type == TaskType.download) {
            context.push("/dialog/new_download_task");
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    if (!tryInitApi(context)) {
      return Container();
    }
    final i18n = AppLocalizations.of(context)!;
    if (isTop(context)) {
      setCurrentTitle(i18n.taskManager, Theme.of(context).primaryColor.value);
    }
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          _buildView(context),
          Positioned(
              bottom: size.height / 10,
              right: size.width / 10,
              child: _buildAddMenu(context))
        ],
      ),
    );
  }
}
