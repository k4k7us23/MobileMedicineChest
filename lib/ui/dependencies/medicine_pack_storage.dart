import 'package:medicine_chest/entities/medicine.dart';
import 'package:medicine_chest/entities/medicine_pack.dart';

abstract class MedicinePackStorage {

  Future<int> saveMedicinePack(MedicinePack pack);

  Future<List<MedicinePack>> getMedicinePacksByMedicine(Medicine medicine);
}