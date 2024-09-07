import 'package:medicine_chest/entities/medicine.dart';
import 'package:medicine_chest/entities/take_schedule.dart';

class Scheme {
  static const int NO_ID = -1;

  int id;
  Medicine medicine;
  double oneTakeAmount = 1.0;
  TakeSchedule takeSchedule;

  Scheme(this.id, this.medicine, this.oneTakeAmount, this.takeSchedule);
}