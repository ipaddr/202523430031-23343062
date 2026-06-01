import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/notes_stream_service.dart';
import '../services/firestore_notes_service.dart';
import '../blocs/loading_bloc.dart';
import '../blocs/dialog_bloc.dart';
import '../blocs/navigation_bloc.dart';
import '../widgets/loading_widgets.dart';

class EditNoteScreen extends StatefulWidget {
  final NoteModel note;

  const EditNoteScreen({super.key, required this.note});

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  final _notesService = NotesStreamService();
  final _firestoreService = FirestoreNotesService();
  String _selectedCategory = '';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
    _selectedCategory = widget.note.category ?? 'Umum';
    _initializeService();
  }

  Future<void> _initializeService() async {
    await _notesService.init();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _updateNote() async {
    // Validation
    if (_titleController.text.isEmpty) {
      DialogBloc.showErrorDialog(
        context,
        title: 'Validasi Gagal',
        message: 'Judul tidak boleh kosong!',
      );
      return;
    }

    try {
      // Show loading overlay
      LoadingBloc.start(context, message: 'Menyimpan perubahan...');

      final updatedNote = widget.note.copyWith(
        title: _titleController.text,
        content: _contentController.text,
        category: _selectedCategory,
        updatedAt: DateTime.now(),
      );

      // Update local storage
      bool localSuccess = await _notesService.updateNote(updatedNote);

      if (!localSuccess) {
        LoadingBloc.stop(context);
        if (mounted) {
          DialogBloc.showErrorDialog(
            context,
            title: 'Error',
            message: 'Gagal menyimpan perubahan secara lokal',
          );
        }
        return;
      }

      // Update Firestore
      bool firestoreSuccess = await _firestoreService.updateNoteInFirestore(
        updatedNote,
      );

      LoadingBloc.stop(context);

      if (firestoreSuccess) {
        if (mounted) {
          DialogBloc.showSuccessDialog(
            context,
            title: 'Berhasil',
            message: 'Catatan berhasil diperbarui!',
          );

          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              NavigationBloc.pop(context);
            }
          });
        }
      } else {
        if (mounted) {
          DialogBloc.showErrorDialog(
            context,
            title: 'Peringatan',
            message: 'Catatan diperbarui lokal, namun gagal update di cloud',
          );

          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              NavigationBloc.pop(context);
            }
          });
        }
      }
    } catch (e) {
      LoadingBloc.stop(context);

      if (mounted) {
        DialogBloc.showErrorDialog(
          context,
          title: 'Error',
          message: 'Error: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Note'),
        elevation: 0,
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Input
            const Text(
              'Judul',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Masukkan judul note...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 24),

            // Content Input
            const Text(
              'Isi Note',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                hintText: 'Tulis isi note di sini...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              minLines: 8,
              maxLines: null,
            ),
            const SizedBox(height: 24),

            // Category Input
            const Text(
              'Kategori',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              items: ['Umum', 'Kerja', 'Pribadi', 'Penting']
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
            ),
            const SizedBox(height: 32),

            // Save Button (Using LoadingButton)
            LoadingButton(
              label: 'Simpan Perubahan',
              isLoading: false,
              onPressed: _updateNote,
            ),
            const SizedBox(height: 12),

            // Cancel Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => NavigationBloc.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Colors.deepPurple),
                ),
                child: const Text(
                  'Batal',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
