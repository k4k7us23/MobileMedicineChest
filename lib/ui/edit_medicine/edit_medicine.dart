import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:medicine_chest/entities/medicine.dart';
import 'package:medicine_chest/ui/add_medicine_pack/medicine_select_or_create.dart';
import 'package:medicine_chest/ui/dependencies/medicine_storage.dart';

class EditMedicinePage extends StatefulWidget {
  final int _medicineId;
  final MedicineStorage _medicineStorage;

  EditMedicinePage(this._medicineId, this._medicineStorage, {super.key});

  @override
  State<StatefulWidget> createState() {
    return EditMedicinePageState(_medicineId, _medicineStorage);
  }
}

class EditMedicinePageState extends State<EditMedicinePage> {
  Medicine? _medicine = null;

  final int medicineId;
  final MedicineStorage _medicineStorage;
  final _createKey = GlobalKey<MedicineCreateWidgetState>();

  EditMedicinePageState(this.medicineId, this._medicineStorage);

  @override
  void initState() {
    super.initState();
    loadMedicine();
  }

  void loadMedicine() async {
    Medicine? medicine = await _medicineStorage.getMedicineById(medicineId);
    if (medicine != null) {
      setState(() {
        _medicine = medicine;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Редактировать лекарство"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {_onSave(context)},
        child: const Icon(Icons.check),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: _body(),
      ),
    );
  }

  Widget _body() {
    if (_medicine == null) {
      return Center(
        child: CircularProgressIndicator(value: null),
      );
    } else {
      return _mainContent(_medicine!);
    }
  }

  Widget _mainContent(Medicine medicine) {
    return MedicineCreateWidget(
      initialMedicine: _medicine,
      showScannerButton: false,
      key: _createKey,
    );
  }

  void _onSave(BuildContext context) async {
    Medicine? newMedicine = _createKey.currentState!.collectOnSave();
    if (newMedicine != null && _medicine != null) {
      _medicine!.name = newMedicine.name;
      _medicine!.releaseForm = newMedicine.releaseForm;
      _medicine!.dosage = newMedicine.dosage;

      await _medicineStorage.saveMedicine(_medicine!);

      Fluttertoast.showToast(
          msg: "Лекарство обновлено",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.white,
          fontSize: 16.0);

      Navigator.of(context).pop(true);
    }
    // TODO
  }
}
