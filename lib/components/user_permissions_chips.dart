import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../api/user.dart';

class UserPermissionsChips extends StatefulWidget {
  const UserPermissionsChips(
      {super.key, this.permissions, this.onChanged, this.readOnly = false});
  final UserPermissions? permissions;
  final ValueChanged<UserPermissions>? onChanged;
  final bool readOnly;

  @override
  State<StatefulWidget> createState() => _UserPermissionsChips();
}

class _UserPermissionsChips extends State<UserPermissionsChips> {
  late UserPermissions _permissions;
  @override
  void initState() {
    _permissions = widget.permissions ?? UserPermissions(0);
    super.initState();
  }

  void _onChanged() {
    if (widget.onChanged != null) {
      widget.onChanged!(_permissions);
    }
  }

  Widget _buildChips(BuildContext context) {
    final i18n = AppLocalizations.of(context)!;
    var list = <FilterChip>[
      FilterChip(
        label: Text(i18n.allPermissions),
        selected: _permissions.isAll,
        onSelected: widget.readOnly
            ? null
            : (bool value) {
                setState(() {
                  if (value) {
                    _permissions.code = userPermissionAll;
                  } else {
                    _permissions.code = 0;
                  }
                });
                _onChanged();
              },
      )
    ];
    for (var flag in UserPermission.values) {
      list.add(FilterChip(
        label: Text(flag.localText(context)),
        selected: _permissions.has(flag),
        onSelected: widget.readOnly
            ? null
            : (bool value) {
                setState(() {
                  if (value) {
                    _permissions.add(flag);
                  } else {
                    _permissions.remove(flag);
                  }
                });
                _onChanged();
              },
      ));
    }
    return Wrap(spacing: 5.0, children: list);
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context)!;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            const Icon(Icons.person),
            Text(i18n.userPermissions, style: const TextStyle(fontSize: 20)),
          ])),
      _buildChips(context),
    ]);
  }
}
