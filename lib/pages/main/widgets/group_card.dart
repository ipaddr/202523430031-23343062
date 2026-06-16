import 'package:betomic/models/group.dart';
import 'package:betomic/theme.dart';
import 'package:flutter/material.dart';

/// Kartu ringkasan satu kelompok di halaman daftar kelompok.
class GroupCard extends StatelessWidget {
  final Group group;
  final String currentUid;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const GroupCard({
    super.key,
    required this.group,
    required this.currentUid,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isAdmin = group.isAdmin(currentUid);
    final memberCount = group.members.length;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: cardShadow,
        ),
        child: Column(
          children: [
            // ── Header bar ──
            Container(
              height: 6,
              decoration: BoxDecoration(
                gradient: mainGradient,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar inisial kelompok
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          group.nama.isNotEmpty
                              ? group.nama[0].toUpperCase()
                              : 'G',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: primaryColor,
                            fontFamily: 'Raleway',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Nama & deskripsi
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    group.nama,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Raleway',
                                      color: textPrimaryColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isAdmin) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          primaryColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'Admin',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: primaryColor,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'Raleway',
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (group.deskripsi.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                group.deskripsi,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: textSecondaryColor,
                                  fontFamily: 'Raleway',
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Menu button
                      if (isAdmin)
                        PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_vert,
                            color: textSecondaryColor,
                            size: 20,
                          ),
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          onSelected: (v) {
                            if (v == 'edit') onEdit();
                            if (v == 'delete') onDelete();
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 18, color: primaryColor),
                                  SizedBox(width: 10),
                                  Text('Edit Kelompok'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 18, color: errorColor),
                                  SizedBox(width: 10),
                                  Text(
                                    'Hapus Kelompok',
                                    style: TextStyle(color: errorColor),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 12),

                  // Footer: jumlah anggota + avatar stack
                  Row(
                    children: [
                      const Icon(Icons.group, size: 16, color: textSecondaryColor),
                      const SizedBox(width: 6),
                      Text(
                        '$memberCount anggota',
                        style: const TextStyle(
                          fontSize: 13,
                          color: textSecondaryColor,
                          fontFamily: 'Raleway',
                        ),
                      ),
                      const Spacer(),
                      // Avatar stack (maks 4)
                      _buildAvatarStack(group.members),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarStack(List<GroupMember> members) {
    const maxShow = 4;
    final shown = members.take(maxShow).toList();
    final extra = members.length - maxShow;

    return SizedBox(
      height: 28,
      width: shown.length * 22.0 + (extra > 0 ? 28 : 0),
      child: Stack(
        children: [
          ...shown.asMap().entries.map((entry) {
            final i = entry.key;
            final m = entry.value;
            return Positioned(
              left: i * 22.0,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _avatarColor(i),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  m.nama.isNotEmpty ? m.nama[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          }),
          if (extra > 0)
            Positioned(
              left: shown.length * 22.0,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  '+$extra',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _avatarColor(int index) {
    const colors = [
      primaryColor,
      secondaryColor,
      successColor,
      warningColor,
    ];
    return colors[index % colors.length];
  }
}
