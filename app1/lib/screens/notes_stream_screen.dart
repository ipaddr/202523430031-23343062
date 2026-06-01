import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/notes_stream_service.dart';

/// Screen demo untuk Notes dengan Streams
class NotesStreamScreen extends StatefulWidget {
  const NotesStreamScreen({super.key});

  @override
  State<NotesStreamScreen> createState() => _NotesStreamScreenState();
}

class _NotesStreamScreenState extends State<NotesStreamScreen> {
  final NotesStreamService _notesService = NotesStreamService();

  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _searchController;

  int _selectedTab = 0; // 0: all, 1: pinned, 2: archived
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _searchController = TextEditingController();
    _initializeService();
  }

  Future<void> _initializeService() async {
    await _notesService.init();
    setState(() {});
  }

  Future<void> _createNote() async {
    if (_titleController.text.isEmpty) {
      _showSnackBar('Title tidak boleh kosong', Colors.red);
      return;
    }

    bool success = await _notesService.createNote(
      _titleController.text,
      _contentController.text,
    );

    if (success) {
      _titleController.clear();
      _contentController.clear();
      if (mounted) {
        _showSnackBar('Note berhasil ditambahkan', Colors.green);
      }
    }
  }

  Future<void> _deleteNote(String id) async {
    bool success = await _notesService.deleteNote(id);
    if (success && mounted) {
      _showSnackBar('Note berhasil dihapus', Colors.orange);
    }
  }

  Future<void> _togglePin(String id) async {
    await _notesService.togglePinStatus(id);
  }

  Future<void> _toggleArchive(String id) async {
    await _notesService.toggleArchiveStatus(id);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes dengan Streams'), elevation: 0),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== CREATE SECTION =====
              _buildCreateSection(),
              const SizedBox(height: 20),

              // ===== SEARCH SECTION =====
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
                decoration: InputDecoration(
                  hintText: 'Cari note...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ===== TABS SECTION =====
              _buildTabButtons(),
              const SizedBox(height: 16),

              // ===== NOTES STREAM SECTION =====
              _buildNotesStream(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create New Note',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Note title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                hintText: 'Note content',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.description),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _createNote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Create Note',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButtons() {
    return Row(
      children: [
        Expanded(child: _buildTabButton('All', 0)),
        const SizedBox(width: 8),
        Expanded(child: _buildTabButton('Pinned', 1)),
        const SizedBox(width: 8),
        Expanded(child: _buildTabButton('Archived', 2)),
      ],
    );
  }

  Widget _buildTabButton(String label, int tabIndex) {
    return ElevatedButton(
      onPressed: () {
        setState(() => _selectedTab = tabIndex);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _selectedTab == tabIndex
            ? Colors.blue
            : Colors.grey[300],
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: _selectedTab == tabIndex ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildNotesStream() {
    // Build title
    final title = _selectedTab == 0
        ? 'All Notes'
        : _selectedTab == 1
        ? 'Pinned Notes'
        : 'Archived Notes';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<NoteModel>>(
          stream: _getStreamForTab(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final notes = snapshot.data ?? [];
            final filteredNotes = _searchQuery.isEmpty
                ? notes
                : notes
                      .where(
                        (note) =>
                            note.title.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            ) ||
                            note.content.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            ),
                      )
                      .toList();

            if (filteredNotes.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      Icon(Icons.note, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        _searchQuery.isEmpty
                            ? 'No notes yet'
                            : 'No matching notes',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredNotes.length,
              itemBuilder: (context, index) {
                final note = filteredNotes[index];
                return _buildNoteCard(note);
              },
            );
          },
        ),
      ],
    );
  }

  Stream<List<NoteModel>> _getStreamForTab() {
    switch (_selectedTab) {
      case 1:
        return _notesService.getPinnedNotesStream();
      case 2:
        return _notesService.getArchivedNotesStream();
      default:
        return _notesService.getAllNotesStream();
    }
  }

  Widget _buildNoteCard(NoteModel note) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    note.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (note.isPinned)
                  const Icon(Icons.push_pin, color: Colors.orange, size: 18),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              note.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(note.createdAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        note.isPinned
                            ? Icons.push_pin
                            : Icons.push_pin_outlined,
                        size: 20,
                      ),
                      color: note.isPinned ? Colors.orange : Colors.grey,
                      onPressed: () => _togglePin(note.id),
                    ),
                    IconButton(
                      icon: Icon(
                        note.isArchived
                            ? Icons.unarchive
                            : Icons.archive_outlined,
                        size: 20,
                      ),
                      color: note.isArchived ? Colors.grey : Colors.blue,
                      onPressed: () => _toggleArchive(note.id),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      color: Colors.red,
                      onPressed: () => _deleteNote(note.id),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _searchController.dispose();
    _notesService.dispose();
    super.dispose();
  }
}
