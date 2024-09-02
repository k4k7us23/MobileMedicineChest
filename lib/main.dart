import 'package:flutter/material.dart';
import 'package:medicine_chest/data/medicine/medicine_pack_storage_impl.dart';
import 'package:medicine_chest/data/medicine/medicine_storage_impl.dart';
import 'package:medicine_chest/ui/add_medicine_pack/add_medicine_pack_full.dart';
import 'package:medicine_chest/ui/dependencies/medicine_pack_storage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final MedicinePackStorage medicinePackStorageImpl = MedicinePackStorageImpl();
  final MedicineStorageImpl medicineStorageImpl = MedicineStorageImpl();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
        useMaterial3: true,
      ),
      home: AddMedicinePackFullPage(medicineStorage: medicineStorageImpl, medicinePackStorage: medicinePackStorageImpl,),
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
