import 'package:betomic/theme.dart';
import 'package:flutter/material.dart';

/// Dialog untuk membuat atau mengedit kelompok.
class AddEditGroupDialog extends StatefulWidget {
  /// Jika null → mode tambah, jika diisi → mode edit.
  final String? initialNama;
  final String? initialDeskripsi;
  final Future<void> Function(String nama, String deskripsi) onSave;

  const AddEditGroupDialog({
    super.key,
    this.initialNama,
    this.initialDeskripsi,
    required this.onSave,
  });

  @override
  State<AddEditGroupDialog> createState() => _AddEditGroupDialogState();
}

class _AddEditGroupDialogState extends State<AddEditGroupDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaCtrl;
  late final TextEditingController _deskripsiCtrl;
  bool _isLoading = false;

  bool get _isEdit => widget.initialNama != null;

  @override
  void initState() {
    super.initState();
    _namaCtrl = TextEditingController(text: widget.initialNama ?? '');
    _deskripsiCtrl =
        TextEditingController(text: widget.initialDeskripsi ?? '');
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _deskripsiCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await widget.onSave(_namaCtrl.text.trim(), _deskripsiCtrl.text.trim());
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
      child: Padding(
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
                    child: const Icon(Icons.group, color: primaryColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _isEdit ? 'Edit Kelompok' : 'Buat Kelompok',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Raleway',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Nama Kelompok ──
              const Text(
                'Nama Kelompok',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textPrimaryColor,
                  fontFamily: 'Raleway',
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _namaCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: _inputDecoration('Contoh: Tim Skripsi Kelompok A'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Nama kelompok wajib diisi';
                  }
                  if (v.trim().length < 3) {
                    return 'Minimal 3 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Deskripsi ──
              const Text(
                'Deskripsi',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textPrimaryColor,
                  fontFamily: 'Raleway',
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _deskripsiCtrl,
                maxLines: 3,
                decoration: _inputDecoration('Opsional — deskripsi singkat kelompok'),
              ),
              const SizedBox(height: 24),

              // ── Buttons ──
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        _isLoading ? null : () => Navigator.pop(context),
                    child: const Text(
                      'Batal',
                      style: TextStyle(color: textSecondaryColor),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _isEdit ? 'Simpan' : 'Buat',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Raleway',
                            ),
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

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: textSecondaryColor,
        fontSize: 13,
        fontFamily: 'Raleway',
      ),
      filled: true,
      fillColor: backgroundColor,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: errorColor, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: errorColor, width: 1.5),
      ),
    );
  }
}
