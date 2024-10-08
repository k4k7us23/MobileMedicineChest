import 'package:flutter/material.dart';
import 'package:medicine_chest/entities/medicine.dart';
import 'package:medicine_chest/entities/medicine_pack.dart';
import 'package:medicine_chest/ui/add_medicine_pack/add_medicine_pack_full.dart';
import 'package:medicine_chest/ui/dependencies/medicine_pack_storage.dart';
import 'package:medicine_chest/ui/dependencies/medicine_storage.dart';
import 'package:medicine_chest/ui/edit_medicine/edit_medicine.dart';
import 'package:medicine_chest/ui/edit_medicine_pack/edit_medicine_pack.dart';
import 'package:medicine_chest/ui/medicine_list/medicine_pack_widget.dart';
import 'package:medicine_chest/ui/medicine_list/medicine_packs_title_widget.dart';
import 'package:medicine_chest/ui/medicine_list/medicine_with_packs.dart';
import 'package:medicine_chest/ui/shared/delete_confitmation_dialog.dart';

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
    _loadPacks();
  }

  void _loadPacks() async {
    setState(() {
      _medicineWithPacks = null;
    });
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
      floatingActionButton: FloatingActionButton(
        key: ValueKey("add_medicine_btn"),
        onPressed: () => {_onAddClicked()},
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _loader() {
    return Center(
        child: CircularProgressIndicator(
      value: null,
    ));
  }

  Widget _mainList(List<MedicineWithPacks> medicineWithPacks) {
    if (medicineWithPacks.isEmpty) {
      return _emptyText();
    } else {
      return ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          var medicineWithPack = medicineWithPacks[index];
          var packs = medicineWithPack.packs;

          return ExpansionTile(
            title: _buildTitle(medicineWithPack),
            expandedAlignment: Alignment.topLeft,
            tilePadding: EdgeInsetsDirectional.symmetric(horizontal: 8.0),
            childrenPadding:
                EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            children: packs.map(_buildMedicinePackUi).toList(),
          );
        },
        itemCount: medicineWithPacks.length,
      );
    }
  }

  Widget _emptyText() {
    return Center(child: Text("Пока нет созданных лекарств"));
  }

  Widget _buildTitle(MedicineWithPacks group) {
    return MedicinePacksTitleWidget(
      group,
      onEditClicked: () async {
        bool? medicineEdited = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EditMedicinePage(
              group.medicine.id,
              _medicineStorageImpl,
            ),
          ),
        );

        if (medicineEdited == true) {
          _loadPacks();
        }
      },
    );
  }

  Widget _buildMedicinePackUi(MedicinePack pack) {
    return MedicinePackWidget(
      pack,
      onDelete: _onMedicineDelete,
      onEdit: _onPackEdit,
    );
  }

  Future<List<MedicineWithPacks>> _getMedicineWithPacks() async {
    List<Medicine> medicines = await _medicineStorageImpl.getMedicines();
    List<MedicineWithPacks> result = [];
    for (var medicine in medicines) {
      var packs =
          await _medicinePackStorage.getMedicinePacksByMedicine(medicine);
      packs.sort((packA, packB) =>
          packA.expirationTime.compareTo(packB.expirationTime));
      result.add(MedicineWithPacks(medicine, packs));
    }

    return result;
  }

  void _onAddClicked() async {
    bool? newMedicineAdded = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddMedicinePackFullPage(
          medicineStorage: _medicineStorageImpl,
          medicinePackStorage: _medicinePackStorage,
        ),
      ),
    );
    if (newMedicineAdded == true) {
      _loadPacks();
    }
  }

  void _onMedicineDelete(MedicinePack pack) {
    String medicineName = pack.medicine?.name ?? "";
    showDeleteConfirmationDialog(context,
        title: 'Удаление лекарства',
        bodyText:
            'Вы собираетесь удалить упаковку#${pack.getFormattedNumber()} $medicineName',
        onConfirmed: () {
      _onMedicineDeleteConfirmed(pack);
    });
  }

  void _onPackEdit(MedicinePack pack) async {
    bool? medicineUpdated = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditMedicinePackPage(
          pack.id,
          _medicinePackStorage,
        ),
      ),
    );
    if (medicineUpdated == true) {
      _loadPacks();
    }
  }

  void _onMedicineDeleteConfirmed(MedicinePack pack) async {
    await _medicinePackStorage.deleteMedicinePack(pack);
    _loadPacks();
  }
}
