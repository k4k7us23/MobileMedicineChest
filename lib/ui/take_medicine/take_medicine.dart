import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:medicine_chest/entities/medicine.dart';
import 'package:medicine_chest/entities/medicine_pack.dart';
import 'package:medicine_chest/entities/take_record.dart';
import 'package:medicine_chest/ui/add_medicine_pack/medicine_select_or_create.dart';
import 'package:medicine_chest/ui/dependencies/medicine_pack_storage.dart';
import 'package:medicine_chest/ui/dependencies/medicine_storage.dart';
import 'package:medicine_chest/ui/dependencies/take_record_storage.dart';
import 'package:medicine_chest/ui/shared/date_picker_text_field.dart';
import 'package:medicine_chest/ui/shared/time_picker_text_field.dart';
import 'package:medicine_chest/ui/take_medicine/packs_selection_widget.dart';
import 'package:medicine_chest/ui/take_medicine/take_medicine_distributor.dart';

class TakeMedicinePage extends StatefulWidget {
  MedicineStorage _medicineStorage;
  MedicinePackStorage _medicinePackStorage;
  TakeRecordStorage _takeRecordStorage;

  TakeMedicinePage(
      this._medicineStorage, this._medicinePackStorage, this._takeRecordStorage,
      {super.key});

  @override
  State<StatefulWidget> createState() {
    return _TakeMedicinePage(
        _medicineStorage, _medicinePackStorage, _takeRecordStorage);
  }
}

class _TakeMedicinePage extends State<TakeMedicinePage> {
  MedicineStorage _medicineStorage;
  MedicinePackStorage _medicinePackStorage;
  TakeRecordStorage _takeRecordStorage;

  _TakeMedicinePage(this._medicineStorage, this._medicinePackStorage,
      this._takeRecordStorage);

  final _formKey = GlobalKey<FormState>();
  final _dosageSizeController = TextEditingController();

  var _takeDate = DateTime.now();
  var _takeTime = TimeOfDay.now();
  Medicine? _selectedMedicine = null;
  Set<MedicinePack> _selectedPacks = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text("Принять лекарство"),
        ),
        body: RawScrollbar(
            child: SingleChildScrollView(child: _mainContent(context))),
        floatingActionButton: FloatingActionButton(
          onPressed: () => {_onSaveClicked()},
          child: const Icon(Icons.check),
        ));
  }

  Widget _mainContent(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _medicineSelector(),
            _spaceBetweenInputs(),
            _creationDate(),
            _spaceBetweenInputs(),
            _creationTime(),
            _spaceBetweenInputs(),
            _dosageSizeWidget(),
            _spaceBetweenInputs(),
            _packsSectionTitle(context),
            _packSelectionWidget(context),
          ],
        ));
  }

  Widget _medicineSelector() {
    return MedicineSelectWidget(
      _medicineStorage,
      onMedicineSetted: (value) => {
        setState(() {
          _selectedMedicine = value;
        })
      },
    );
  }

  Widget _creationDate() {
    return DatePickerTextField(
        label: "Дата приема",
        initialDate: _takeDate,
        minDateTime: null,
        maxDateTime: null,
        dateTimeSetted: (newDateTime) => {
              setState(() {
                _takeDate = newDateTime;
              })
            });
  }

  Widget _creationTime() {
    return TimePickerTextField(
      label: "Время приема",
      initalTime: _takeTime,
      timeSetted: (newTime) => {
        setState(() {
          _takeTime = newTime;
        })
      },
    );
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

  Widget _packsSectionTitle(BuildContext context) {
    var textColor = Theme.of(context).colorScheme.primary;
    return Text("Выберите упаковки лекарства",
        style: TextStyle(
            fontSize: 18, color: textColor, fontWeight: FontWeight.bold));
  }

  Widget _packSelectionWidget(BuildContext context) {
    if (_selectedMedicine == null) {
      return SizedBox.shrink();
    } else {
      return Padding(
          padding: EdgeInsets.only(top: 0.0),
          child: MedicinePackSelectionWidget(
              _selectedMedicine!, _medicinePackStorage,
              onSelectedPacksUpdated: (packs) => {_selectedPacks = packs}));
    }
  }

  Widget _spaceBetweenInputs() {
    return SizedBox(height: 10);
  }

  DateTime _getTakeTime() {
    return _takeDate.copyWith(hour: _takeTime.hour, minute: _takeTime.minute);
  }

  void _onSaveClicked() async {
    if (_formKey.currentState?.validate() == true &&
        _selectedMedicine != null) {
      double? oneTakeAmount = _parseDosageLeft(_dosageSizeController.text);
      if (oneTakeAmount == null) {
        return;
      }
      DateTime takeTime = _getTakeTime();

      final packsDistributor = TakeMedicineDistributor();
      Map<MedicinePack, double>? takeAmountByPack;
      try {
        takeAmountByPack = packsDistributor.getDistribution(
            _selectedPacks.toList(), oneTakeAmount);
      } on DistributionException catch (e) {
        Fluttertoast.showToast(
          msg: e.message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.white,
          fontSize: 16.0);
        return;
      }

      TakeRecord takeRecord = TakeRecord(
          TakeRecord.NO_ID, _selectedMedicine!, takeTime, takeAmountByPack);

      await _takeRecordStorage.saveTakeRecord(takeRecord);

      Fluttertoast.showToast(
          msg: "Лекарство принято",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.white,
          fontSize: 16.0);

      Navigator.of(context).pop(true);
    }
  }
}
