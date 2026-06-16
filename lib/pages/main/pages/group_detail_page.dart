import 'package:betomic/models/group.dart';
import 'package:betomic/pages/main/pages/group_tasks_collab_page.dart';
import 'package:betomic/service/group_database.dart';
import 'package:betomic/theme.dart';
import 'package:flutter/material.dart';

/// Halaman detail kelompok: info kelompok, manajemen anggota,
/// dan tombol masuk ke halaman tugas.
class GroupDetailPage extends StatefulWidget {
  final String groupId;
  final String currentUid;
  final String currentNama;
  final String currentEmail;

  const GroupDetailPage({
    super.key,
    required this.groupId,
    required this.currentUid,
    required this.currentNama,
    required this.currentEmail,
  });

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  final _db = GroupDatabase();
  final _emailCtrl = TextEditingController();
  bool _isAddingMember = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  // ── Dialog kirim undangan via email ──
  void _showAddMemberDialog(Group group) {
    _emailCtrl.clear();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.person_add, color: primaryColor),
              SizedBox(width: 10),
              Text(
                'Undang Anggota',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Raleway',
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Masukkan email pengguna:',
                style: TextStyle(
                  fontSize: 13,
                  color: textSecondaryColor,
                  fontFamily: 'Raleway',
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Mereka akan menerima undangan dan harus menerimanya terlebih dahulu.',
                style: TextStyle(
                  fontSize: 12,
                  color: textSecondaryColor,
                  fontFamily: 'Raleway',
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'contoh@email.com',
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                  filled: true,
                  fillColor: backgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: primaryColor, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Batal',
                style: TextStyle(color: textSecondaryColor),
              ),
            ),
            ElevatedButton(
              onPressed: _isAddingMember
                  ? null
                  : () async {
                      final email = _emailCtrl.text.trim();
                      if (email.isEmpty) return;

                      setDialogState(() => _isAddingMember = true);
                      final error = await _db.kirimUndangan(
                        groupId: group.id,
                        groupNama: group.nama,
                        inviterUid: widget.currentUid,
                        inviterNama: widget.currentNama,
                        email: email,
                      );
                      setDialogState(() => _isAddingMember = false);

                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              error ?? 'Undangan berhasil dikirim',
                            ),
                            backgroundColor:
                                error != null ? errorColor : successColor,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isAddingMember
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Kirim'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Konfirmasi hapus anggota ──
  void _confirmRemoveMember(Group group, GroupMember member) {
    final isSelf = member.uid == widget.currentUid;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isSelf ? 'Keluar Kelompok' : 'Hapus Anggota',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontFamily: 'Raleway',
          ),
        ),
        content: Text(
          isSelf
              ? 'Kamu akan keluar dari kelompok "${group.nama}". Lanjutkan?'
              : 'Hapus ${member.nama} dari kelompok ini?',
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
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(context);
              if (isSelf) {
                await _db.keluarKelompok(
                  groupId: group.id,
                  member: member,
                );
                if (mounted) Navigator.pop(context); // kembali ke daftar
              } else {
                await _db.hapusAnggota(
                  groupId: group.id,
                  member: member,
                );
              }
            },
            child: Text(isSelf ? 'Keluar' : 'Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Group?>(
      stream: _db.streamKelompok(groupId: widget.groupId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: primaryColor),
            ),
          );
        }

        final group = snapshot.data;
        if (group == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Kelompok')),
            body: const Center(child: Text('Kelompok tidak ditemukan.')),
          );
        }

        final isAdmin = group.isAdmin(widget.currentUid);

        return Scaffold(
          backgroundColor: backgroundColor,
          body: CustomScrollView(
            slivers: [
              // ── Header ──
              SliverAppBar(
                pinned: true,
                expandedHeight: 160,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
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
                            const SizedBox(height: 40),
                            Text(
                              group.nama,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                fontFamily: 'Raleway',
                              ),
                            ),
                            if (group.deskripsi.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                group.deskripsi,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white70,
                                  fontFamily: 'Raleway',
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                backgroundColor: primaryColor,
              ),

              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Dua Card Tugas ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
                      child: Column(
                        children: [
                          // Card Tugas Seri
                          _buildTaskEntryCard(
                            context: context,
                            group: group,
                            label: 'Daftar Tugas Seri',
                            desc: 'Dikerjakan berurutan — tugas berikutnya\nterbuka setelah tugas sebelumnya selesai',
                            icon: Icons.linear_scale,
                            color: secondaryColor,
                            initialTab: 0,
                          ),
                          const SizedBox(height: 12),
                          // Card Tugas Paralel
                          _buildTaskEntryCard(
                            context: context,
                            group: group,
                            label: 'Daftar Tugas Paralel',
                            desc: 'Semua tugas bisa dikerjakan\nsecara bebas dan mandiri',
                            icon: Icons.compare_arrows,
                            color: primaryColor,
                            initialTab: 1,
                          ),
                        ],
                      ),
                    ),

                    // ── Section Anggota ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Anggota (${group.members.length})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: textPrimaryColor,
                              fontFamily: 'Raleway',
                            ),
                          ),
                          if (isAdmin)
                            TextButton.icon(
                              onPressed: () => _showAddMemberDialog(group),
                              icon: const Icon(
                                Icons.person_add,
                                size: 16,
                                color: primaryColor,
                              ),
                              label: const Text(
                                'Tambah',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Raleway',
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // ── List Anggota ──
                    ...group.members.map(
                      (member) => _buildMemberTile(
                        member: member,
                        isAdmin: isAdmin,
                        group: group,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Tombol keluar kelompok (untuk non-admin) ──
                    if (!isAdmin)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: OutlinedButton.icon(
                          onPressed: () {
                            final me = group.members.firstWhere(
                              (m) => m.uid == widget.currentUid,
                            );
                            _confirmRemoveMember(group, me);
                          },
                          icon: const Icon(Icons.exit_to_app, color: errorColor),
                          label: const Text(
                            'Keluar dari Kelompok',
                            style: TextStyle(
                              color: errorColor,
                              fontFamily: 'Raleway',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: errorColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        ),
                      ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTaskEntryCard({
    required BuildContext context,
    required Group group,
    required String label,
    required String desc,
    required IconData icon,
    required Color color,
    required int initialTab,
  }) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GroupTasksCollabPage(
            group: group,
            currentUid: widget.currentUid,
            currentNama: widget.currentNama,
            initialTabIndex: initialTab,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: color,
                      fontFamily: 'Raleway',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: const TextStyle(
                      fontSize: 11,
                      color: textSecondaryColor,
                      fontFamily: 'Raleway',
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberTile({
    required GroupMember member,
    required bool isAdmin,
    required Group group,
  }) {
    final isSelf = member.uid == widget.currentUid;
    final canRemove = isAdmin && !member.isAdmin; // admin tidak hapus admin lain

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [elevationShadow1],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: member.isAdmin
                ? primaryColor.withValues(alpha: 0.15)
                : Colors.grey.shade100,
            child: Text(
              member.nama.isNotEmpty ? member.nama[0].toUpperCase() : '?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: member.isAdmin ? primaryColor : textSecondaryColor,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      member.nama + (isSelf ? ' (Kamu)' : ''),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Raleway',
                        color: textPrimaryColor,
                      ),
                    ),
                    if (member.isAdmin) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Admin',
                          style: TextStyle(
                            fontSize: 10,
                            color: primaryColor,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Raleway',
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  member.email,
                  style: const TextStyle(
                    fontSize: 12,
                    color: textSecondaryColor,
                    fontFamily: 'Raleway',
                  ),
                ),
              ],
            ),
          ),

          // Hapus (hanya admin, hanya untuk member biasa)
          if (canRemove)
            IconButton(
              icon: const Icon(Icons.person_remove, size: 20, color: errorColor),
              onPressed: () => _confirmRemoveMember(group, member),
              tooltip: 'Hapus anggota',
            ),
        ],
      ),
    );
  }
}
