import 'package:flutter/material.dart';
import 'package:medicine_chest/entities/medicine.dart';

class MedicineReleaseFormSelectorWidget extends StatelessWidget {
  final MedicineReleaseForm selectedForm;
  final ValueSetter<MedicineReleaseForm> onReleaseFormSelected;
  final EdgeInsets? menuInsets;

  const MedicineReleaseFormSelectorWidget(this.selectedForm, this.onReleaseFormSelected, {this.menuInsets, super.key});

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<MedicineReleaseForm>(
      initialSelection: selectedForm,
      requestFocusOnTap: false,
      label: const Text('Форма выпуска'),
      enableSearch: false,
      enableFilter: false,
      expandedInsets: menuInsets,
      onSelected: (MedicineReleaseForm? form) {
        if (form != null) {
          onReleaseFormSelected(form);
        }
      },
      dropdownMenuEntries: MedicineReleaseForm.values
          .map<DropdownMenuEntry<MedicineReleaseForm>>(
              (MedicineReleaseForm releaseForm) {
        return DropdownMenuEntry<MedicineReleaseForm>(
          value: releaseForm,
          label: releaseForm.name,
        );
      }).toList(),
    );
  }
}
