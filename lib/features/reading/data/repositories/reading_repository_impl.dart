import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/entities/passage.dart';
import '../../domain/repositories/reading_repository.dart';

class ReadingRepositoryImpl implements ReadingRepository {
  @override
  Future<List<Passage>> getReadingPassages() async {
    final String jsonString = await rootBundle.loadString('sample_data/reading_passages.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    final List<dynamic> passagesJson = jsonData['reading_passages'];
    return passagesJson.map((json) => Passage.fromJson(json)).toList();
  }

  @override
  Future<Passage> getPassageById(String id) async {
    final passages = await getReadingPassages();
    return passages.firstWhere((passage) => passage.id == id);
  }
}