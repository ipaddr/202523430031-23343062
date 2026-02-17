import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Firebase Service untuk menangani semua operasi Firebase
class FirebaseService {
  // Singleton pattern
  static final FirebaseService _instance = FirebaseService._internal();

  factory FirebaseService() {
    return _instance;
  }

  FirebaseService._internal();

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Getters
  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;
  FirebaseStorage get storage => _storage;
  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;

  // ============ AUTHENTICATION METHODS ============

  /// Sign up dengan email dan password
  Future<UserCredential?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Login dengan email dan password
  Future<UserCredential?> login({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  /// Reset password
  Future<void> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      await _auth.currentUser?.updateProfile(
        displayName: displayName,
        photoURL: photoUrl,
      );
    } catch (e) {
      rethrow;
    }
  }

  // ============ FIRESTORE METHODS ============

  /// Tambah dokumen
  Future<String> addDocument({
    required String collection,
    required Map<String, dynamic> data,
  }) async {
    try {
      final docRef = await _firestore.collection(collection).add(data);
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  /// Set dokumen (create atau update)
  Future<void> setDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
    bool merge = false,
  }) async {
    try {
      await _firestore.collection(collection).doc(docId).set(
            data,
            SetOptions(merge: merge),
          );
    } catch (e) {
      rethrow;
    }
  }

  /// Update dokumen
  Future<void> updateDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection(collection).doc(docId).update(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Hapus dokumen
  Future<void> deleteDocument({
    required String collection,
    required String docId,
  }) async {
    try {
      await _firestore.collection(collection).doc(docId).delete();
    } catch (e) {
      rethrow;
    }
  }

  /// Ambil satu dokumen
  Future<DocumentSnapshot> getDocument({
    required String collection,
    required String docId,
  }) async {
    try {
      return await _firestore.collection(collection).doc(docId).get();
    } catch (e) {
      rethrow;
    }
  }

  /// Ambil semua dokumen dari collection
  Future<QuerySnapshot> getCollection({
    required String collection,
  }) async {
    try {
      return await _firestore.collection(collection).get();
    } catch (e) {
      rethrow;
    }
  }

  /// Query dengan kondisi
  Future<QuerySnapshot> query({
    required String collection,
    required String field,
    required String operator, // '==', '<', '<=', '>', '>=', 'array-contains'
    required dynamic value,
  }) async {
    try {
      Query query = _firestore.collection(collection);

      if (operator == '==') {
        query = query.where(field, isEqualTo: value);
      } else if (operator == '<') {
        query = query.where(field, isLessThan: value);
      } else if (operator == '<=') {
        query = query.where(field, isLessThanOrEqualTo: value);
      } else if (operator == '>') {
        query = query.where(field, isGreaterThan: value);
      } else if (operator == '>=') {
        query = query.where(field, isGreaterThanOrEqualTo: value);
      } else if (operator == 'array-contains') {
        query = query.where(field, arrayContains: value);
      }

      return await query.get();
    } catch (e) {
      rethrow;
    }
  }

  /// Real-time stream dari collection
  Stream<QuerySnapshot> streamCollection({
    required String collection,
  }) {
    return _firestore.collection(collection).snapshots();
  }

  /// Real-time stream dari satu dokumen
  Stream<DocumentSnapshot> streamDocument({
    required String collection,
    required String docId,
  }) {
    return _firestore.collection(collection).doc(docId).snapshots();
  }

  // ============ STORAGE METHODS ============

  /// Upload file
  Future<String> uploadFile({
    required String path,
    required String filePath,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.putFile(
        File(filePath),
      );
      return await ref.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }

  /// Download URL
  Future<String> getDownloadUrl({required String path}) async {
    try {
      return await _storage.ref().child(path).getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }

  /// Delete file
  Future<void> deleteFile({required String path}) async {
    try {
      await _storage.ref().child(path).delete();
    } catch (e) {
      rethrow;
    }
  }

  // ============ BATCH OPERATIONS ============

  /// Batch write operations
  Future<void> batchWrite(void Function(WriteBatch) updateFn) async {
    try {
      final batch = _firestore.batch();
      updateFn(batch);
      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  // ============ TRANSACTION ============

  /// Transaction untuk operasi multi-dokumen
  Future<T> transaction<T>(
    Future<T> Function(Transaction) updateFn,
  ) async {
    try {
      return await _firestore.runTransaction(updateFn);
    } catch (e) {
      rethrow;
    }
  }
}
