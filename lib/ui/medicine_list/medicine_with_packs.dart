import 'package:medicine_chest/entities/medicine.dart';
import 'package:medicine_chest/entities/medicine_pack.dart';

class MedicineWithPacks {
  Medicine medicine;
  List<MedicinePack> packs;

  MedicineWithPacks(this.medicine, this.packs) {
    for (var pack in packs) {
      if (pack.medicine != medicine) {
        throw Exception("All packs should have passed medicine setted");
      }
    }
  }

  double getLeftAmount() {
    double result = 0;
    for (var pack in packs) {
      result += pack.leftAmount;
    }
    return result;
  }
}