import 'package:medicine_chest/entities/medicine.dart';

class MedicinePack {
  int id;
  Medicine? medicine;
  double leftAmount;
  DateTime expirationTime;

  MedicinePack({required this.id, this.medicine, required this.leftAmount, required this.expirationTime});
}