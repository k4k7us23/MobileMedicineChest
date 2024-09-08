import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medicine_chest/entities/medicine.dart';
import 'package:medicine_chest/ui/dependencies/medicine_storage.dart';
import 'package:medicine_chest/ui/shared/medicine_release_form_selector.dart';

enum _Type { _select, _create }

class MedicineSelectOrCreateWidget extends StatefulWidget {
  MedicineStorage _medicineStorage;

  MedicineSelectOrCreateWidget(this._medicineStorage, {super.key});

  @override
  State<StatefulWidget> createState() {
    return MedicineSelectOrCreateState(_medicineStorage);
  }
}

class MedicineSelectOrCreateState extends State<MedicineSelectOrCreateWidget> {
  MedicineStorage _medicineStorage;

  MedicineSelectOrCreateState(this._medicineStorage);

  _Type _currentType = _Type._select;
  bool _selectAllowed = true;

  final _createKey = GlobalKey<MedicineCreateWidgetState>();
  final _selectKey = GlobalKey<MedicineSelectWidgetState>();

  @override
  void initState() {
    super.initState();
    initialLoad();
  }

  void initialLoad() async {
    bool hasAnyMedicines = await _medicineStorage.hasAnyMedicines();
    if (!hasAnyMedicines) {
      setState(() {
        _selectAllowed = false;
        _currentType = _Type._create;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var child =
        (_currentType == _Type._create) ? _createNew() : _selectExisting();
    return Column(
      children: [
        _typeSwitcher(),
        Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: child),
      ],
    );
  }

  Widget _typeSwitcher() {
    return SegmentedButton<_Type>(
      segments: <ButtonSegment<_Type>>[
        ButtonSegment<_Type>(
          value: _Type._select,
          label: Text('Выбрать существующее'),
          icon: null,
          enabled: _selectAllowed,
        ),
        ButtonSegment<_Type>(
          value: _Type._create,
          label: Text('Создать новое'),
        )
      ],
      expandedInsets: EdgeInsets.all(8.0),
      selected: {_currentType},
      showSelectedIcon: false,
      onSelectionChanged: (selectedSet) => {
        setState(() {
          _currentType = selectedSet.first;
        })
      },
    );
  }

  Widget _selectExisting() {
    return MedicineSelectWidget(_medicineStorage, key: _selectKey);
  }

  Widget _createNew() {
    return MedicineCreateWidget(key: _createKey);
  }

  Medicine? collectOnSave(BuildContext context) {
    if (_currentType == _Type._create) {
      return _createKey.currentState?.collectOnSave();
    } else {
      return _selectKey.currentState?.collectOnSave(context);
    }
  }
}

class MedicineSelectWidget extends StatefulWidget {
  MedicineStorage _medicineStorage;
  ValueSetter<Medicine?>? onMedicineSetted = null;

  MedicineSelectWidget(this._medicineStorage, {super.key, this.onMedicineSetted});

  @override
  State<StatefulWidget> createState() {
    return MedicineSelectWidgetState(_medicineStorage, onMedicineSetted: this.onMedicineSetted);
  }
}

class MedicineSelectWidgetState extends State<MedicineSelectWidget> {
  MedicineStorage _medicineStorage;

  MedicineSelectWidgetState(this._medicineStorage, {this.onMedicineSetted});

  List<Medicine>? _medicines = null;
  Medicine? _selectedMedicine = null;
  ValueSetter<Medicine?>? onMedicineSetted = null;

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  void _loadMedicines() async {
    var loadedMedicines = await _medicineStorage.getMedicines();
    setState(() {
      _medicines = loadedMedicines;
      if (loadedMedicines.isNotEmpty) {
        _selectedMedicine = loadedMedicines.first;
        onMedicineSetted?.call(_selectedMedicine);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_medicines == null) {
      return Text("Идет загрузка");
    } else if (_medicines!.isEmpty) {
      return Text("Пока нет созданных лекарств");
    } else {
      return Padding(
        padding: EdgeInsets.only(top: 12.0),
        child: _medicineSelector(),
      );
    }
  }

  Widget _medicineSelector() {
    return DropdownMenu<Medicine>(
      initialSelection: _selectedMedicine,
      label: const Text('Выберите лекарство'),
      onSelected: (value) {
        setState(() {
          _selectedMedicine = value;
          onMedicineSetted?.call(_selectedMedicine);
        });
      },
      dropdownMenuEntries: _medicines!.map(_mapToMenuEntry).toList(),
      expandedInsets: EdgeInsets.zero,
    );
  }

  DropdownMenuEntry<Medicine> _mapToMenuEntry(Medicine medicine) {
    String dosagePart = "";
    if (medicine.dosage != null) {
      dosagePart = "(дозировка ${medicine.dosage!.toStringAsFixed(2)})";
    }

    String label = "${medicine.name} (форма выпуска: ${medicine.releaseForm.name}) $dosagePart";

    return DropdownMenuEntry(value: medicine, label: label);
  }

  Medicine? collectOnSave(BuildContext context) {
    if (_selectedMedicine == null) {
      final snackBar = SnackBar(
        content: Text('Необходимо выбрать лекарство.'),
        duration: Duration(seconds: 2), 
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return null;
    }
    return _selectedMedicine;
  }
}

class MedicineCreateWidget extends StatefulWidget {
  const MedicineCreateWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return MedicineCreateWidgetState();
  }
}

class MedicineCreateWidgetState extends State<MedicineCreateWidget> {
  MedicineReleaseForm _releaseForm = MedicineReleaseForm.tablet;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dosageContoller = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
                validator: (value) {
                  var valueWithoutSpaces = value?.replaceAll(" ", "");
                  if (valueWithoutSpaces == null ||
                      valueWithoutSpaces.isEmpty) {
                    return "Название не может быть пустым";
                  }
                  return null;
                },
                controller: _nameController,
                decoration: const InputDecoration(
                    border: UnderlineInputBorder(), labelText: 'Название')),
            SizedBox(height: 20),
            SizedBox(
                width: double.infinity,
                child: MedicineReleaseFormSelectorWidget(_releaseForm,
                    (newReleaseForm) {
                  setState(() {
                    _releaseForm = newReleaseForm;
                  });
                }, menuInsets: EdgeInsets.zero)),
            SizedBox(height: 4),
            TextFormField(
                controller: _dosageContoller,
                validator: (value) {
                  var valueWithoutSpaces = value?.replaceAll(" ", "");
                  if (valueWithoutSpaces == null ||
                      valueWithoutSpaces.isEmpty) {
                    return null;
                  }
                  var leftAmount = NumberFormat().tryParse(valueWithoutSpaces);
                  if (leftAmount == null) {
                    return "Дозировка лекарства должена быть числом";
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Дозировка (действующее вещество)')),
          ],
        ));
  }

  Medicine? collectOnSave() {
    if (_formKey.currentState?.validate() == true) {
      String name = _nameController.text;
      return Medicine(
          id: Medicine.NO_ID, name: name, releaseForm: _releaseForm);
    }
    return null;
  }
}
