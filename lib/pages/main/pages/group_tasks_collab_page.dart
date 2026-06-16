import 'package:betomic/models/collab_task.dart';
import 'package:betomic/models/group.dart';
import 'package:betomic/pages/main/widgets/add_edit_collab_task_dialog.dart';
import 'package:betomic/service/group_database.dart';
import 'package:betomic/theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

/// Halaman tugas kolaboratif real-time.
/// Tab 0 = Tugas Seri (berurutan), Tab 1 = Tugas Paralel (bebas).
class GroupTasksCollabPage extends StatefulWidget {
  final Group group;
  final String currentUid;
  final String currentNama;
  final int initialTabIndex;

  const GroupTasksCollabPage({
    super.key,
    required this.group,
    required this.currentUid,
    required this.currentNama,
    this.initialTabIndex = 0,
  });

  @override
  State<GroupTasksCollabPage> createState() => _GroupTasksCollabPageState();
}

class _GroupTasksCollabPageState extends State<GroupTasksCollabPage>
    with SingleTickerProviderStateMixin {
  final _db = GroupDatabase();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool get _isAdmin => widget.group.isAdmin(widget.currentUid);

  // ── Dialog tambah tugas ──
  void _showAddDialog(String mode) async {
    int urutan = 0;
    if (mode == 'seri') {
      urutan = await _db.getNextUrutanSeri(groupId: widget.group.id);
    }
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AddEditCollabTaskDialog(
        members: widget.group.members,
        initialMode: mode,
        onSave: ({
          required namaTugas,
          required deskripsi,
          required assigneeUid,
          required assigneeNama,
          required waktuPengerjaan,
          required mode,
        }) =>
            _db.tambahTugas(
          groupId: widget.group.id,
          namaTugas: namaTugas,
          deskripsi: deskripsi,
          assigneeUid: assigneeUid,
          assigneeNama: assigneeNama,
          waktuPengerjaan: waktuPengerjaan,
          createdBy: widget.currentUid,
          mode: mode,
          urutan: urutan,
        ),
      ),
    );
  }

  // ── Dialog edit tugas ──
  void _showEditDialog(CollabTask task) {
    showDialog(
      context: context,
      builder: (_) => AddEditCollabTaskDialog(
        members: widget.group.members,
        task: task,
        onSave: ({
          required namaTugas,
          required deskripsi,
          required assigneeUid,
          required assigneeNama,
          required waktuPengerjaan,
          required mode,
        }) =>
            _db.updateTugas(
          groupId: widget.group.id,
          taskId: task.id,
          namaTugas: namaTugas,
          deskripsi: deskripsi,
          assigneeUid: assigneeUid,
          assigneeNama: assigneeNama,
          waktuPengerjaan: waktuPengerjaan,
          mode: mode,
          urutan: task.urutan,
        ),
      ),
    );
  }

  // ── Konfirmasi hapus ──
  void _confirmDelete(CollabTask task) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Tugas',
            style: TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Raleway')),
        content: Text('Hapus tugas "${task.namaTugas}"?',
            style: const TextStyle(fontFamily: 'Raleway', fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal',
                style: TextStyle(color: textSecondaryColor)),
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
              await _db.hapusTugas(
                  groupId: widget.group.id, taskId: task.id);
              if (mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Tugas dihapus')));
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.group.nama,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Raleway')),
            Text('${widget.group.members.length} anggota',
                style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          labelStyle: const TextStyle(
              fontWeight: FontWeight.w700, fontFamily: 'Raleway'),
          tabs: const [
            Tab(icon: Icon(Icons.linear_scale, size: 16), text: 'Seri'),
            Tab(icon: Icon(Icons.compare_arrows, size: 16), text: 'Paralel'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _SeriTasksView(
            db: _db,
            group: widget.group,
            currentUid: widget.currentUid,
            isAdmin: _isAdmin,
            onAdd: () => _showAddDialog('seri'),
            onEdit: _showEditDialog,
            onDelete: _confirmDelete,
          ),
          _ParalelTasksView(
            db: _db,
            group: widget.group,
            currentUid: widget.currentUid,
            isAdmin: _isAdmin,
            onAdd: () => _showAddDialog('paralel'),
            onEdit: _showEditDialog,
            onDelete: _confirmDelete,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// VIEW: TUGAS SERI
// ═══════════════════════════════════════════════════════════════════════════
class _SeriTasksView extends StatelessWidget {
  final GroupDatabase db;
  final Group group;
  final String currentUid;
  final bool isAdmin;
  final VoidCallback onAdd;
  final void Function(CollabTask) onEdit;
  final void Function(CollabTask) onDelete;

  const _SeriTasksView({
    required this.db,
    required this.group,
    required this.currentUid,
    required this.isAdmin,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CollabTask>>(
      stream: db.streamTugasSeri(groupId: group.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: primaryColor));
        }
        final tasks = snapshot.data ?? [];
        final ongoing = tasks.where((t) => !t.isCompleted).toList();
        final done = tasks.where((t) => t.isCompleted).toList();

        return Column(
          children: [
            // Info + FAB kecil
            _buildHeader(
              context,
              label: 'Tugas Seri',
              desc: 'Tugas harus diselesaikan secara berurutan',
              icon: Icons.linear_scale,
              color: secondaryColor,
              onAdd: onAdd,
            ),
            Expanded(
              child: tasks.isEmpty
                  ? _emptyState(isDone: false, isSeri: true)
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 100),
                      children: [
                        if (ongoing.isNotEmpty) ...[
                          _sectionLabel('Berlangsung'),
                          ...ongoing.asMap().entries.map((e) {
                            final index = e.key;
                            final task = e.value;
                            // Tugas terkunci jika ada tugas sebelumnya belum selesai
                            final isBlocked = index > 0 &&
                                ongoing.take(index).any((t) => !t.isCompleted);
                            final blockedBy =
                                isBlocked ? ongoing[index - 1].namaTugas : null;
                            return _TaskCard(
                              task: task,
                              currentUid: currentUid,
                              isAdmin: isAdmin,
                              isBlocked: isBlocked,
                              blockedByName: blockedBy,
                              urutanLabel: '#${task.urutan}',
                              onToggle: isBlocked
                                  ? null
                                  : (val) => db.updateStatusTugas(
                                      groupId: group.id,
                                      taskId: task.id,
                                      isCompleted: val),
                              onEdit: () => onEdit(task),
                              onDelete: () => onDelete(task),
                            );
                          }),
                        ],
                        if (done.isNotEmpty) ...[
                          _sectionLabel('Selesai'),
                          ...done.map((task) => _TaskCard(
                                task: task,
                                currentUid: currentUid,
                                isAdmin: isAdmin,
                                isBlocked: false,
                                urutanLabel: '#${task.urutan}',
                                onToggle: (val) => db.updateStatusTugas(
                                    groupId: group.id,
                                    taskId: task.id,
                                    isCompleted: val),
                                onEdit: () => onEdit(task),
                                onDelete: () => onDelete(task),
                              )),
                        ],
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// VIEW: TUGAS PARALEL
// ═══════════════════════════════════════════════════════════════════════════
class _ParalelTasksView extends StatefulWidget {
  final GroupDatabase db;
  final Group group;
  final String currentUid;
  final bool isAdmin;
  final VoidCallback onAdd;
  final void Function(CollabTask) onEdit;
  final void Function(CollabTask) onDelete;

  const _ParalelTasksView({
    required this.db,
    required this.group,
    required this.currentUid,
    required this.isAdmin,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_ParalelTasksView> createState() => _ParalelTasksViewState();
}

class _ParalelTasksViewState extends State<_ParalelTasksView> {
  String _filterAssignee = 'Semua';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CollabTask>>(
      stream: widget.db.streamTugasParalel(groupId: widget.group.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: primaryColor));
        }
        final allTasks = snapshot.data ?? [];
        final filtered = _filterAssignee == 'Semua'
            ? allTasks
            : allTasks
                .where((t) => t.assigneeUid == _filterAssignee)
                .toList();
        final ongoing = filtered.where((t) => !t.isCompleted).toList();
        final done = filtered.where((t) => t.isCompleted).toList();

        return Column(
          children: [
            _buildHeader(
              context,
              label: 'Tugas Paralel',
              desc: 'Semua tugas bisa dikerjakan secara bebas',
              icon: Icons.compare_arrows,
              color: primaryColor,
              onAdd: widget.onAdd,
              filterWidget: _buildFilter(),
            ),
            Expanded(
              child: allTasks.isEmpty
                  ? _emptyState(isDone: false, isSeri: false)
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 100),
                      children: [
                        if (ongoing.isNotEmpty) ...[
                          _sectionLabel('Berlangsung'),
                          ...ongoing.map((task) => _TaskCard(
                                task: task,
                                currentUid: widget.currentUid,
                                isAdmin: widget.isAdmin,
                                isBlocked: false,
                                onToggle: (val) =>
                                    widget.db.updateStatusTugas(
                                        groupId: widget.group.id,
                                        taskId: task.id,
                                        isCompleted: val),
                                onEdit: () => widget.onEdit(task),
                                onDelete: () => widget.onDelete(task),
                              )),
                        ],
                        if (done.isNotEmpty) ...[
                          _sectionLabel('Selesai'),
                          ...done.map((task) => _TaskCard(
                                task: task,
                                currentUid: widget.currentUid,
                                isAdmin: widget.isAdmin,
                                isBlocked: false,
                                onToggle: (val) =>
                                    widget.db.updateStatusTugas(
                                        groupId: widget.group.id,
                                        taskId: task.id,
                                        isCompleted: val),
                                onEdit: () => widget.onEdit(task),
                                onDelete: () => widget.onDelete(task),
                              )),
                        ],
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilter() {
    final items = <DropdownMenuItem<String>>[
      const DropdownMenuItem(value: 'Semua', child: Text('Semua')),
      ...widget.group.members.map((m) => DropdownMenuItem(
            value: m.uid,
            child: Text(
              m.uid == widget.currentUid ? 'Tugasku' : m.nama,
              overflow: TextOverflow.ellipsis,
            ),
          )),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _filterAssignee,
          dropdownColor: primaryColor,
          iconEnabledColor: Colors.white,
          style: const TextStyle(
              color: Colors.white, fontFamily: 'Raleway', fontSize: 13),
          onChanged: (v) =>
              setState(() => _filterAssignee = v ?? 'Semua'),
          items: items,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════════════════

Widget _buildHeader(
  BuildContext context, {
  required String label,
  required String desc,
  required IconData icon,
  required Color color,
  required VoidCallback onAdd,
  Widget? filterWidget,
}) {
  return Container(
    color: color.withValues(alpha: 0.08),
    padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
    child: Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: color,
                      fontFamily: 'Raleway')),
              Text(desc,
                  style: const TextStyle(
                      fontSize: 11,
                      color: textSecondaryColor,
                      fontFamily: 'Raleway')),
            ],
          ),
        ),
        if (filterWidget != null) ...[filterWidget, const SizedBox(width: 8)],
        ElevatedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Tambah',
              style: TextStyle(fontSize: 12, fontFamily: 'Raleway')),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    ),
  );
}

Widget _sectionLabel(String label) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
    child: Text(label,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textSecondaryColor,
            fontFamily: 'Raleway')),
  );
}

Widget _emptyState({required bool isDone, required bool isSeri}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            isDone
                ? FontAwesomeIcons.circleCheck
                : FontAwesomeIcons.clipboardList,
            size: 52,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            isDone
                ? 'Belum ada tugas selesai'
                : isSeri
                    ? 'Belum ada tugas seri'
                    : 'Belum ada tugas paralel',
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textSecondaryColor,
                fontFamily: 'Raleway'),
          ),
          if (!isDone) ...[
            const SizedBox(height: 8),
            const Text('Tap tombol "Tambah" untuk mulai',
                style: TextStyle(
                    fontSize: 13,
                    color: textSecondaryColor,
                    fontFamily: 'Raleway')),
          ],
        ],
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// TASK CARD
// ═══════════════════════════════════════════════════════════════════════════
class _TaskCard extends StatelessWidget {
  final CollabTask task;
  final String currentUid;
  final bool isAdmin;
  final bool isBlocked;
  final String? blockedByName;
  final String? urutanLabel;
  final void Function(bool)? onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TaskCard({
    required this.task,
    required this.currentUid,
    required this.isAdmin,
    required this.isBlocked,
    this.blockedByName,
    this.urutanLabel,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isOverdue = task.waktuPengerjaan.isBefore(now) && !task.isCompleted;
    final isToday = task.waktuPengerjaan.day == now.day &&
        task.waktuPengerjaan.month == now.month &&
        task.waktuPengerjaan.year == now.year;
    final isMyTask = task.assigneeUid == currentUid;

    Color borderColor = Colors.grey.shade200;
    if (isBlocked) borderColor = warningColor.withValues(alpha: 0.5);
    if (isOverdue) borderColor = errorColor.withValues(alpha: 0.4);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isBlocked
            ? Colors.orange.withValues(alpha: 0.03)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Checkbox / lock icon
                isBlocked
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: Icon(Icons.lock,
                            size: 20, color: Colors.orange.shade400),
                      )
                    : Checkbox(
                        value: task.isCompleted,
                        activeColor: task.isSeri ? secondaryColor : primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                        onChanged: onToggle == null
                            ? null
                            : (val) => onToggle!(val ?? false),
                      ),
                // Judul + badges
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (urutanLabel != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: secondaryColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(urutanLabel!,
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: secondaryColor,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'Raleway')),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Expanded(
                              child: Text(
                                task.namaTugas,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Raleway',
                                  color: task.isCompleted || isBlocked
                                      ? textSecondaryColor
                                      : textPrimaryColor,
                                  decoration: task.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            _badge(
                              icon: Icons.person,
                              label: isMyTask ? 'Tugasku' : task.assigneeNama,
                              color: isMyTask ? primaryColor : textSecondaryColor,
                            ),
                            if (isBlocked)
                              _badge(
                                  icon: Icons.lock,
                                  label: 'Terkunci',
                                  color: warningColor),
                            if (isToday && !task.isCompleted && !isBlocked)
                              _badge(
                                  icon: Icons.today,
                                  label: 'Hari ini',
                                  color: Colors.blue),
                            if (isOverdue && !isBlocked)
                              _badge(
                                  icon: Icons.warning_amber,
                                  label: 'Terlambat',
                                  color: errorColor),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Edit & delete
                if (isAdmin || isMyTask)
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit,
                            size: 18, color: primaryColor),
                        onPressed: onEdit,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(height: 4),
                      IconButton(
                        icon: const Icon(Icons.delete,
                            size: 18, color: errorColor),
                        onPressed: onDelete,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
              ],
            ),
            // Pesan terkunci
            if (isBlocked && blockedByName != null)
              Container(
                margin: const EdgeInsets.only(top: 6),
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 14, color: Colors.orange.shade700),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Selesaikan "$blockedByName" terlebih dahulu',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade700,
                            fontFamily: 'Raleway'),
                      ),
                    ),
                  ],
                ),
              ),
            if (task.deskripsi.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 6, 6, 0),
                child: Text(task.deskripsi,
                    style: const TextStyle(
                        fontSize: 13,
                        color: textSecondaryColor,
                        fontFamily: 'Raleway'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: (isOverdue ? errorColor : primaryColor)
                    .withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.access_time,
                      size: 14,
                      color: isOverdue ? errorColor : primaryColor),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('dd MMM yyyy, HH:mm', 'id_ID')
                        .format(task.waktuPengerjaan),
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Raleway',
                        color: isOverdue ? errorColor : primaryColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(
      {required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Raleway')),
        ],
      ),
    );
  }
}
