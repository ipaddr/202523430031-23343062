import 'package:betomic/models/invitation.dart';
import 'package:betomic/service/auth.dart';
import 'package:betomic/service/group_database.dart';
import 'package:betomic/theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

/// Halaman notifikasi undangan kelompok.
class GroupInvitationsPage extends StatefulWidget {
  const GroupInvitationsPage({super.key});

  @override
  State<GroupInvitationsPage> createState() => _GroupInvitationsPageState();
}

class _GroupInvitationsPageState extends State<GroupInvitationsPage> {
  final _db = GroupDatabase();
  late final String _uid;

  @override
  void initState() {
    super.initState();
    _uid = authService.value.currentUser!.uid;
  }

  Future<void> _accept(Invitation inv) async {
    try {
      await _db.terimaUndangan(invitation: inv);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Berhasil bergabung dengan "${inv.groupNama}"'),
            backgroundColor: successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menerima undangan: $e'),
            backgroundColor: errorColor,
          ),
        );
      }
    }
  }

  Future<void> _decline(Invitation inv) async {
    try {
      await _db.tolakUndangan(invitationId: inv.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Undangan ditolak')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menolak undangan: $e'),
            backgroundColor: errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Undangan Kelompok',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontFamily: 'Raleway',
          ),
        ),
      ),
      body: StreamBuilder<List<Invitation>>(
        stream: _db.streamUndanganMasuk(uid: _uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: errorColor),
              ),
            );
          }

          final invitations = snapshot.data ?? [];

          if (invitations.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: invitations.length,
            itemBuilder: (ctx, i) => _buildInvitationCard(invitations[i]),
          );
        },
      ),
    );
  }

  Widget _buildInvitationCard(Invitation inv) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: const [elevationShadow2],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.group_add,
                    color: primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        inv.groupNama,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Raleway',
                          color: textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Diundang oleh ${inv.inviterNama}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: textSecondaryColor,
                          fontFamily: 'Raleway',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Timestamp
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: textSecondaryColor),
                const SizedBox(width: 4),
                Text(
                  DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(inv.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: textSecondaryColor,
                    fontFamily: 'Raleway',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _decline(inv),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Tolak'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: errorColor,
                      side: const BorderSide(color: errorColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _accept(inv),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Terima'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: FaIcon(
                FontAwesomeIcons.envelopeOpenText,
                size: 52,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Tidak ada undangan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textPrimaryColor,
                fontFamily: 'Raleway',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Undangan untuk bergabung kelompok\nakan muncul di sini',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: textSecondaryColor,
                fontFamily: 'Raleway',
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
