import 'package:intl/intl.dart';
import 'package:medicine_chest/entities/medicine.dart';

class MedicinePack {
  int id;
  Medicine? medicine;
  double leftAmount;
  DateTime expirationTime;

  MedicinePack(
      {required this.id,
      this.medicine,
      required this.leftAmount,
      required this.expirationTime});

  static int NO_ID = -1;

  bool isExpired() {
    var diffrence = DateTime.now().difference(expirationTime);
    return diffrence.inDays >= 1;
  }

  String getFormattedNumber() {
    return (id + 1).toString();
  }

  String getFormattedExpirationTime() {
    return DateFormat("dd.MM.yyyy").format(expirationTime);
  }

  @override
  bool operator ==(Object other) {
    return other is MedicinePack &&
        other.id == id &&
        other.medicine == medicine &&
        other.leftAmount == leftAmount &&
        other.expirationTime == expirationTime;
  }

  @override
  int get hashCode => id;
}
