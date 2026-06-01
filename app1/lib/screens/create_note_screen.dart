import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/notes_stream_service.dart';
import '../services/firestore_notes_service.dart';
import '../services/auth_service.dart';
import 'package:uuid/uuid.dart';
import '../blocs/loading_bloc.dart';
import '../blocs/dialog_bloc.dart';
import '../blocs/navigation_bloc.dart';
import '../widgets/loading_widgets.dart';

class CreateNoteScreen extends StatefulWidget {
  const CreateNoteScreen({super.key});

  @override
  State<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _notesService = NotesStreamService();
  final _firestoreService = FirestoreNotesService();
  final _authService = AuthService();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
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
      LoadingBloc.start(context, message: 'Menyimpan catatan...');

      // Get current user ID
      final userId = _authService.uid;
      if (userId == null) {
        LoadingBloc.stop(context);
        if (mounted) {
          DialogBloc.showErrorDialog(
            context,
            title: 'Error',
            message: 'User tidak terautentikasi',
          );
        }
        return;
      }

      // Create note object
      const uuid = Uuid();
      final newNote = NoteModel(
        id: uuid.v4(),
        userId: userId,
        title: _titleController.text,
        content: _contentController.text,
        createdAt: DateTime.now(),
      );

      // Save to local storage
      bool localSuccess = await _notesService.createNote(
        _titleController.text,
        _contentController.text,
      );

      if (!localSuccess) {
        LoadingBloc.stop(context);
        if (mounted) {
          DialogBloc.showErrorDialog(
            context,
            title: 'Error',
            message: 'Gagal menyimpan catatan secara lokal',
          );
        }
        return;
      }

      // Save to Firestore
      bool firestoreSuccess = await _firestoreService.createNoteToFirestore(
        newNote,
      );

      LoadingBloc.stop(context);

      if (firestoreSuccess) {
        if (mounted) {
          // Show success dialog
          DialogBloc.showSuccessDialog(
            context,
            title: 'Berhasil',
            message: 'Catatan berhasil disimpan!',
          );

          // Clear controllers
          _titleController.clear();
          _contentController.clear();

          // Delay then pop screen
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
            message: 'Catatan disimpan lokal, namun gagal upload ke cloud',
          );

          _titleController.clear();
          _contentController.clear();

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
      appBar: AppBar(title: const Text('Buat Note Baru'), elevation: 0),
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
            const SizedBox(height: 32),

            // Save Button (Using LoadingButton)
            LoadingButton(
              label: 'Simpan Catatan',
              isLoading: false,
              onPressed: _saveNote,
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
