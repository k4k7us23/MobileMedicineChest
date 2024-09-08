import 'package:medicine_chest/entities/medicine.dart';
import 'package:medicine_chest/entities/medicine_pack.dart';

class TakeRecord {
  static const int NO_ID = -1;

  int id;
  Medicine medicine;
  DateTime takeTime;

  Map<MedicinePack, double> takeAmountByPack;

  TakeRecord(this.id, this.medicine, this.takeTime, this.takeAmountByPack);

  double getTakenAmount() {
    double result = 0.0;
    takeAmountByPack.forEach((_, amount){
      result += amount;
    }); 
    return result;
  }

}