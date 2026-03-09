import '../models/note_model.dart';
import 'auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service untuk manage sharing notes dengan user lain
class NoteSharingService {
  static final NoteSharingService _instance = NoteSharingService._internal();

  factory NoteSharingService() {
    return _instance;
  }

  NoteSharingService._internal();

  final _authService = AuthService();
  static const String _sharesCollection = 'note_shares';
  static const String _usersCollection = 'users';

  /// Get current user ID
  String? _getCurrentUserId() {
    return _authService.uid;
  }

  /// Verify if user is authenticated
  bool _isUserAuthenticated() {
    return _authService.isAuthenticated;
  }

  // ==================== SHARE ====================

  /// Share note dengan user lain
  Future<bool> shareNoteWithUser({
    required String noteId,
    required String recipientEmail,
    String permission = 'view', // 'view' atau 'edit'
  }) async {
    try {
      // Verify authentication
      if (!_isUserAuthenticated()) {
        print('User not authenticated');
        return false;
      }

      final currentUserId = _getCurrentUserId();
      if (currentUserId == null) {
        print('Current user ID not found');
        return false;
      }

      // Find user by email
      final userQuery = await FirebaseFirestore.instance
          .collection(_usersCollection)
          .where('email', isEqualTo: recipientEmail)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        print('User with email $recipientEmail not found');
        return false;
      }

      final recipientId = userQuery.docs.first.id;

      // Create share record
      final shareData = {
        'noteId': noteId,
        'sharedBy': currentUserId,
        'sharedWith': recipientId,
        'permission': permission,
        'sharedAt': FieldValue.serverTimestamp(),
        'status': 'active',
      };

      final shareId = '${noteId}_${recipientId}';

      await FirebaseFirestore.instance
          .collection(_sharesCollection)
          .doc(shareId)
          .set(shareData);

      print('Note shared with $recipientEmail: $permission');
      return true;
    } catch (e) {
      print('Error sharing note: $e');
      return false;
    }
  }

  // ==================== UNSHARE ====================

  /// Batalkan sharing note dengan user tertentu
  Future<bool> unshareNoteWithUser({
    required String noteId,
    required String recipientId,
  }) async {
    try {
      // Verify authentication
      if (!_isUserAuthenticated()) {
        print('User not authenticated');
        return false;
      }

      final currentUserId = _getCurrentUserId();
      if (currentUserId == null) {
        print('Current user ID not found');
        return false;
      }

      final shareId = '${noteId}_${recipientId}';

      // Verify ownership
      final shareDoc = await FirebaseFirestore.instance
          .collection(_sharesCollection)
          .doc(shareId)
          .get();

      if (!shareDoc.exists) {
        print('Share record not found');
        return false;
      }

      final data = shareDoc.data() as Map<String, dynamic>;
      if (data['sharedBy'] != currentUserId) {
        print('Unauthorized: Only note owner can revoke sharing');
        return false;
      }

      // Remove share
      await FirebaseFirestore.instance
          .collection(_sharesCollection)
          .doc(shareId)
          .delete();

      print('Note sharing removed: $recipientId');
      return true;
    } catch (e) {
      print('Error removing share: $e');
      return false;
    }
  }

  // ==================== READ ====================

  /// Get list user yang note ini sudah di-share
  Future<List<Map<String, dynamic>>> getSharedWithUsers(String noteId) async {
    try {
      // Verify authentication
      if (!_isUserAuthenticated()) {
        print('User not authenticated');
        return [];
      }

      final currentUserId = _getCurrentUserId();
      if (currentUserId == null) {
        print('Current user ID not found');
        return [];
      }

      final sharesSnapshot = await FirebaseFirestore.instance
          .collection(_sharesCollection)
          .where('noteId', isEqualTo: noteId)
          .where('sharedBy', isEqualTo: currentUserId)
          .where('status', isEqualTo: 'active')
          .get();

      List<Map<String, dynamic>> sharedUsers = [];

      for (var doc in sharesSnapshot.docs) {
        final data = doc.data();
        final recipientId = data['sharedWith'];

        // Get recipient user info
        final userDoc = await FirebaseFirestore.instance
            .collection(_usersCollection)
            .doc(recipientId)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          sharedUsers.add({
            'id': recipientId,
            'email': userData['email'] ?? 'Unknown',
            'name': userData['name'] ?? 'Unknown',
            'permission': data['permission'] ?? 'view',
            'sharedAt': (data['sharedAt'] as Timestamp?)?.toDate(),
          });
        }
      }

      return sharedUsers;
    } catch (e) {
      print('Error getting shared users: $e');
      return [];
    }
  }

  /// Get notes yang di-share ke current user
  Future<List<Map<String, dynamic>>> getSharedNotesForMe() async {
    try {
      // Verify authentication
      if (!_isUserAuthenticated()) {
        print('User not authenticated');
        return [];
      }

      final currentUserId = _getCurrentUserId();
      if (currentUserId == null) {
        print('Current user ID not found');
        return [];
      }

      final sharesSnapshot = await FirebaseFirestore.instance
          .collection(_sharesCollection)
          .where('sharedWith', isEqualTo: currentUserId)
          .where('status', isEqualTo: 'active')
          .get();

      List<Map<String, dynamic>> sharedNotes = [];

      for (var doc in sharesSnapshot.docs) {
        final data = doc.data();
        sharedNotes.add({
          'noteId': data['noteId'],
          'sharedBy': data['sharedBy'],
          'permission': data['permission'] ?? 'view',
          'sharedAt': (data['sharedAt'] as Timestamp?)?.toDate(),
        });
      }

      return sharedNotes;
    } catch (e) {
      print('Error getting shared notes: $e');
      return [];
    }
  }

  // ==================== UPDATE PERMISSION ====================

  /// Update permission sharing (view → edit atau sebaliknya)
  Future<bool> updateSharePermission({
    required String noteId,
    required String recipientId,
    required String newPermission,
  }) async {
    try {
      // Verify authentication
      if (!_isUserAuthenticated()) {
        print('User not authenticated');
        return false;
      }

      final currentUserId = _getCurrentUserId();
      if (currentUserId == null) {
        print('Current user ID not found');
        return false;
      }

      final shareId = '${noteId}_${recipientId}';

      // Verify ownership
      final shareDoc = await FirebaseFirestore.instance
          .collection(_sharesCollection)
          .doc(shareId)
          .get();

      if (!shareDoc.exists) {
        print('Share record not found');
        return false;
      }

      final data = shareDoc.data() as Map<String, dynamic>;
      if (data['sharedBy'] != currentUserId) {
        print('Unauthorized: Only note owner can update permissions');
        return false;
      }

      // Update permission
      await FirebaseFirestore.instance
          .collection(_sharesCollection)
          .doc(shareId)
          .update({
            'permission': newPermission,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      print('Share permission updated: $newPermission');
      return true;
    } catch (e) {
      print('Error updating permission: $e');
      return false;
    }
  }

  /// Check permission untuk note tertentu
  Future<String?> checkNotePermission(String noteId) async {
    try {
      // Verify authentication
      if (!_isUserAuthenticated()) {
        print('User not authenticated');
        return null;
      }

      final currentUserId = _getCurrentUserId();
      if (currentUserId == null) {
        print('Current user ID not found');
        return null;
      }

      // Check if current user is owner
      // This would need to be checked in the note document itself
      // For now, return null if not shared with user

      final sharesSnapshot = await FirebaseFirestore.instance
          .collection(_sharesCollection)
          .where('noteId', isEqualTo: noteId)
          .where('sharedWith', isEqualTo: currentUserId)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();

      if (sharesSnapshot.docs.isEmpty) {
        return null;
      }

      final data = sharesSnapshot.docs.first.data() as Map<String, dynamic>;
      return data['permission'] as String?;
    } catch (e) {
      print('Error checking permission: $e');
      return null;
    }
  }
}
