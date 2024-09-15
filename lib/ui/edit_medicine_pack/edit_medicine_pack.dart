import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:medicine_chest/entities/medicine_pack.dart';
import 'package:medicine_chest/ui/add_medicine_pack/medicine_pack_create.dart';
import 'package:medicine_chest/ui/dependencies/medicine_pack_storage.dart';

class EditMedicinePackPage extends StatefulWidget {
  final int packId;
  final MedicinePackStorage medicinePackStorage;

  EditMedicinePackPage(this.packId, this.medicinePackStorage, {super.key});

  @override
  State<StatefulWidget> createState() {
    return _EditMedicinePackState(packId, medicinePackStorage);
  }
}

class _EditMedicinePackState extends State<EditMedicinePackPage> {
  final int packId;

  MedicinePack? _pack = null;
  MedicinePackStorage packStorage;

  final _packCreateKey = GlobalKey<MedicinePackCreateWidgetState>();

  _EditMedicinePackState(this.packId, this.packStorage);

  @override
  void initState() {
    super.initState();
    _loadPack();
  }

  void _loadPack() async {
    MedicinePack? pack = await packStorage.getById(packId);
    if (pack != null) {
      setState(() {
        _pack = pack;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Редактировать упаковку"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {onSave(context)},
        child: const Icon(Icons.check),
      ),
      body: _body(),
    );
  }

  Widget _body() {
    if (_pack == null) {
      return Center(
        child: CircularProgressIndicator(value: null),
      );
    } else {
      return _mainContent(_pack!);
    }
  }

  Widget _mainContent(MedicinePack medicinePack) {
    return Column(
      children: [
        Text(
          medicinePack.medicine!.name,
          style: TextStyle(
              color: Theme.of(context).colorScheme.primary, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          "Упаковка#${medicinePack.getFormattedNumber()}",
          style: TextStyle(fontSize: 18),
        ),
        MedicinePackCreateWidget(
          initialAmount: medicinePack.leftAmount,
          initalExpirationTime: medicinePack.expirationTime,
          key: _packCreateKey,
        )
      ],
    );
  }

  void onSave(BuildContext context) async {
    MedicinePack? medicinePack = _packCreateKey.currentState?.collectOnSave();
    if (medicinePack != null) {
      _pack!.expirationTime = medicinePack.expirationTime;
      _pack!.leftAmount = medicinePack.leftAmount;
      await packStorage.saveMedicinePack(_pack!);

      FocusManager.instance.primaryFocus?.unfocus(); // hide keyboard

      Fluttertoast.showToast(
          msg: "Упаковка обновлена",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.white,
          fontSize: 16.0);

      Navigator.of(context).pop(true);
    }
  }
}
