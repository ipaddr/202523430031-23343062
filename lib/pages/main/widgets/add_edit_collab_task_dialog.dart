import 'package:betomic/models/collab_task.dart';
import 'package:betomic/models/group.dart';
import 'package:betomic/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Dialog untuk tambah atau edit tugas kolaboratif.
/// Mendukung pemilihan mode: paralel (bebas) atau seri (berurutan).
class AddEditCollabTaskDialog extends StatefulWidget {
  final List<GroupMember> members;
  final CollabTask? task; // null = mode tambah
  /// mode awal yang dipilih sebelum dialog dibuka (opsional, default 'paralel')
  final String initialMode;
  final Future<void> Function({
    required String namaTugas,
    required String deskripsi,
    required String assigneeUid,
    required String assigneeNama,
    required DateTime waktuPengerjaan,
    required String mode,
  }) onSave;

  const AddEditCollabTaskDialog({
    super.key,
    required this.members,
    required this.onSave,
    this.task,
    this.initialMode = 'paralel',
  });

  @override
  State<AddEditCollabTaskDialog> createState() =>
      _AddEditCollabTaskDialogState();
}

class _AddEditCollabTaskDialogState extends State<AddEditCollabTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaTugasCtrl;
  late final TextEditingController _deskripsiCtrl;

  GroupMember? _selectedMember;
  DateTime? _selectedDateTime;
  late String _selectedMode; // 'paralel' | 'seri'
  bool _isLoading = false;

  bool get _isEdit => widget.task != null;

  @override
  void initState() {
    super.initState();
    _namaTugasCtrl = TextEditingController(text: widget.task?.namaTugas ?? '');
    _deskripsiCtrl = TextEditingController(text: widget.task?.deskripsi ?? '');
    _selectedDateTime = widget.task?.waktuPengerjaan;
    _selectedMode = widget.task?.mode ?? widget.initialMode;

    if (_isEdit) {
      try {
        _selectedMember = widget.members
            .firstWhere((m) => m.uid == widget.task!.assigneeUid);
      } catch (_) {
        _selectedMember =
            widget.members.isNotEmpty ? widget.members.first : null;
      }
    } else {
      _selectedMember =
          widget.members.isNotEmpty ? widget.members.first : null;
    }
  }

  @override
  void dispose() {
    _namaTugasCtrl.dispose();
    _deskripsiCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: primaryColor),
        ),
        child: child!,
      ),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: primaryColor),
        ),
        child: child!,
      ),
    );
    if (time == null || !mounted) return;

    setState(() {
      _selectedDateTime = DateTime(
          date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Pilih waktu pengerjaan terlebih dahulu')));
      return;
    }
    if (_selectedMember == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih anggota yang ditugaskan')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await widget.onSave(
        namaTugas: _namaTugasCtrl.text.trim(),
        deskripsi: _deskripsiCtrl.text.trim(),
        assigneeUid: _selectedMember!.uid,
        assigneeNama: _selectedMember!.nama,
        waktuPengerjaan: _selectedDateTime!,
        mode: _selectedMode,
      );
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.assignment,
                        color: primaryColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _isEdit ? 'Edit Tugas' : 'Tambah Tugas',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Raleway',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Mode Pengerjaan ──
              _label('Mode Pengerjaan'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _modeButton(
                      label: 'Paralel',
                      icon: Icons.compare_arrows,
                      desc: 'Bebas dikerjakan kapan saja',
                      value: 'paralel',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _modeButton(
                      label: 'Seri',
                      icon: Icons.linear_scale,
                      desc: 'Harus berurutan',
                      value: 'seri',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Nama Tugas ──
              _label('Nama Tugas'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _namaTugasCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: _inputDecoration('Contoh: Buat laporan bab 3'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Nama tugas wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),

              // ── Deskripsi ──
              _label('Deskripsi'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _deskripsiCtrl,
                maxLines: 3,
                decoration: _inputDecoration('Opsional — detail tugas'),
              ),
              const SizedBox(height: 16),

              // ── Assignee ──
              _label('Ditugaskan kepada'),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<GroupMember>(
                    value: _selectedMember,
                    isExpanded: true,
                    hint: const Text('Pilih anggota',
                        style: TextStyle(
                            fontSize: 13,
                            color: textSecondaryColor,
                            fontFamily: 'Raleway')),
                    items: widget.members
                        .map((m) => DropdownMenuItem(
                              value: m,
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor:
                                        primaryColor.withValues(alpha: 0.15),
                                    child: Text(
                                      m.nama.isNotEmpty
                                          ? m.nama[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: primaryColor,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(m.nama,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'Raleway')),
                                        if (m.isAdmin)
                                          const Text('Admin',
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: primaryColor,
                                                  fontFamily: 'Raleway')),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                    onChanged: (m) => setState(() => _selectedMember = m),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Waktu Pengerjaan ──
              _label('Waktu Pengerjaan'),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _pickDateTime,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 18, color: primaryColor),
                      const SizedBox(width: 10),
                      Text(
                        _selectedDateTime == null
                            ? 'Pilih tanggal & jam'
                            : DateFormat('dd MMMM yyyy, HH:mm', 'id_ID')
                                .format(_selectedDateTime!),
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Raleway',
                          color: _selectedDateTime == null
                              ? textSecondaryColor
                              : textPrimaryColor,
                          fontWeight: _selectedDateTime == null
                              ? FontWeight.normal
                              : FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Buttons ──
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        _isLoading ? null : () => Navigator.pop(context),
                    child: const Text('Batal',
                        style: TextStyle(color: textSecondaryColor)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text(
                            _isEdit ? 'Simpan' : 'Tambah',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Raleway'),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Tombol pilih mode seri/paralel ──
  Widget _modeButton({
    required String label,
    required IconData icon,
    required String desc,
    required String value,
  }) {
    final isSelected = _selectedMode == value;
    final color = value == 'seri' ? secondaryColor : primaryColor;
    return GestureDetector(
      onTap: () => setState(() => _selectedMode = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : textSecondaryColor, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontFamily: 'Raleway',
                color: isSelected ? color : textPrimaryColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              desc,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                color: textSecondaryColor,
                fontFamily: 'Raleway',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
          fontFamily: 'Raleway',
        ),
      );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
            color: textSecondaryColor, fontSize: 13, fontFamily: 'Raleway'),
        filled: true,
        fillColor: backgroundColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: primaryColor, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: errorColor, width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: errorColor, width: 1.5)),
      );
}
