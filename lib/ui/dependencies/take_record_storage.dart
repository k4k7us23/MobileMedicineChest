import 'package:medicine_chest/entities/take_record.dart';

abstract class TakeRecordStorage {

  Future<int> saveTakeRecord(TakeRecord record);

  Future<List<TakeRecord>> getTakeRecordForDay(DateTime day);

  Future<void> deleteTakeRecord(TakeRecord record);
}