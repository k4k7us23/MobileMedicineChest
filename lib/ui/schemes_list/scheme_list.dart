import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medicine_chest/entities/every_day_schedule.dart';
import 'package:medicine_chest/entities/scheme.dart';
import 'package:medicine_chest/ui/add_sheme/add_scheme.dart';
import 'package:medicine_chest/ui/dependencies/medicine_storage.dart';
import 'package:medicine_chest/ui/dependencies/scheme_storage.dart';

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
    _loadPacks();
  }

  void _loadPacks() async {
    setState(() {
      _schemes = null;
    });
    List<Scheme> loadedSchemes = await _schemeStorage.getActiveOrFutureSchemes();
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
        onPressed: () => { _onAddClicked() },
        child: const Icon(Icons.add),
      )
    );
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
    return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
     
      children: [
        Padding(padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0), child: _schemeContent(scheme),),
        Divider(),
      ],
    );
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
    return ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return _scheme(_schemes![index]);
        },
        itemCount: _schemes!.length);
  }

  void _onAddClicked() async {
    bool? newSchemeAdded = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => AddSchemePage(_medcineStorage, _schemeStorage))
    );
    if (newSchemeAdded == true) {
      _loadPacks();
    }
  }
}
