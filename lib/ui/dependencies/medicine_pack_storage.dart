import 'package:medicine_chest/entities/medicine_pack.dart';

abstract class MedicinePackStorage {

  Future<int> saveMedicinePack(MedicinePack pack);
}