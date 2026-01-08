import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreExamService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all reading tests
  Future<List<Map<String, dynamic>>> getReadingTests() async {
    try {
      final snapshot = await _firestore
          .collection('ielts_reading')
          .orderBy('testNumber')
          .get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching reading tests: $e');
      return [];
    }
  }

  // Get single reading test by ID
  Future<Map<String, dynamic>?> getReadingTest(String testId) async {
    try {
      final doc = await _firestore
          .collection('ielts_reading')
          .doc(testId)
          .get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      print('Error fetching reading test: $e');
      return null;
    }
  }

  // Get all speaking tests
  Future<List<Map<String, dynamic>>> getSpeakingTests() async {
    try {
      final snapshot = await _firestore
          .collection('ielts_speaking')
          .orderBy('testNumber')
          .get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching speaking tests: $e');
      return [];
    }
  }

  // Get single speaking test by ID
  Future<Map<String, dynamic>?> getSpeakingTest(String testId) async {
    try {
      final doc = await _firestore
          .collection('ielts_speaking')
          .doc(testId)
          .get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      print('Error fetching speaking test: $e');
      return null;
    }
  }

  // Get all writing tests
  Future<List<Map<String, dynamic>>> getWritingTests() async {
    try {
      final snapshot = await _firestore
          .collection('ielts_writing')
          .orderBy('testNumber')
          .get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching writing tests: $e');
      return [];
    }
  }

  // Get single writing test by ID
  Future<Map<String, dynamic>?> getWritingTest(String testId) async {
    try {
      final doc = await _firestore
          .collection('ielts_writing')
          .doc(testId)
          .get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      print('Error fetching writing test: $e');
      return null;
    }
  }

  // Get all listening tests
  Future<List<Map<String, dynamic>>> getListeningTests() async {
    try {
      final snapshot = await _firestore
          .collection('ielts_listening')
          .orderBy('testNumber')
          .get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching listening tests: $e');
      return [];
    }
  }

  // Get single listening test by ID
  Future<Map<String, dynamic>?> getListeningTest(String testId) async {
    try {
      final doc = await _firestore
          .collection('ielts_listening')
          .doc(testId)
          .get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      print('Error fetching listening test: $e');
      return null;
    }
  }

  // Save test result
  Future<void> saveTestResult({
    required String userId,
    required String testId,
    required Map<String, dynamic> results,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('test_results')
          .doc(testId)
          .set({...results, 'completedAt': FieldValue.serverTimestamp()});
    } catch (e) {
      print('Error saving test result: $e');
      rethrow;
    }
  }

  // Get user test results
  Future<List<Map<String, dynamic>>> getUserTestResults(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('test_results')
          .orderBy('completedAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      print('Error fetching user test results: $e');
      return [];
    }
  }

  // Save practice result (for individual skill practice)
  Future<void> savePracticeResult({
    required String userId,
    required String skillType, // 'reading', 'listening', 'writing', 'speaking'
    required String testId,
    required Map<String, dynamic> results,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('practice_history')
          .add({
            'skillType': skillType,
            'testId': testId,
            'testTitle': results['testTitle'] ?? '',
            'score': results['score'] ?? 0,
            'totalQuestions': results['totalQuestions'] ?? 0,
            'bandScore': results['bandScore'] ?? 0.0,
            'timeSpent': results['timeSpent'] ?? 0,
            'details': results['details'] ?? {},
            'completedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      print('Error saving practice result: $e');
      rethrow;
    }
  }

  // Get user practice history
  Future<List<Map<String, dynamic>>> getUserPracticeHistory({
    required String userId,
    String? skillType, // Filter by skill if provided
    int? limit,
  }) async {
    try {
      var query = _firestore
          .collection('users')
          .doc(userId)
          .collection('practice_history')
          .orderBy('completedAt', descending: true);

      if (skillType != null) {
        query =
            query.where('skillType', isEqualTo: skillType)
                as Query<Map<String, dynamic>>;
      }

      if (limit != null) {
        query = query.limit(limit) as Query<Map<String, dynamic>>;
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      print('Error fetching practice history: $e');
      return [];
    }
  }

  // Get practice statistics
  Future<Map<String, dynamic>> getPracticeStatistics(String userId) async {
    try {
      final history = await getUserPracticeHistory(userId: userId);

      final readingCount = history
          .where((h) => h['skillType'] == 'reading')
          .length;
      final listeningCount = history
          .where((h) => h['skillType'] == 'listening')
          .length;
      final writingCount = history
          .where((h) => h['skillType'] == 'writing')
          .length;
      final speakingCount = history
          .where((h) => h['skillType'] == 'speaking')
          .length;

      final avgReadingBand = _calculateAverageBand(history, 'reading');
      final avgListeningBand = _calculateAverageBand(history, 'listening');
      final avgWritingBand = _calculateAverageBand(history, 'writing');
      final avgSpeakingBand = _calculateAverageBand(history, 'speaking');

      return {
        'totalPractices': history.length,
        'readingCount': readingCount,
        'listeningCount': listeningCount,
        'writingCount': writingCount,
        'speakingCount': speakingCount,
        'avgReadingBand': avgReadingBand,
        'avgListeningBand': avgListeningBand,
        'avgWritingBand': avgWritingBand,
        'avgSpeakingBand': avgSpeakingBand,
      };
    } catch (e) {
      print('Error calculating statistics: $e');
      return {};
    }
  }

  double _calculateAverageBand(
    List<Map<String, dynamic>> history,
    String skillType,
  ) {
    final filtered = history.where((h) => h['skillType'] == skillType).toList();
    if (filtered.isEmpty) return 0.0;

    final sum = filtered.fold<double>(
      0.0,
      (sum, h) => sum + (h['bandScore'] ?? 0.0),
    );
    return sum / filtered.length;
  }
}
