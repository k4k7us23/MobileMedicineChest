import 'package:flutter/material.dart';

void showDeleteConfirmationDialog(BuildContext context, {
  required String title,
  required String bodyText,
  VoidCallback? onConfirmed,
  VoidCallback? onCanceled,
}) {
  showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  bodyText,
                  style: TextStyle(fontSize: 18),
                ),
                Text('Продолжить?', style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Отмена'),
              onPressed: () {
                Navigator.of(context).pop();
                onCanceled?.call();
              },
            ),
            TextButton(
              child: const Text('Продолжить'),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirmed?.call();
              },
            ),
          ],
        );
      },
    );
}