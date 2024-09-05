enum MedicineReleaseForm {
  tablet,
  injection,
  liquid,
  powder,
  other
}

extension MedicineReleaseFormName on MedicineReleaseForm {
  String get name {
    switch (this) {
      case MedicineReleaseForm.tablet:
        return "Таблетка";
      case MedicineReleaseForm.injection:
        return "Инъекция";
      case MedicineReleaseForm.liquid:
        return "Жидкость";
      case MedicineReleaseForm.powder:
        return "Порошок";
      case MedicineReleaseForm.other:
        return "Другое";
    }
  }
}


class Medicine {
  static int NO_ID = -1;

  int id;
  String name;
  MedicineReleaseForm releaseForm;
  double? dosage = null;

  Medicine({required this.id, required this.name, required this.releaseForm});
}