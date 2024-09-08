import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medicine_chest/entities/medicine_pack.dart';

class SelectableMedicinePackWidget extends StatelessWidget {
  MedicinePack _medicinePack;
  bool _isSelected;
  VoidCallback _onCheckBoxClick;

  SelectableMedicinePackWidget(
      this._medicinePack, this._isSelected, this._onCheckBoxClick,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [_mainColumn(context), _checkBox()]);
  }

  Widget _mainColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title(),
        _leftAmount(context),
        _validUntil(context),
      ],
    );
  }

  Widget _checkBox() {
    return Checkbox(
        value: _isSelected, onChanged: (value) => {_onCheckBoxClick()});
  }

  Widget _title() {
    var titleString = "Упаковка #${_medicinePack.id}";
    return Text(
      titleString,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _leftAmount(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: [
          TextSpan(text: "Остаток: "),
          TextSpan(
              text: _medicinePack.leftAmount.toStringAsFixed(2),
              style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _validUntil(BuildContext context) {
    var dateFormat = DateFormat("dd.MM.yyyy");
    var validUntilString = dateFormat.format(_medicinePack.expirationTime);

    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: [
          TextSpan(text: "Годен до: "),
          TextSpan(
              text: validUntilString,
              style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
