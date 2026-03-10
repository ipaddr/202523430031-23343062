import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/notes_stream_service.dart';

/// Screen untuk membuat notes baru dengan interface lengkap
/// Fokus pada user experience saat create/draft notes
/// Support untuk auto-save, categories, dan rich formatting
class NotesCreateView extends StatefulWidget {
  const NotesCreateView({super.key});

  @override
  State<NotesCreateView> createState() => _NotesCreateViewState();
}

class _NotesCreateViewState extends State<NotesCreateView> {
  final NotesStreamService _notesService = NotesStreamService();

  // Controllers
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  // State variables
  String _selectedCategory = '';
  bool _isPinned = false;
  bool _isAutoSaveEnabled = true;
  DateTime? _lastAutoSaveTime;
  bool _isSaving = false;

  // Auto-save timer

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _initializeService();
    _setupAutoSave();
  }

  Future<void> _initializeService() async {
    await _notesService.init();
    if (mounted) {
      setState(() {});
    }
  }

  /// Setup auto-save every 30 seconds
  void _setupAutoSave() {
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted && _isAutoSaveEnabled && _hasContent()) {
        _autoSaveNote();
        if (mounted) {
          _setupAutoSave(); // Reschedule
        }
      } else if (mounted) {
        _setupAutoSave(); // Reschedule even if not saved
      }
    });
  }

  /// Check if note has content
  bool _hasContent() {
    return _titleController.text.trim().isNotEmpty ||
        _contentController.text.trim().isNotEmpty;
  }

  /// Auto-save note sebagai draft
  Future<void> _autoSaveNote() async {
    if (!_hasContent() || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      bool success = await _notesService.createNote(
        _titleController.text.isEmpty ? 'Untitled' : _titleController.text,
        _contentController.text,
        category: _selectedCategory.isEmpty ? null : _selectedCategory,
      );

      if (success && mounted) {
        setState(() {
          _lastAutoSaveTime = DateTime.now();
          _isSaving = false;
        });

        _showAutoSaveIndicator('Auto-saved');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        _showAutoSaveIndicator('Auto-save failed', Colors.red);
      }
    }
  }

  /// Save note dengan PIN option
  Future<void> _saveNote({bool pinNote = false}) async {
    if (_titleController.text.isEmpty) {
      _showSnackBar('Title tidak boleh kosong', Colors.red);
      return;
    }

    setState(() => _isSaving = true);

    try {
      bool success = await _notesService.createNote(
        _titleController.text,
        _contentController.text,
        category: _selectedCategory.isEmpty ? null : _selectedCategory,
      );

      if (success) {
        // Get the created note to pin if needed
        if (pinNote) {
          // Note: In real app, would need to track created note ID
          // For now, we'll just save without auto-pinning
        }

        if (mounted) {
          _titleController.clear();
          _contentController.clear();
          setState(() {
            _selectedCategory = '';
            _isPinned = false;
            _isSaving = false;
          });

          _showSnackBar('Note created successfully', Colors.green);

          // Optional: show success dialog
          _showSuccessDialog();
        }
      } else {
        _showSnackBar('Failed to create note', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  /// Show success dialog after note creation
  Future<void> _showSuccessDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: const Text('Note Created!'),
        content: const Text('Your note has been saved successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showCreateAnother();
            },
            child: const Text('Create Another'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  /// Show dialog untuk membuat note lain
  Future<void> _showCreateAnother() async {
    // Dialog bisa menampilkan quick categories atau suggestions
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Another Note?'),
        content: const Text('Mulai note baru atau pilih dari suggestions?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // New note ready, just show the form
            },
            child: const Text('New Note'),
          ),
        ],
      ),
    );
  }

  /// Show snackbar message
  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show auto-save indicator
  void _showAutoSaveIndicator(String message, [Color? color]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color ?? Colors.blue[700],
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// Clear form
  void _clearForm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Form?'),
        content: const Text('Semua konten akan dihapus. Lanjutkan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _titleController.clear();
              _contentController.clear();
              setState(() {
                _selectedCategory = '';
                _isPinned = false;
              });
              _showSnackBar('Form cleared', Colors.blue);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  /// Build category selector
  Widget _buildCategorySelector() {
    return StreamBuilder<List<NoteCategoryModel>>(
      stream: _notesService.getCategoriesStream(),
      builder: (context, snapshot) {
        final categories = snapshot.data ?? [];

        if (categories.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'No categories yet',
              style: TextStyle(color: Colors.grey[600]),
            ),
          );
        }

        return SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: categories.length + 1, // +1 for None
            itemBuilder: (context, index) {
              if (index == 0) {
                final isSelected = _selectedCategory.isEmpty;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('None'),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedCategory = '');
                    },
                  ),
                );
              }

              final category = categories[index - 1];
              final isSelected = _selectedCategory == category.name;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(
                      () => _selectedCategory = selected ? category.name : '',
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Build character count indicator
  Widget _buildCharacterCount() {
    final totalChars =
        _titleController.text.length + _contentController.text.length;
    final wordCount = _contentController.text.split(RegExp(r'\s+')).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Text(
            'Words: $wordCount',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(width: 16),
          Text(
            'Characters: $totalChars',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          if (_lastAutoSaveTime != null) ...[
            const Spacer(),
            Icon(Icons.cloud_done, size: 16, color: Colors.green[700]),
            const SizedBox(width: 4),
            Text(
              'Saved',
              style: TextStyle(fontSize: 12, color: Colors.green[700]),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _notesService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_hasContent()) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Discard Note?'),
              content: const Text('Catatan Anda akan hilang. Lanjutkan?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Keep Writing'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Close screen
                  },
                  child: const Text('Discard'),
                ),
              ],
            ),
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create New Note'),
          elevation: 2,
          actions: [
            // Auto-save toggle
            IconButton(
              onPressed: () {
                setState(() => _isAutoSaveEnabled = !_isAutoSaveEnabled);
                _showSnackBar(
                  _isAutoSaveEnabled
                      ? 'Auto-save enabled'
                      : 'Auto-save disabled',
                  Colors.blue,
                );
              },
              icon: Icon(
                _isAutoSaveEnabled ? Icons.cloud_queue : Icons.cloud_off,
                color: _isAutoSaveEnabled ? Colors.blue : Colors.grey,
              ),
              tooltip: 'Toggle auto-save',
            ),

            // Pin button
            IconButton(
              onPressed: () {
                setState(() => _isPinned = !_isPinned);
              },
              icon: Icon(
                Icons.push_pin,
                color: _isPinned ? Colors.orange : Colors.grey,
              ),
              tooltip: _isPinned ? 'Unpin' : 'Pin',
            ),

            // Save button
            Padding(
              padding: const EdgeInsets.all(8),
              child: Center(
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : ElevatedButton.icon(
                        onPressed: () => _saveNote(),
                        icon: const Icon(Icons.save, size: 18),
                        label: const Text('Save'),
                      ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title field
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Note Title',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 18),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
              ),

              const SizedBox(height: 16),

              // Category selector
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildCategorySelector(),
                  ],
                ),
              ),

              const Divider(),

              // Content field
              TextField(
                controller: _contentController,
                decoration: InputDecoration(
                  hintText: 'Start typing your note...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(fontSize: 16, height: 1.6),
                maxLines: null,
                minLines: 15,
              ),

              const SizedBox(height: 16),

              // Character count
              _buildCharacterCount(),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _clearForm,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Clear'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[100],
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : () => _saveNote(),
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Save Note'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Tips section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tips:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '• Auto-save adalah aktif default\n'
                      '• Gunakan kategori untuk organize notes\n'
                      '• Pin penting notes untuk akses cepat\n'
                      '• Tekan kembali untuk batalkan (jika ada konten)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[800],
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
