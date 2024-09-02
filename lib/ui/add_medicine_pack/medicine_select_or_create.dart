import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medicine_chest/entities/medicine.dart';
import 'package:medicine_chest/ui/shared/medicine_release_form_selector.dart';

enum _Type { _select, _create }

class MedicineSelectOrCreateWidget extends StatefulWidget {
  const MedicineSelectOrCreateWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return MedicineSelectOrCreateState();
  }
}

class MedicineSelectOrCreateState extends State<MedicineSelectOrCreateWidget> {
  _Type _currentType = _Type._select;

  final _createKey = GlobalKey<MedicineCreateWidgetState>();
  final _selectKey = GlobalKey<MedicineSelectWidgetState>();

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
      segments: const <ButtonSegment<_Type>>[
        ButtonSegment<_Type>(
          value: _Type._select,
          label: Text('Выбрать существующее'),
          icon: null,
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
    return MedicineSelectWidget(key: _selectKey);
  }

  Widget _createNew() {
    return MedicineCreateWidget(key: _createKey);
  }

  Medicine? collectOnSave() {
    if (_currentType == _Type._create) {
        return _createKey.currentState?.collectOnSave();
    } else {
      return _selectKey.currentState?.collectOnSave();
    }
  }
}

class MedicineSelectWidget extends StatefulWidget {

  const MedicineSelectWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return MedicineSelectWidgetState();
  }
}

class MedicineSelectWidgetState extends State<MedicineSelectWidget> {
  @override
  Widget build(BuildContext context) {
     return Text("select existing todo");
  }


  Medicine? collectOnSave() {
    // TODO
    return null;
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
                  if (valueWithoutSpaces == null || valueWithoutSpaces.isEmpty) {
                    return null;
                  }
                  var leftAmount = NumberFormat().tryParse(valueWithoutSpaces);
                  if (leftAmount == null) {
                    return "Дозировка лекарства должена быть числом";
                  }
                  return null;
                } ,
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
        return Medicine(id: Medicine.NO_ID, name: name, releaseForm: _releaseForm);
    }
    return null;
  }
}
