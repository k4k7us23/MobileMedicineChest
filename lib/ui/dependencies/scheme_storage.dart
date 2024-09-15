import 'package:medicine_chest/entities/scheme.dart';

abstract class SchemeStorage {
  Future<int> saveScheme(Scheme scheme);

  Future<Scheme?> getById(int id);

  Future<List<Scheme>> getActiveOrFutureSchemes();

  Future<List<Scheme>> getSchemesForDay(DateTime day);

  Future<void> deleteScheme(Scheme scheme);
}