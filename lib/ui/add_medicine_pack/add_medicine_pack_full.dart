import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:medicine_chest/entities/medicine.dart';
import 'package:medicine_chest/entities/medicine_pack.dart';
import 'package:medicine_chest/ui/add_medicine_pack/medicine_pack_create.dart';
import 'package:medicine_chest/ui/add_medicine_pack/medicine_select_or_create.dart';
import 'package:medicine_chest/ui/dependencies/medicine_pack_storage.dart';
import 'package:medicine_chest/ui/dependencies/medicine_storage.dart';

class AddMedicinePackFullPage extends StatefulWidget {
  final MedicineStorage medicineStorage;
  final MedicinePackStorage medicinePackStorage;

  const AddMedicinePackFullPage(
      {super.key,
      required this.medicineStorage,
      required this.medicinePackStorage});

  @override
  State<StatefulWidget> createState() {
    return _AddMedicinePackFullPageState(
        medicineStorage: medicineStorage,
        medicinePackStorage: medicinePackStorage);
  }
}

class _AddMedicinePackFullPageState extends State<AddMedicinePackFullPage> {
  MedicineStorage medicineStorage;
  MedicinePackStorage medicinePackStorage;

  _AddMedicinePackFullPageState(
      {required this.medicineStorage, required this.medicinePackStorage});

  final _packCreateKey = GlobalKey<MedicinePackCreateWidgetState>();
  final _medicineSelectOrCreateKey = GlobalKey<MedicineSelectOrCreateState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Добавить упаковку лекарства"),
      ),
      body: RawScrollbar(
          child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Лекарство", style: _getSectionStyle(context)),
              ),
            ),
            MedicineSelectOrCreateWidget(medicineStorage,
                key: _medicineSelectOrCreateKey),
            Padding(
              padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 40.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Упаковка", style: _getSectionStyle(context)),
              ),
            ),
            MedicinePackCreateWidget(key: _packCreateKey),
            SizedBox(
              height: 20,
            )
          ],
        ),
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {onSave(context)},
        child: const Icon(Icons.check),
      ),
    );
  }

  TextStyle _getSectionStyle(BuildContext context) {
    return TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary);
  }

  void onSave(BuildContext context) async {
    MedicinePack? medicinePack = _packCreateKey.currentState?.collectOnSave();
    Medicine? medicine =
        _medicineSelectOrCreateKey.currentState?.collectOnSave(context);

    if (medicine != null && medicinePack != null) {
      int savedMedicineId = await medicineStorage.saveMedicine(medicine);

      medicine.id = savedMedicineId;
      medicinePack.medicine = medicine;

      await medicinePackStorage.saveMedicinePack(medicinePack);

      FocusManager.instance.primaryFocus?.unfocus(); // hide keyboard

      Fluttertoast.showToast(
          msg: "Лекарство добавлено",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }
}
