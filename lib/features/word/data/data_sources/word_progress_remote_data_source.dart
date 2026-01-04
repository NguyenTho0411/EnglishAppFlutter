import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/word_progress_model.dart';

abstract class WordProgressRemoteDataSource {
  Future<void> saveProgress({
    required String uid,
    required WordProgressModel progress,
  });

  Future<WordProgressModel?> getProgress({
    required String uid,
    required String wordId,
  });

  Future<List<WordProgressModel>> getAllProgress(String uid);

  Stream<List<WordProgressModel>> watchAllProgress(String uid);

  Future<void> deleteProgress({
    required String uid,
    required String wordId,
  });

  Future<void> deleteAllProgress(String uid);
}

class WordProgressRemoteDataSourceImpl implements WordProgressRemoteDataSource {
  final FirebaseFirestore firestore;
  final String _collection = 'word_progress';

  WordProgressRemoteDataSourceImpl(this.firestore);

  @override
  Future<void> saveProgress({
    required String uid,
    required WordProgressModel progress,
  }) async {
    await firestore
        .collection(_collection)
        .doc(uid)
        .collection('words')
        .doc(progress.wordId)
        .set(progress.toFirestore(), SetOptions(merge: true));
  }

  @override
  Future<WordProgressModel?> getProgress({
    required String uid,
    required String wordId,
  }) async {
    final doc = await firestore
        .collection(_collection)
        .doc(uid)
        .collection('words')
        .doc(wordId)
        .get();

    if (!doc.exists || doc.data() == null) return null;

    return WordProgressModel.fromFirestore(doc.data()!);
  }

  @override
  Future<List<WordProgressModel>> getAllProgress(String uid) async {
    final snapshot = await firestore
        .collection(_collection)
        .doc(uid)
        .collection('words')
        .get();

    return snapshot.docs
        .map((doc) => WordProgressModel.fromFirestore(doc.data()))
        .toList();
  }

  @override
  Stream<List<WordProgressModel>> watchAllProgress(String uid) {
    return firestore
        .collection(_collection)
        .doc(uid)
        .collection('words')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WordProgressModel.fromFirestore(doc.data()))
            .toList());
  }

  @override
  Future<void> deleteProgress({
    required String uid,
    required String wordId,
  }) async {
    await firestore
        .collection(_collection)
        .doc(uid)
        .collection('words')
        .doc(wordId)
        .delete();
  }

  @override
  Future<void> deleteAllProgress(String uid) async {
    final batch = firestore.batch();
    final snapshot = await firestore
        .collection(_collection)
        .doc(uid)
        .collection('words')
        .get();

    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
