import 'package:flutter/material.dart';
import 'package:medicine_chest/entities/medicine.dart';
import 'package:medicine_chest/entities/medicine_pack.dart';
import 'package:medicine_chest/ui/dependencies/medicine_pack_storage.dart';
import 'package:medicine_chest/ui/dependencies/medicine_storage.dart';
import 'package:medicine_chest/ui/medicine_list/medicine_pack_widget.dart';
import 'package:medicine_chest/ui/medicine_list/medicine_packs_title_widget.dart';
import 'package:medicine_chest/ui/medicine_list/medicine_with_packs.dart';

class MedicinesListPage extends StatefulWidget {
  final MedicinePackStorage _medicinePackStorage;
  final MedicineStorage _medicineStorage;

  MedicinesListPage(this._medicineStorage, this._medicinePackStorage,
      {super.key});

  @override
  State<StatefulWidget> createState() {
    return _MedicinesListPageState(_medicineStorage, _medicinePackStorage);
  }
}

class _MedicinesListPageState extends State<MedicinesListPage> {
  final MedicinePackStorage _medicinePackStorage;
  final MedicineStorage _medicineStorageImpl;

  _MedicinesListPageState(this._medicineStorageImpl, this._medicinePackStorage);

  List<MedicineWithPacks>? _medicineWithPacks = null;

  @override
  void initState() {
    super.initState();
    loadPacks();
  }

  void loadPacks() async {
    List<MedicineWithPacks> data = await _getMedicineWithPacks();
    setState(() {
      _medicineWithPacks = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    var child = (_medicineWithPacks == null)
        ? _loader()
        : _mainList(_medicineWithPacks!);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Cписок лекарств"),
      ),
      body: child,
    );
  }

  Widget _loader() {
    return Center(child: CircularProgressIndicator(value: null,)); // todo;
  }

  Widget _mainList(List<MedicineWithPacks> medicineWithPacks) {
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        var medicineWithPack = medicineWithPacks[index];
        var packs = medicineWithPack.packs;

        return ExpansionTile(
          title: _buildTitle(medicineWithPack),
          expandedAlignment: Alignment.topLeft,
          tilePadding: EdgeInsetsDirectional.symmetric(horizontal: 8.0),
          childrenPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          children: packs.map(_buildMedicinePackUi).toList(),
        );
      },
      itemCount: medicineWithPacks.length,
    );
  }

  Widget _buildTitle(MedicineWithPacks group) {
    return MedicinePacksTitleWidget(group);
  }

  Widget _buildMedicinePackUi(MedicinePack pack) {
   return MedicinePackWidget(pack);
  }

  Future<List<MedicineWithPacks>> _getMedicineWithPacks() async {
    List<Medicine> medicines = await _medicineStorageImpl.getMedicines();
    List<MedicineWithPacks> result = [];
    for (var medicine in medicines) {
      var packs =
          await _medicinePackStorage.getMedicinePacksByMedicine(medicine);
      packs.sort((packA, packB) => packA.expirationTime.compareTo(packB.expirationTime));
      result.add(MedicineWithPacks(medicine, packs));
    }

    await Future.delayed(Duration(seconds: 50));
    return result;
  }
}


