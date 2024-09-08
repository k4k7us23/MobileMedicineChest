import 'dart:math';

import 'package:medicine_chest/entities/medicine_pack.dart';

class DistributionException implements Exception {
  final String message;
  
  DistributionException(this.message);
  
  @override
  String toString() => 'DistributionException: $message';
}

class TakeMedicineDistributor {

  Map<MedicinePack, double> getDistribution(List<MedicinePack> packs, double amount) {
    List<MedicinePack> sortedByExpTime = [...packs];
    
    sortedByExpTime.sort((p1, p2) => p1.expirationTime.compareTo(p2.expirationTime));
    double takenAmount = 0;
    int index = 0;
    Map<MedicinePack, double> result = {};

    while (takenAmount < amount && index < packs.length) {
      MedicinePack pack = sortedByExpTime[index];

      double curTakeAmount = min(amount - takenAmount, pack.leftAmount) ;

      result[pack] = curTakeAmount;
      takenAmount += curTakeAmount;
      index++;
    }

    if (takenAmount < amount) {
      throw DistributionException("Выбранных упаковок не хватает лекарства");
    }

    return result;
  }
  
}