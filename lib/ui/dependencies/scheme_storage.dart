import 'package:medicine_chest/entities/scheme.dart';

abstract class SchemeStorage {
  Future<int> saveScheme(Scheme scheme);

  Future<List<Scheme>> getActiveOrFutureSchemes();
}