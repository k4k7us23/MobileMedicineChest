import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medicine_chest/entities/every_day_schedule.dart';
import 'package:medicine_chest/entities/scheme.dart';
import 'package:medicine_chest/ui/add_sheme/add_scheme.dart';
import 'package:medicine_chest/ui/dependencies/medicine_storage.dart';
import 'package:medicine_chest/ui/dependencies/scheme_storage.dart';
import 'package:medicine_chest/ui/shared/delete_confitmation_dialog.dart';
import 'package:medicine_chest/ui/shared/delete_or_edit_dialog.dart';

class SchemeListPage extends StatefulWidget {
  MedicineStorage _medicineStorage;
  SchemeStorage _schemeStorage;

  SchemeListPage(this._medicineStorage, this._schemeStorage, {super.key});

  @override
  State<StatefulWidget> createState() {
    return _SchemeListPageState(_medicineStorage, _schemeStorage);
  }
}

class _SchemeListPageState extends State<SchemeListPage> {
  SchemeStorage _schemeStorage;
  MedicineStorage _medcineStorage;

  _SchemeListPageState(this._medcineStorage, this._schemeStorage);

  List<Scheme>? _schemes = null;

  @override
  void initState() {
    super.initState();
    _loadSchemes();
  }

  void _loadSchemes() async {
    setState(() {
      _schemes = null;
    });
    List<Scheme> loadedSchemes =
        await _schemeStorage.getActiveOrFutureSchemes();
    setState(() {
      _schemes = loadedSchemes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text("Расписания приема"),
        ),
        body: _mainContent(),
        floatingActionButton: FloatingActionButton(
          onPressed: () => {_onAddClicked()},
          child: const Icon(Icons.add),
        ));
  }

  Widget _mainContent() {
    if (_schemes == null) {
      return _loader();
    } else {
      return _mainList();
    }
  }

  Widget _loader() {
    return Center(
        child: CircularProgressIndicator(
      value: null,
    ));
  }

  Widget _scheme(Scheme scheme) {
    return InkWell(child:  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: _schemeContent(scheme),
        ),
        Divider(),
      ],
    ), onTap: (){
      _onSchemeClicked(scheme);
    },);
  }

  void _onSchemeClicked(Scheme scheme) {
    showDeleteOrEditDialog(
      context,
      onDelete: () {
        _onSchemeDeleteClicked(scheme);
      },
      onEdit: () {
        _onEditClicked(scheme.id);
      }
    );
  }

  void _onSchemeDeleteClicked(Scheme scheme) {
    showDeleteConfirmationDialog(context,
        title: "Удаление схемы приема лекарства",
        bodyText:
            "Вы собираетесь удалить схему приема ${scheme.medicine.name}",
       onConfirmed: () {
           _onSchemeDeleteConfirmed(scheme);
       }
    );
  }

  void _onSchemeDeleteConfirmed(Scheme scheme) async {
    await _schemeStorage.deleteScheme(scheme);  
    _loadSchemes();
  }

  Widget _schemeContent(Scheme scheme) {
    var dateFormat = DateFormat("dd.MM.yyyy");

    var startDateFormat =
        dateFormat.format(scheme.takeSchedule.getFirstTakeDay());
    var endDateFormat = dateFormat.format(scheme.takeSchedule.getLastTakeDay());

    final medicineName = scheme.medicine.name;
    final durationString = "С $startDateFormat по $endDateFormat";

    EveryDaySchedule everyDaySchedule = scheme.takeSchedule as EveryDaySchedule;

    var takeCountInDay = everyDaySchedule.getTakeTimesPerDay();
    final takeCountString = "$takeCountInDay раз в день";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          medicineName,
          style: TextStyle(fontSize: 20.0),
        ),
        Text(durationString, style: TextStyle(fontSize: 16.0)),
        Text(takeCountString),
      ],
    );
  }

  Widget _mainList() {
    if (_schemes!.isEmpty) {
      return _emptyText();
    } else {
      return ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return _scheme(_schemes![index]);
          },
          itemCount: _schemes!.length);
    }
  }

  Widget _emptyText() {
    return Center(child: Text("Пока нет созданных схем приема"));
  }

  void _onAddClicked() async {
    bool? newSchemeAdded = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => AddSchemePage(_medcineStorage, _schemeStorage, Scheme.NO_ID)));
    if (newSchemeAdded == true) {
      _loadSchemes();
    }
  }

  void _onEditClicked(int schemeId) async {
    bool? newSchemeAdded = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => AddSchemePage(_medcineStorage, _schemeStorage, schemeId)));
    if (newSchemeAdded == true) {
      _loadSchemes();
    }
  }
}
