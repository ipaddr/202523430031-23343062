import 'package:cloud_firestore/cloud_firestore.dart';

/// Status undangan kelompok
enum InvitationStatus { pending, accepted, declined }

extension InvitationStatusExt on InvitationStatus {
  String get value {
    switch (this) {
      case InvitationStatus.pending:
        return 'pending';
      case InvitationStatus.accepted:
        return 'accepted';
      case InvitationStatus.declined:
        return 'declined';
    }
  }

  static InvitationStatus fromString(String s) {
    switch (s) {
      case 'accepted':
        return InvitationStatus.accepted;
      case 'declined':
        return InvitationStatus.declined;
      default:
        return InvitationStatus.pending;
    }
  }
}

/// Model undangan bergabung kelompok.
///
/// Skema Firestore: invitations/{invitationId}
///   - groupId, groupNama
///   - inviterUid, inviterNama
///   - inviteeUid, inviteeEmail, inviteeNama
///   - status: 'pending' | 'accepted' | 'declined'
///   - createdAt
class Invitation {
  final String id;
  final String groupId;
  final String groupNama;
  final String inviterUid;
  final String inviterNama;
  final String inviteeUid;
  final String inviteeEmail;
  final String inviteeNama;
  final InvitationStatus status;
  final DateTime createdAt;

  Invitation({
    required this.id,
    required this.groupId,
    required this.groupNama,
    required this.inviterUid,
    required this.inviterNama,
    required this.inviteeUid,
    required this.inviteeEmail,
    required this.inviteeNama,
    required this.status,
    required this.createdAt,
  });

  factory Invitation.fromMap(Map<String, dynamic> data, String id) {
    return Invitation(
      id: id,
      groupId: data['groupId'] ?? '',
      groupNama: data['groupNama'] ?? '',
      inviterUid: data['inviterUid'] ?? '',
      inviterNama: data['inviterNama'] ?? '',
      inviteeUid: data['inviteeUid'] ?? '',
      inviteeEmail: data['inviteeEmail'] ?? '',
      inviteeNama: data['inviteeNama'] ?? '',
      status: InvitationStatusExt.fromString(data['status'] ?? 'pending'),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  bool get isPending => status == InvitationStatus.pending;
}
