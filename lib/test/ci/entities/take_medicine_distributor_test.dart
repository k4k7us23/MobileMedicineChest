import 'dart:ffi';
import 'dart:math';

import 'package:medicine_chest/entities/medicine_pack.dart';
import 'package:medicine_chest/ui/take_medicine/take_medicine_distributor.dart';
import 'package:test/test.dart';


List<MedicinePack> _createPacks(List<int> expTime, List<double> leftAmount) {
  List<MedicinePack> result = [];

  for (int i = 0; i < expTime.length; i++) {
    var curExpTime = expTime[i];
    var curLeftAmount = leftAmount[i];
    
    result.add(MedicinePack(id: i, leftAmount: curLeftAmount, expirationTime: DateTime.fromMicrosecondsSinceEpoch(curExpTime)));
  }

  return result;
}

void main() {
  group("One package", () {
    test('Only one package test enough amount', () {
        final takeAmount = 10.0;

        var packs = _createPacks([23], [200]);
        var result = TakeMedicineDistributor().getDistribution(packs, takeAmount);

        expect(result.length, 1);
        expect(result.values.first, takeAmount);
    });

    test('Only one package test not enought amount', () {
        final takeAmount = 250.0;

        var packs = _createPacks([23], [200]);

        expect(() => TakeMedicineDistributor().getDistribution(packs, takeAmount), throwsA(isA<DistributionException>()));
    });
  });

  test("Take all packs", () {
      final takeAmount = 60.0;

      var packs = _createPacks([1, 2, 3], [10, 20, 30]);
      var result = TakeMedicineDistributor().getDistribution(packs, takeAmount);

      expect(result.length, 3);
      expect(result[packs[0]], 10);
      expect(result[packs[1]], 20);
      expect(result[packs[2]], 30);
  });

  test("Take by expiration time test", () {
      final takeAmount = 15.0;

      var packs = _createPacks([3, 2, 1], [30, 20, 10]);
      var result = TakeMedicineDistributor().getDistribution(packs, takeAmount);

      expect(result.length, 2);
      expect(result[packs[2]], 10);
      expect(result[packs[1]], 5);
  });
}
