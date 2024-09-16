import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medicine_chest/entities/medicine_pack.dart';
import 'package:medicine_chest/ui/shared/date_picker_text_field.dart';

class MedicinePackCreateWidget extends StatefulWidget {

  final double? initialAmount;
  final DateTime? initalExpirationTime; 

  const MedicinePackCreateWidget({super.key, this.initialAmount, this.initalExpirationTime});

  @override
  State<StatefulWidget> createState() {
    return MedicinePackCreateWidgetState(initialAmount, initalExpirationTime);
  }
}

class MedicinePackCreateWidgetState extends State<MedicinePackCreateWidget> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  DateTime _expirationTime = DateTime.now().add(Duration(days: 365));

  final double? _initialAmount;
  final DateTime? _initalExpirationTime; 

  MedicinePackCreateWidgetState(this._initialAmount, this._initalExpirationTime);

  @override
  void initState() {
    super.initState();

    if (_initialAmount != null) {
      _amountController.text = _initialAmount.toStringAsFixed(2);
    }

    if (_initalExpirationTime != null) {
      setState(() {
        _expirationTime = _initalExpirationTime;
      });
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              TextFormField(
                key: ValueKey("left_amount_input"),
                  validator: (value) {
                    var valueWithoutSpaces = value?.replaceAll(" ", "");
                    if (valueWithoutSpaces == null ||
                        valueWithoutSpaces.isEmpty) {
                      return "Остаток не может быть пустым";
                    }

                    var amountLeft = parseAmountLeft(value);
                    if (amountLeft == null) {
                      return "Остаток должен быть числом";
                    }

                    if (amountLeft <= 0) {
                      return "Остаток должен быть больше нуля";
                    }
                    return null;
                  },
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Остаток лекарства')),
              SizedBox(height: 20),
              DatePickerTextField(
                label: "Срок годности",
                initialDate: _expirationTime,
                minDateTime: DateTime.now(),
                dateTimeSetted: (newExpirationDate) => {
                  setState(() {
                    _expirationTime = newExpirationDate;
                  })
                }
              )
            ],
          )),
    );
  }

  double? parseAmountLeft(String? amountString) {
    if (amountString == null) {
      return null;
    } else {
      var amountWithoutSpaces = amountString.replaceAll(" ", "");
      return NumberFormat().tryParse(amountWithoutSpaces)?.toDouble();
    }
  }

  MedicinePack? collectOnSave() {
    if (_formKey.currentState?.validate() == true) {
      double? amountLeft = parseAmountLeft(_amountController.text);
      if (amountLeft != null) {
        return MedicinePack(id: MedicinePack.NO_ID, leftAmount: amountLeft, expirationTime: _expirationTime);
      } else {
        return null;
      }
    }
    return null;
  }
}
