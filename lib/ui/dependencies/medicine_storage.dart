import 'package:medicine_chest/entities/medicine.dart';

abstract class MedicineStorage {

  int saveMedicine(Medicine medicine);
}