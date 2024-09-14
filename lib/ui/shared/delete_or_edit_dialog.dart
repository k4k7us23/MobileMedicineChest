import 'package:flutter/material.dart';

void showDeleteOrEditDialog(
  BuildContext context, {
  VoidCallback? onEdit,
  VoidCallback? onDelete,
  bool showEdit = true,
}) {
  showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Выберите действие'),
          children: _getOptions(context, onEdit, onDelete, showEdit),
        );
      });
}

List<Widget> _getOptions(BuildContext context, VoidCallback? onEdit,
    VoidCallback? onDelete, bool showEdit) {
  List<Widget> result = [];
  if (showEdit) {
    result.add(SimpleDialogOption(
      onPressed: () {
        Navigator.of(context).pop();
        onEdit?.call();
      },
      child: const Text('Редактировать'),
    ));
  }
  result.add(SimpleDialogOption(
    onPressed: () {
      Navigator.of(context).pop();
      onDelete?.call();
    },
    child: const Text('Удалить'),
  ));
  return result;
}
