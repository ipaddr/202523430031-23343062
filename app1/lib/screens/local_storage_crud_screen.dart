import 'package:flutter/material.dart';
import '../models/todo_model.dart';
import '../services/local_storage_service.dart';
import '../services/todo_repository.dart';

/// Screen demo untuk CRUD Local Storage
class LocalStorageCrudScreen extends StatefulWidget {
  const LocalStorageCrudScreen({super.key});

  @override
  State<LocalStorageCrudScreen> createState() => _LocalStorageCrudScreenState();
}

class _LocalStorageCrudScreenState extends State<LocalStorageCrudScreen> {
  final TodoRepository _todoRepository = TodoRepository();
  final LocalStorageService _storage = LocalStorageService();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _searchController;

  List<TodoModel> _todos = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _searchController = TextEditingController();
    _initializeStorage();
    _loadTodos();
  }

  Future<void> _initializeStorage() async {
    await _storage.init();
  }

  Future<void> _loadTodos() async {
    setState(() => _isLoading = true);
    try {
      _todos = await _todoRepository.getAllTodos();
      setState(() {});
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createTodo() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Title tidak boleh kosong')));
      return;
    }

    bool success = await _todoRepository.createTodo(
      _titleController.text,
      _descriptionController.text,
    );

    if (success) {
      _titleController.clear();
      _descriptionController.clear();
      _loadTodos();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Todo berhasil ditambahkan'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _deleteTodo(String id) async {
    bool success = await _todoRepository.deleteTodo(id);
    if (success) {
      _loadTodos();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Todo berhasil dihapus'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _toggleCompletion(String id) async {
    bool success = await _todoRepository.toggleTodoCompletion(id);
    if (success) {
      _loadTodos();
    }
  }

  Future<void> _searchTodos(String query) async {
    if (query.isEmpty) {
      _loadTodos();
    } else {
      setState(() => _isLoading = true);
      try {
        _todos = await _todoRepository.searchTodos(query);
        setState(() {});
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteAllTodos() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Semua Todo'),
        content: const Text('Apakah Anda yakin ingin menghapus semua todo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              bool success = await _todoRepository.deleteAllTodos();
              if (success) {
                _loadTodos();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Semua todo berhasil dihapus'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRUD Local Storage Demo'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== CREATE SECTION =====
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'CREATE - Tambah Todo',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _titleController,
                              decoration: InputDecoration(
                                hintText: 'Judul todo',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(Icons.title),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _descriptionController,
                              decoration: InputDecoration(
                                hintText: 'Deskripsi todo',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(Icons.description),
                              ),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _createTodo,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text(
                                  'Tambah Todo',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ===== SEARCH SECTION =====
                    TextField(
                      controller: _searchController,
                      onChanged: _searchTodos,
                      decoration: InputDecoration(
                        hintText: 'Cari todo...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ===== STATS SECTION =====
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total',
                            _todos.length.toString(),
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            'Selesai',
                            _todos
                                .where((t) => t.isCompleted)
                                .length
                                .toString(),
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            'Pending',
                            _todos
                                .where((t) => !t.isCompleted)
                                .length
                                .toString(),
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ===== READ SECTION (List Todos) =====
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'READ - Daftar Todo',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _todos.isEmpty ? null : _deleteAllTodos,
                          icon: const Icon(Icons.delete_sweep),
                          label: const Text('Hapus Semua'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (_todos.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.done_all,
                                size: 48,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tidak ada todo',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _todos.length,
                        itemBuilder: (context, index) {
                          final todo = _todos[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Checkbox(
                                value: todo.isCompleted,
                                onChanged: (_) => _toggleCompletion(todo.id),
                              ),
                              title: Text(
                                todo.title,
                                style: TextStyle(
                                  decoration: todo.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              subtitle: Text(
                                todo.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                color: Colors.red,
                                onPressed: () => _deleteTodo(todo.id),
                              ),
                              onTap: () => _showTodoDetail(todo),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  void _showTodoDetail(TodoModel todo) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Detail Todo',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text('ID: ${todo.id}'),
            const SizedBox(height: 8),
            Text('Title: ${todo.title}'),
            const SizedBox(height: 8),
            Text('Description: ${todo.description}'),
            const SizedBox(height: 8),
            Text('Status: ${todo.isCompleted ? 'Selesai' : 'Pending'}'),
            const SizedBox(height: 8),
            Text('Created: ${todo.createdAt.toString().split('.')[0]}'),
            if (todo.updatedAt != null)
              Text('Updated: ${todo.updatedAt.toString().split('.')[0]}'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(label),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
