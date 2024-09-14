import 'package:flutter/material.dart';

void showDeleteOrEditDialog(BuildContext context, {VoidCallback? onEdit, VoidCallback? onDelete}) {
  showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Выберите действие'),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.of(context).pop();
                  onEdit?.call();
                },
                child: const Text('Редактировать'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.of(context).pop();
                  onDelete?.call();
                },
                child: const Text('Удалить'),
              ),
            ],
          );
        });
}