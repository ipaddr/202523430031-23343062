import 'package:betomic/models/group.dart';
import 'package:betomic/models/invitation.dart';
import 'package:betomic/pages/main/pages/group_detail_page.dart';
import 'package:betomic/pages/main/pages/group_invitations_page.dart';
import 'package:betomic/pages/main/widgets/add_edit_group_dialog.dart';
import 'package:betomic/pages/main/widgets/group_card.dart';
import 'package:betomic/service/auth.dart';
import 'package:betomic/service/group_database.dart';
import 'package:betomic/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Halaman utama fitur kelompok kolaboratif.
/// Menampilkan daftar kelompok yang diikuti user + tombol buat kelompok baru.
class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  final _db = GroupDatabase();
  late final User _user;
  late final String _uid;
  late final String _nama;
  late final String _email;

  @override
  void initState() {
    super.initState();
    _user = authService.value.currentUser!;
    _uid = _user.uid;
    _nama = _user.displayName ?? 'User';
    _email = _user.email ?? '';
  }

  // ── Buat kelompok baru ──
  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (_) => AddEditGroupDialog(
        onSave: (nama, deskripsi) => _db.buatKelompok(
          creatorUid: _uid,
          creatorNama: _nama,
          creatorEmail: _email,
          nama: nama,
          deskripsi: deskripsi,
        ),
      ),
    );
  }

  // ── Edit kelompok ──
  void _showEditDialog(Group group) {
    showDialog(
      context: context,
      builder: (_) => AddEditGroupDialog(
        initialNama: group.nama,
        initialDeskripsi: group.deskripsi,
        onSave: (nama, deskripsi) => _db.updateKelompok(
          groupId: group.id,
          nama: nama,
          deskripsi: deskripsi,
        ),
      ),
    );
  }

  // ── Konfirmasi hapus kelompok ──
  void _confirmDelete(Group group) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Kelompok',
          style: TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Raleway'),
        ),
        content: Text(
          'Kelompok "${group.nama}" beserta semua tugas di dalamnya akan dihapus permanen. Lanjutkan?',
          style: const TextStyle(fontFamily: 'Raleway', fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(color: textSecondaryColor),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _db.hapusKelompok(
                groupId: group.id,
                members: group.members,
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Kelompok "${group.nama}" dihapus'),
                  ),
                );
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  // ── Navigasi ke detail kelompok ──
  void _openDetail(Group group) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GroupDetailPage(
          groupId: group.id,
          currentUid: _uid,
          currentNama: _nama,
          currentEmail: _email,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            elevation: 0,
            actions: [
              // Badge undangan masuk
              StreamBuilder<List<Invitation>>(
                stream: _db.streamUndanganMasuk(uid: _uid),
                builder: (context, snapshot) {
                  final count = snapshot.data?.length ?? 0;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          icon: const FaIcon(
                            FontAwesomeIcons.bell,
                            color: Colors.white,
                            size: 20,
                          ),
                          tooltip: 'Undangan',
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const GroupInvitationsPage(),
                            ),
                          ),
                        ),
                        if (count > 0)
                          Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                color: secondaryColor,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                count > 9 ? '9+' : '$count',
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [secondaryColor, primaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kelompok',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            fontFamily: 'Raleway',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Halo, $_nama 👋',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                            fontFamily: 'Raleway',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            backgroundColor: primaryColor,
          ),

          // ── Konten ──
          StreamBuilder<List<Group>>(
            stream: _db.getKelompokUser(uid: _uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  ),
                );
              }

              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'Terjadi kesalahan: ${snapshot.error}',
                      style: const TextStyle(color: errorColor),
                    ),
                  ),
                );
              }

              final groups = snapshot.data ?? [];

              if (groups.isEmpty) {
                return SliverFillRemaining(
                  child: _buildEmptyState(),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    if (i == 0) {
                      // Info jumlah kelompok
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                        child: Text(
                          '${groups.length} kelompok bergabung',
                          style: const TextStyle(
                            fontSize: 13,
                            color: textSecondaryColor,
                            fontFamily: 'Raleway',
                          ),
                        ),
                      );
                    }
                    final group = groups[i - 1];
                    return GroupCard(
                      group: group,
                      currentUid: _uid,
                      onTap: () => _openDetail(group),
                      onEdit: () => _showEditDialog(group),
                      onDelete: () => _confirmDelete(group),
                    );
                  },
                  childCount: groups.length + 1,
                ),
              );
            },
          ),

          // Padding bawah supaya tidak tertutup FAB
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),

      // ── FAB buat kelompok ──
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.group_add),
        label: const Text(
          'Buat Kelompok',
          style: TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Raleway'),
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
                color: primaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const FaIcon(
                FontAwesomeIcons.peopleGroup,
                size: 52,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Belum ada kelompok',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: textPrimaryColor,
                fontFamily: 'Raleway',
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Buat kelompok baru atau minta admin kelompokmu\nuntuk menambahkan kamu sebagai anggota.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: textSecondaryColor,
                fontFamily: 'Raleway',
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: _showCreateDialog,
              icon: const Icon(Icons.group_add),
              label: const Text(
                'Buat Kelompok',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Raleway',
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
