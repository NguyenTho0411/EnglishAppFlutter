import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../../app/constants/app_const.dart';
import '../../../../../core/errors/exception.dart';

abstract class CartRemoteDataSource {
  Future<void> createCart(String uid, Map<String, dynamic> map);
  Future<Map<String, dynamic>> getCart(String uid);
  Future<void> clearCart(String uid);
  Future<void> updateCart(String uid, Map<String, dynamic> map);
  Future<void> deleteCart(String uid);
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final FirebaseFirestore firestore;
  final String _carts = "carts";

  CartRemoteDataSourceImpl(this.firestore);

  @override
  Future<void> createCart(String uid, Map<String, dynamic> map) async {
    try {
      await firestore.collection(_carts).doc(uid).set(
            map,
            SetOptions(merge: true),
          );
    } on FirebaseException {
      rethrow;
    } on UnimplementedError catch (e) {
      throw DatabaseException(e.message ?? '');
    }
  }

  @override
  Future<Map<String, dynamic>> getCart(String uid) async {
    try {
      final result = await firestore.collection(_carts).doc(uid).get();
      if (result.exists) {
        return result.data()!;
      } else {
        // Auto-create cart document if not exists
        print('🔵 Cart document not found for $uid, creating...');
        final emptyCart = {'id': uid, 'bags': []};
        await firestore.collection(_carts).doc(uid).set(emptyCart);
        return emptyCart;
      }
    } on FirebaseException catch (e) {
      print('🔴 FirebaseException in getCart: ${e.code} - ${e.message}');
      rethrow;
    } on UnimplementedError catch (e) {
      print('🔴 UnimplementedError in getCart: ${e.message}');
      throw DatabaseException(e.message ?? '');
    }
  }

  @override
  Future<void> clearCart(String uid) async {
    try {
      await firestore.collection(_carts).doc(uid).update({'bags': []});
    } on FirebaseException {
      rethrow;
    } on UnimplementedError catch (e) {
      throw DatabaseException(e.message ?? '');
    }
  }

  @override
  Future<void> updateCart(String uid, Map<String, dynamic> map) async {
    try {
      await firestore.collection(_carts).doc(uid).update(map);
    } on FirebaseException {
      rethrow;
    } on UnimplementedError catch (e) {
      throw DatabaseException(e.message ?? '');
    }
  }

  @override
  Future<void> deleteCart(String uid) async {
    try {
      await firestore.collection(_carts).doc(uid).delete();
    } on FirebaseException {
      rethrow;
    } on UnimplementedError catch (e) {
      throw DatabaseException(e.message ?? '');
    }
  }
}
