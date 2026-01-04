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
      final doc = await _firestore.collection('ielts_reading').doc(testId).get();
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
      final doc = await _firestore.collection('ielts_speaking').doc(testId).get();
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
      final doc = await _firestore.collection('ielts_writing').doc(testId).get();
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
      final doc = await _firestore.collection('ielts_listening').doc(testId).get();
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
          .set({
        ...results,
        'completedAt': FieldValue.serverTimestamp(),
      });
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
      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      print('Error fetching user test results: $e');
      return [];
    }
  }
}
