import 'package:flutter/material.dart';
import 'package:medicine_chest/data/database_creator.dart';
import 'package:medicine_chest/data/medicine/medicine_pack_storage_impl.dart';
import 'package:medicine_chest/data/medicine/medicine_storage_impl.dart';
import 'package:medicine_chest/ui/dependencies/medicine_pack_storage.dart';
import 'package:medicine_chest/ui/medicine_list/medicine_list.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = openDatabase(
    join(await getDatabasesPath(), 'medicine.db'),
    onCreate: (db, version) {
      var dbCreator = DatabaseCreator(db);
      dbCreator.create();
    },
    version: DatabaseCreator.DATABASE_VERSION
  );

  final medicineStorageImpl = MedicineStorageImpl(database);
  final medicinePackStorageImpl = MedicinePackStorageImpl(database);

  runApp(MyApp(medicinePackStorageImpl: medicinePackStorageImpl, medicineStorageImpl: medicineStorageImpl,));
}

class MyApp extends StatelessWidget {
  final MedicinePackStorage medicinePackStorageImpl;
  final MedicineStorageImpl medicineStorageImpl;

  const MyApp(
      {super.key,
      required this.medicinePackStorageImpl,
      required this.medicineStorageImpl});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
        useMaterial3: true,
      ),
      home: MedicinesListPage(medicineStorageImpl, medicinePackStorageImpl),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
