import 'package:flutter/material.dart';
import 'package:medicine_chest/ui/medicine_list/medicine_with_packs.dart';

class MedicinePacksTitleWidget extends StatelessWidget {

  final MedicineWithPacks _medicineWithPacks;
  final VoidCallback? onEditClicked;

  const MedicinePacksTitleWidget(this._medicineWithPacks, {this.onEditClicked, super.key});

  @override
  Widget build(BuildContext context) {
    var medicine = _medicineWithPacks.medicine;
    var leftAmount = _medicineWithPacks.getLeftAmount().toStringAsFixed(2);
    var colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          medicine.name,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: colorScheme.primary),
        ),
        InkWell(child: Icon(Icons.edit), onTap: () {
            onEditClicked?.call();
        },),
        Text(
          'Остаток: $leftAmount',
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

}