import 'package:medicine_chest/entities/medicine.dart';

abstract class MedicineStorage {

  Future<int> saveMedicine(Medicine medicine);

  Future<bool> hasAnyMedicines();

  Future<List<Medicine>> getMedicines();
}