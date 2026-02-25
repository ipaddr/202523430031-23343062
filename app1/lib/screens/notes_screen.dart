import 'package:flutter/material.dart';
import 'package:app1/models/models.dart';
import 'package:app1/services/auth_service.dart';

/// Notes Screen - Halaman untuk mengelola catatan
class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _authService = AuthService();
  final _searchController = TextEditingController();

  /// Sample notes data - In production, fetch from Firestore
  List<NoteModel> _notes = [];
  List<NoteModel> _filteredNotes = [];
  String _selectedCategory = 'Semua';
  bool _showCompleted = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _searchController.addListener(_filterNotes);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Load notes - TODO: Connect to Firestore
  void _loadNotes() {
    _notes = [
      NoteModel(
        id: '1',
        title: 'Kerja Proyek Flutter',
        content: 'Selesaikan fitur login dan register',
        userId: _authService.currentUser?.uid ?? '',
        category: 'Kerja',
        isDone: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      NoteModel(
        id: '2',
        title: 'Beli Groceries',
        content: 'Beli susu, telur, dan roti di supermarket',
        userId: _authService.currentUser?.uid ?? '',
        category: 'Belanja',
        isDone: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      NoteModel(
        id: '3',
        title: 'Meeting Klien',
        content: 'Diskusi tentang requirement aplikasi baru',
        userId: _authService.currentUser?.uid ?? '',
        category: 'Rapat',
        isDone: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
    _filterNotes();
  }

  /// Filter and search notes
  void _filterNotes() {
    _filteredNotes = _notes.where((note) {
      // Filter by search
      final matchesSearch =
          note.title.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          ) ||
          note.content.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          );

      // Filter by category
      final matchesCategory =
          _selectedCategory == 'Semua' || note.category == _selectedCategory;

      // Filter by completion status
      final matchesStatus = _showCompleted || !note.isDone;

      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();

    setState(() {});
  }

  /// Show add/edit note dialog
  void _showNoteDialog({NoteModel? note}) {
    final isEditing = note != null;
    final titleController = TextEditingController(text: note?.title ?? '');
    final contentController = TextEditingController(text: note?.content ?? '');
    String selectedCategory = note?.category ?? 'Kerja';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(isEditing ? 'Edit Catatan' : 'Catatan Baru'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Judul',
                    hintText: 'Masukkan judul catatan',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  decoration: InputDecoration(
                    labelText: 'Isi',
                    hintText: 'Masukkan isi catatan',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: ['Kerja', 'Belanja', 'Rapat', 'Pribadi', 'Lainnya']
                      .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) selectedCategory = value;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final newNote = NoteModel(
                  id: note?.id ?? DateTime.now().toString(),
                  title: titleController.text,
                  content: contentController.text,
                  userId: _authService.currentUser?.uid ?? '',
                  category: selectedCategory,
                  isDone: note?.isDone ?? false,
                  createdAt: note?.createdAt ?? DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                setState(() {
                  if (isEditing) {
                    final index = _notes.indexWhere((n) => n.id == note.id);
                    if (index != -1) {
                      _notes[index] = newNote;
                    }
                  } else {
                    _notes.add(newNote);
                  }
                  _filterNotes();
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isEditing
                          ? 'Catatan diperbarui'
                          : 'Catatan berhasil ditambahkan',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text(isEditing ? 'Perbarui' : 'Simpan'),
            ),
          ],
        );
      },
    );
  }

  /// Delete note with confirmation
  void _deleteNote(NoteModel note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Catatan'),
        content: const Text('Apakah Anda yakin ingin menghapus catatan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _notes.removeWhere((n) => n.id == note.id);
                _filterNotes();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Catatan dihapus'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Toggle note completion status
  void _toggleNoteStatus(NoteModel note) {
    setState(() {
      final index = _notes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        _notes[index] = note.copyWith(isDone: !note.isDone);
        _filterNotes();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Saya'),
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_filteredNotes.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari catatan...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // Filter and Toggle Options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Category Filter
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      children:
                          ['Semua', 'Kerja', 'Belanja', 'Rapat', 'Pribadi']
                              .map(
                                (category) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: FilterChip(
                                    label: Text(category),
                                    selected: _selectedCategory == category,
                                    onSelected: (selected) {
                                      setState(() {
                                        _selectedCategory = selected
                                            ? category
                                            : 'Semua';
                                        _filterNotes();
                                      });
                                    },
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Toggle Completed Notes
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Checkbox(
                  value: _showCompleted,
                  onChanged: (value) {
                    setState(() {
                      _showCompleted = value ?? true;
                      _filterNotes();
                    });
                  },
                ),
                const Text('Tampilkan catatan selesai'),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Notes List
          Expanded(
            child: _filteredNotes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.note_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada catatan',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredNotes.length,
                    itemBuilder: (context, index) {
                      final note = _filteredNotes[index];
                      return _NoteCard(
                        note: note,
                        onEdit: () => _showNoteDialog(note: note),
                        onDelete: () => _deleteNote(note),
                        onToggle: () => _toggleNoteStatus(note),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNoteDialog(),
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Note Card Widget
class _NoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  const _NoteCard({
    required this.note,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Checkbox
            Row(
              children: [
                Checkbox(value: note.isDone, onChanged: (_) => onToggle()),
                Expanded(
                  child: Text(
                    note.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      decoration: note.isDone
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Content
            Text(
              note.content,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                decoration: note.isDone
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Category and Date
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    note.category ?? 'Umum',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _formatDate(note.createdAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  label: const Text(
                    'Hapus',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inDays < 1) {
      return 'Hari ini';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
