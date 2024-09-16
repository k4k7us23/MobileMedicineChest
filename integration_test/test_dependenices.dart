import 'package:medicine_chest/data/medicine/medicine_storage_impl.dart';
import 'package:medicine_chest/entities/take_record.dart';
import 'package:medicine_chest/ui/dependencies/medicine_pack_storage.dart';
import 'package:medicine_chest/ui/dependencies/medicine_storage.dart';
import 'package:medicine_chest/ui/dependencies/scheme_storage.dart';
import 'package:medicine_chest/ui/dependencies/take_record_storage.dart';

class TestDependenices {
  MedicineStorage medicineStorage;
  MedicinePackStorage medicinePackStorage;
  SchemeStorage schemeStorage;
  TakeRecordStorage takeRecordStorage;

  TestDependenices(
      {required this.medicineStorage,
      required this.medicinePackStorage,
      required this.schemeStorage,
      required this.takeRecordStorage});
}
