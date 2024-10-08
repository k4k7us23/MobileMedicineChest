import 'dart:async';
import 'package:flutter/material.dart';
import 'package:medicine_chest/entities/medicine_pack.dart';
import 'package:medicine_chest/ui/shared/delete_or_edit_dialog.dart';

class MedicinePackWidget extends StatefulWidget {
  final MedicinePack _pack;
  Function(MedicinePack pack)? onDelete = null;
  Function(MedicinePack pack)? onEdit = null;

  MedicinePackWidget(this._pack, {this.onDelete, this.onEdit, super.key});

  @override
  State<StatefulWidget> createState() {
    return _MedicinePackState(_pack, onDelete: onDelete, onEdit: onEdit);
  }
}

class _MedicinePackState extends State<MedicinePackWidget> {
  static final Duration _INVALIDATE_EXPIRATION_INTERVAL = Duration(seconds: 30);
  final MedicinePack _pack;
  Function(MedicinePack pack)? onDelete = null;
  Function(MedicinePack pack)? onEdit = null;

  _MedicinePackState(this._pack, {this.onDelete, this.onEdit});

  Timer? _timer;
  var _isExpired = false;

  @override
  void initState() {
    super.initState();
    _isExpired = _pack.isExpired();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(_INVALIDATE_EXPIRATION_INTERVAL, (timer) {
      setState(() {
        _isExpired = _pack.isExpired();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return InkWell(
        onTap: _onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                "Упаковка #${_pack.getFormattedNumber()}",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.secondary),
              ),
              _buildExpirationTime(context)
            ]),
            Text("Остаток: ${_pack.leftAmount.toStringAsFixed(2)}"),
          ],
        ));
  }

  void _onTap() {
    showDeleteOrEditDialog(context, onEdit: () {
      onEdit?.call(_pack);
    }, onDelete: () {
      onDelete?.call(_pack);
    });
  }

  Widget _buildExpirationTime(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (_isExpired) {
      return Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Row(
            children: [
              Icon(
                Icons.warning,
                color: colorScheme.error,
              ),
              Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: _buildExpiredText(context)),
            ],
          ));
    } else {
      return Text(key: ValueKey("medicine_expire_at_text"), "Срок годности: ${_pack.getFormattedExpirationTime()}");
    }
  }

  Widget _buildExpiredText(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Text.rich(
      key: ValueKey("medicine_expired_text"),
      TextSpan(
        children: [
          TextSpan(
            text: 'Просрочено \n',
            style: TextStyle(
                fontSize: 16,
                color: colorScheme.error,
                fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: _pack.getFormattedExpirationTime(),
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
