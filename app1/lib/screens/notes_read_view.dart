import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/notes_stream_service.dart';

/// Screen untuk membaca semua notes dengan fitur lengkap
/// Menampilkan semua notes dalam format list yang elegan
/// Dengan sorting, filtering, dan pengaturan view
class NotesReadView extends StatefulWidget {
  const NotesReadView({super.key});

  @override
  State<NotesReadView> createState() => _NotesReadViewState();
}

class _NotesReadViewState extends State<NotesReadView> {
  final NotesStreamService _notesService = NotesStreamService();

  // Controllers
  late TextEditingController _searchController;

  // State variables
  String _searchQuery = '';
  int _sortBy = 0; // 0: newest, 1: oldest, 2: title A-Z
  int _viewMode = 0; // 0: list, 1: grid
  bool _showOnlyPinned = false;
  String _filterCategory = 'All'; // 'All' atau category name

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
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
    _searchController.dispose();
    _notesService.dispose();
    super.dispose();
  }

  /// Sort notes berdasarkan pilihan user
  List<NoteModel> _sortNotes(List<NoteModel> notes) {
    switch (_sortBy) {
      case 0: // Newest first
        return notes..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case 1: // Oldest first
        return notes..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case 2: // Title A-Z
        return notes..sort((a, b) => a.title.compareTo(b.title));
      default:
        return notes;
    }
  }

  /// Filter notes berdasarkan search dan category
  List<NoteModel> _filterNotes(List<NoteModel> notes) {
    return notes.where((note) {
      // Filter by search query
      final matchesSearch =
          _searchQuery.isEmpty ||
          note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          note.content.toLowerCase().contains(_searchQuery.toLowerCase());

      // Filter by pinned
      final matchesPinned = !_showOnlyPinned || note.isPinned;

      // Filter by category
      final matchesCategory =
          _filterCategory == 'All' || note.category == _filterCategory;

      return matchesSearch && matchesPinned && matchesCategory;
    }).toList();
  }

  /// Tampilkan detail note dalam dialog
  Future<void> _showNoteDetail(NoteModel note) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(note.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (note.category != null) ...[
                Text(
                  'Category: ${note.category}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
              ],
              Text(note.content, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Created: ${_formatDate(note.createdAt)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        if (note.updatedAt != null)
                          Text(
                            'Updated: ${_formatDate(note.updatedAt!)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (note.isPinned)
                    const Tooltip(
                      message: 'Pinned',
                      child: Icon(Icons.push_pin, color: Colors.orange),
                    ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _togglePin(note.id);
            },
            child: Text(note.isPinned ? 'Unpin' : 'Pin'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _toggleArchive(note.id);
            },
            child: Text(note.isArchived ? 'Unarchive' : 'Archive'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteNote(note.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Toggle pin status
  Future<void> _togglePin(String noteId) async {
    await _notesService.togglePinStatus(noteId);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pin status updated')));
    }
  }

  /// Toggle archive status
  Future<void> _toggleArchive(String noteId) async {
    await _notesService.toggleArchiveStatus(noteId);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Archive status updated')));
    }
  }

  /// Delete note dengan confirmation
  Future<void> _deleteNote(String noteId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note?'),
        content: const Text('Catatan akan dihapus. Lanjutkan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _notesService.deleteNote(noteId);
              if (mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Note deleted')));
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// Format date untuk display
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (dateOnly == yesterday) {
      return 'Yesterday ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  /// Build list view untuk notes
  Widget _buildListView(List<NoteModel> notes) {
    if (notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No notes found',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return _buildNoteCard(note);
      },
    );
  }

  /// Build note card
  Widget _buildNoteCard(NoteModel note) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: InkWell(
        onTap: () => _showNoteDetail(note),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title dan status icons
              Row(
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (note.isPinned)
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.push_pin,
                        size: 16,
                        color: Colors.orange,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Content preview
              Text(
                note.content,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Category dan date
              Row(
                children: [
                  if (note.category != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        note.category!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  const Spacer(),
                  Text(
                    _formatDate(note.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build grid view untuk notes
  Widget _buildGridView(List<NoteModel> notes) {
    if (notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No notes found',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return Card(
          child: InkWell(
            onTap: () => _showNoteDetail(note),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          note.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (note.isPinned)
                        const Icon(
                          Icons.push_pin,
                          size: 14,
                          color: Colors.orange,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      note.content,
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (note.category != null)
                    Chip(
                      label: Text(
                        note.category!,
                        style: const TextStyle(fontSize: 10),
                      ),
                      backgroundColor: Colors.blue[100],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Tampilkan filter categories dari stream
  Widget _buildCategoryFilter() {
    return StreamBuilder<List<NoteCategoryModel>>(
      stream: _notesService.getCategoriesStream(),
      builder: (context, snapshot) {
        final categories = snapshot.data ?? [];
        final categoryNames = [
          'All',
          ...categories.map((c) => c.name).toList(),
        ];

        return SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: categoryNames.length,
            itemBuilder: (context, index) {
              final category = categoryNames[index];
              final isSelected = _filterCategory == category;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _filterCategory = category;
                    });
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Notes'),
        elevation: 2,
        actions: [
          // Sort dropdown
          PopupMenuButton<int>(
            onSelected: (value) {
              setState(() => _sortBy = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 0, child: Text('Newest First')),
              const PopupMenuItem(value: 1, child: Text('Oldest First')),
              const PopupMenuItem(value: 2, child: Text('Title (A-Z)')),
            ],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Icon(
                _sortBy == 0
                    ? Icons.sort
                    : _sortBy == 1
                    ? Icons.sort
                    : Icons.sort_by_alpha,
              ),
            ),
          ),

          // View mode toggle
          IconButton(
            onPressed: () {
              setState(() => _viewMode = _viewMode == 0 ? 1 : 0);
            },
            icon: Icon(_viewMode == 0 ? Icons.grid_view : Icons.view_list),
          ),

          // Filter pinned
          IconButton(
            onPressed: () {
              setState(() => _showOnlyPinned = !_showOnlyPinned);
            },
            icon: Icon(
              Icons.push_pin,
              color: _showOnlyPinned ? Colors.orange : Colors.grey,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
              decoration: InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Category filter
          _buildCategoryFilter(),

          // Notes content
          Expanded(
            child: StreamBuilder<List<NoteModel>>(
              stream: _notesService.getAllNotesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                      ],
                    ),
                  );
                }

                final notes = snapshot.data ?? [];
                final filteredNotes = _filterNotes(notes);
                final sortedNotes = _sortNotes(filteredNotes);

                if (_viewMode == 0) {
                  return _buildListView(sortedNotes);
                } else {
                  return _buildGridView(sortedNotes);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
