import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:medicine_chest/entities/every_day_schedule.dart';
import 'package:medicine_chest/entities/medicine.dart';
import 'package:medicine_chest/entities/scheme.dart';
import 'package:medicine_chest/entities/take_schedule.dart';
import 'package:medicine_chest/ui/add_medicine_pack/medicine_select_or_create.dart';
import 'package:medicine_chest/ui/add_sheme/day_time_moments_selector.dart';
import 'package:medicine_chest/ui/dependencies/medicine_storage.dart';
import 'package:medicine_chest/ui/dependencies/scheme_storage.dart';
import 'package:medicine_chest/ui/shared/date_picker_text_field.dart';

class AddSchemePage extends StatefulWidget {
  MedicineStorage _medicineStorage;
  SchemeStorage _schemeStorage;
  int schemeId;

  AddSchemePage(this._medicineStorage, this._schemeStorage, this.schemeId, {super.key});

  @override
  State<StatefulWidget> createState() {
    return AddSchemeState(_medicineStorage, _schemeStorage, schemeId);
  }
}

class AddSchemeState extends State<AddSchemePage> {
  MedicineStorage _medicineStorage;
  SchemeStorage _schemeStorage;
  int schemeId;

  AddSchemeState(this._medicineStorage, this._schemeStorage, this.schemeId);

  final _selectKey = GlobalKey<MedicineSelectWidgetState>();
  final _formKey = GlobalKey<FormState>();
  DateTime _beginDateTime = DateTime.now();
  DateTime _endDateTime = DateTime.now().add(Duration(days: 7));

  final _dosageSizeController = TextEditingController();

  List<int> _dayTimeMoments = [];

  @override
  void initState() {
    super.initState();

    if (schemeId != Scheme.NO_ID) {
      _loadScheme();
    }
  }

  void _loadScheme() async {
      Scheme? scheme = await _schemeStorage.getById(schemeId);
      if (scheme != null) {
        _applyScheme(scheme);
      }
  }
 
  void _applyScheme(Scheme scheme) {
    _selectKey.currentState?.setMedicine(scheme.medicine);

    _dosageSizeController.text = scheme.oneTakeAmount.toStringAsFixed(2);
    setState(() {
      _beginDateTime = scheme.takeSchedule.getFirstTakeDay();
      _endDateTime = scheme.takeSchedule.getLastTakeDay();

      List<DateTime> timeMoments = scheme.takeSchedule.getTakeMomentsForDay(_beginDateTime);
      List<int> minutesOfTheDay = timeMoments.map((dateTime) => TimeOfDay.fromDateTime(dateTime))
        .map((timeOfDay) => timeOfDay.hour * 60 + timeOfDay.minute).toList();
      _dayTimeMoments = minutesOfTheDay;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(_getPageTitle()),
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
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: _dayTimeMomentsSelector()),
        ]))));
  }

  String _getPageTitle() {
    if (schemeId == Scheme.NO_ID) {
      return "Создать расписание приема";
    } else {
      return "Редактировать расписание приема";
    }
  }

  Widget _mainContent() {
    return Column(children: [
      MedicineSelectWidget(_medicineStorage, key: _selectKey,),
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
        maxDateTime: _endDateTime,
        dateTimeSetted: (newDateTime) => {
              setState(() {
                _beginDateTime = newDateTime;
              })
            },
            key: UniqueKey(),
      );
  }

  Widget _lastDaySelectorWidget() {
    return DatePickerTextField(
        label: "Последний день приема",
        initialDate: _endDateTime,
        minDateTime: _beginDateTime,
        dateTimeSetted: (newDateTime) => {
              setState(() {
                _endDateTime = newDateTime;
              })
            },
        key: UniqueKey(),
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

  Widget _dayTimeMomentsSelector() {
    return DayTimeMomentsSelector(initialDayTimeMoments: _dayTimeMoments, (dayTimeMoments) {
      setState(() {
        _dayTimeMoments = dayTimeMoments;
      });
    }, key: UniqueKey());
  }

  onSave(BuildContext _context) async {
    Medicine? medicine = _selectKey.currentState?.collectOnSave(context);
    if (_formKey.currentState?.validate() == true && medicine != null) {
      double? oneTakeAmount = _parseDosageLeft(_dosageSizeController.text);
      if (oneTakeAmount == null) {
        return;
      }
      if (_dayTimeMoments.isEmpty) {
        Fluttertoast.showToast(
            msg: "Необходимо задать хотя бы один момент времени",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            textColor: Colors.white,
            fontSize: 16.0);
        return;
      }

      TakeSchedule everyDaySchedule = EveryDaySchedule.create(
          _dayTimeMoments.map((minutes) => minutes * 60).toList(), _beginDateTime, _endDateTime);
      Scheme scheme =
          Scheme(schemeId, medicine, oneTakeAmount, everyDaySchedule);

      final int id = await _schemeStorage.saveScheme(scheme);

      Fluttertoast.showToast(
          msg: "Схема приема создана",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.white,
          fontSize: 16.0);

      Navigator.of(context).pop(true);
    }
  }
}
