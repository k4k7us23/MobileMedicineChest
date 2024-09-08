import 'package:flutter/material.dart';
import 'package:medicine_chest/entities/medicine.dart';
import 'package:medicine_chest/entities/medicine_pack.dart';
import 'package:medicine_chest/ui/dependencies/medicine_pack_storage.dart';
import 'package:medicine_chest/ui/take_medicine/selectable_medicine_pack.dart';

class MedicinePackSelectionWidget extends StatefulWidget {
  MedicinePackStorage _medicinePackStorage;

  Medicine _medicine;

  ValueSetter<Set<MedicinePack>>? onSelectedPacksUpdated;

  MedicinePackSelectionWidget(this._medicine, this._medicinePackStorage,
      {super.key, this.onSelectedPacksUpdated});

  @override
  State<StatefulWidget> createState() {
    return _MedicinePackSelectionState(
      _medicinePackStorage,
      _medicine,
      onSelectedPacksUpdated,
    );
  }
}

class _MedicinePackSelectionState extends State<MedicinePackSelectionWidget> {
  MedicinePackStorage _medicinePackStorage;
  Medicine _medicine;

  List<MedicinePack>? _packs = null;
  ValueSetter<Set<MedicinePack>>? _onSelectedPacksUpdated;
  Set<MedicinePack> _selectedMedicinePacks = {};

  _MedicinePackSelectionState(
      this._medicinePackStorage, this._medicine, this._onSelectedPacksUpdated);

  @override
  void initState() {
    super.initState();
    _loadPacks();
  }

  void _loadPacks() async {
    List<MedicinePack> packs =
        await _medicinePackStorage.getMedicinePacksByMedicine(_medicine);
    packs.sort(
        (pack1, pack2) => pack1.expirationTime.compareTo(pack2.expirationTime));
    setState(() {
      _packs = packs;
      if (packs.isNotEmpty) {
        addPackToSelection(packs[0]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_packs == null) {
      return _loading();
    } else {
      return _mainContent(_packs!);
    }
  }

  Widget _loading() {
    return Text("Идет загрузка");
  }

  Widget _mainContent(List<MedicinePack> medicinePacks) {
    if (medicinePacks.isNotEmpty) {
      return _list(medicinePacks);
    } else {
      return Text("Отсуствуют упаковки для выбранного лекарства");
    }
  }

  Widget _list(List<MedicinePack> medicinePacks) {
    return ListView.builder(
      itemBuilder: (context, index) {
        if (index > 0) {
          return _packItem(medicinePacks[index - 1]);
        } else {
          return Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: _totalSelectedSection(context));
        }
      },
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: medicinePacks.length + 1,
    );
  }

  Widget _totalSelectedSection(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: [
          TextSpan(text: "Суммарный остаток в выбранных упаковках: "),
          TextSpan(
              text: _getSelectedTotalAmount().toStringAsFixed(2),
              style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _packItem(MedicinePack medicinePack) {
    var isSelected = _selectedMedicinePacks.contains(medicinePack);

    var item = SelectableMedicinePackWidget(medicinePack, isSelected, () {
      if (_selectedMedicinePacks.contains(medicinePack)) {
        removePackFromSelection(medicinePack);
      } else {
        addPackToSelection(medicinePack);
      }
    });
    return Column(children: [
      Padding(padding: EdgeInsets.symmetric(vertical: 4), child: item),
      Divider()
    ]);
  }

  void addPackToSelection(MedicinePack pack) {
    setState(() {
      _selectedMedicinePacks.add(pack);
      _onSelectedPacksUpdated?.call({..._selectedMedicinePacks});
    });
  }

  void removePackFromSelection(MedicinePack pack) {
    setState(() {
      _selectedMedicinePacks.remove(pack);
      _onSelectedPacksUpdated?.call({..._selectedMedicinePacks});
    });
  }

  double _getSelectedTotalAmount() {
    var result = 0.0;
    for (var selectedPack in _selectedMedicinePacks) {
      result += selectedPack.leftAmount;
    }
    return result;
  }
}
