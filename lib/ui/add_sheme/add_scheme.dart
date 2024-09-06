import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medicine_chest/entities/medicine.dart';
import 'package:medicine_chest/ui/add_medicine_pack/medicine_select_or_create.dart';
import 'package:medicine_chest/ui/add_sheme/day_time_moments_selector.dart';
import 'package:medicine_chest/ui/dependencies/medicine_storage.dart';
import 'package:medicine_chest/ui/shared/date_picker_text_field.dart';

class AddSchemePage extends StatefulWidget {
  MedicineStorage _medicineStorage;

  AddSchemePage(this._medicineStorage, {super.key});

  @override
  State<StatefulWidget> createState() {
    return AddSchemeState(_medicineStorage);
  }
}

class AddSchemeState extends State<AddSchemePage> {
  MedicineStorage _medicineStorage;

  AddSchemeState(this._medicineStorage);

  final _selectKey = GlobalKey<MedicineSelectWidgetState>();
  final _formKey = GlobalKey<FormState>();
  DateTime _beginDateTime = DateTime.now();
  DateTime _endDateTime = DateTime.now().add(Duration(days: 7));

  final _dosageSizeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text("Создать расписание приема"),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => {onSave(context)},
          child: const Icon(Icons.check),
        ),
        body: RawScrollbar(
            child: SingleChildScrollView(
                child: Column(children: [
          Padding(
              padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
              child: _mainContent()),
          Padding(padding: EdgeInsets.symmetric(horizontal: 8.0), child:  _dayTimeMomentsSelector()),
        ]))));
  }

  Widget _mainContent() {
    return Column(children: [
      MedicineSelectWidget(_medicineStorage),
      _spaceBetweenInputs(),
      _firstDaySelectorWidget(),
      _spaceBetweenInputs(),
      _lastDaySelectorWidget(),
      _spaceBetweenInputs(),
      _dosageSizeWidget(),
      _spaceBetweenInputs(),
    ]);
  }

  Widget _spaceBetweenInputs() {
    return SizedBox(height: 10);
  }

  Widget _firstDaySelectorWidget() {
    return DatePickerTextField(
        label: "Первый день приема",
        initialDate: _beginDateTime,
        minDateTime: null,
        dateTimeSetted: (newDateTime) => {
              setState(() {
                _beginDateTime = newDateTime;
              })
            });
  }

  Widget _lastDaySelectorWidget() {
    return DatePickerTextField(
        label: "Последний день приема",
        initialDate: _endDateTime,
        minDateTime: null,
        dateTimeSetted: (newDateTime) => {
              setState(() {
                _endDateTime = newDateTime;
              })
            });
  }

  Widget _dosageSizeWidget() {
    return Form(
        key: _formKey,
        child: TextFormField(
            validator: (value) {
              var valueWithoutSpaces = value?.replaceAll(" ", "");
              if (valueWithoutSpaces == null || valueWithoutSpaces.isEmpty) {
                return "Необходимо указать размер дозы";
              }

              var amountLeft = _parseDosageLeft(value);
              if (amountLeft == null) {
                return "Размер дозы должен быть числом";
              }
              return null;
            },
            controller: _dosageSizeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
                border: UnderlineInputBorder(), labelText: 'Размер дозы')));
  }

  double? _parseDosageLeft(String? dosage) {
    if (dosage == null) {
      return null;
    } else {
      var amountWithoutSpaces = dosage.replaceAll(" ", "");
      return NumberFormat().tryParse(amountWithoutSpaces)?.toDouble();
    }
  }

  Widget _dayTimeMomentsSelector() {
    return DayTimeMomentsSelector();
  }

  onSave(BuildContext _context) async {
    Medicine? medicine = _selectKey.currentState?.collectOnSave(context);
    if (_formKey.currentState?.validate() == true) {
      // todo save scheme
    }
  }
}
