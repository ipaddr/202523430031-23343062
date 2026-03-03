/// Quick Reference untuk menggunakan Local Storage CRUD
/// Copy dan paste code sesuai kebutuhan Anda

/*

// ============ IMPORT ============
import 'package:app1/services/local_storage_service.dart';
import 'package:app1/services/todo_repository.dart';

// ============ INITIALIZE (di main()) ============
void initializeStorage() async {
  final storage = LocalStorageService();
  await storage.init();
  print('Storage initialized');
}

// ============ SIMPLE CRUD EXAMPLES ============

// --- CREATE ---
Future<void> exampleCreate() async {
  final storage = LocalStorageService();

  // Save simple string
  await storage.saveString('user_name', 'John Doe');

  // Save object (Map)
  await storage.saveObject('profile', {
    'name': 'John',
    'email': 'john@example.com',
    'age': 25,
  });

  // Save list
  await storage.saveStringList('favorites', ['Pizza', 'Pasta', 'Burger']);
}

// --- READ ---
Future<void> exampleRead() async {
  final storage = LocalStorageService();

  // Read string
  String? userName = storage.getString('user_name');
  print('User: $userName');

  // Read object
  Map<String, dynamic>? profile = storage.getObject('profile');
  print('Profile: $profile');

  // Read list
  List<String>? favorites = storage.getStringList('favorites');
  print('Favorites: $favorites');
}

// --- UPDATE ---
Future<void> exampleUpdate() async {
  final storage = LocalStorageService();

  // Update string
  await storage.updateString('user_name', 'Jane Doe');

  // Update object
  await storage.updateObject('profile', {
    'name': 'Jane',
    'email': 'jane@example.com',
    'age': 28,
  });
}

// --- DELETE ---
Future<void> exampleDelete() async {
  final storage = LocalStorageService();

  // Delete single key
  await storage.delete('user_name');

  // Delete multiple keys
  await storage.deleteMultiple(['profile', 'favorites']);

  // Delete all
  await storage.deleteAll();
}

// ============ TODO REPOSITORY EXAMPLES ============

// --- CREATE TODO ---
Future<void> createTodoExample() async {
  final todoRepo = TodoRepository();

  bool success = await todoRepo.createTodo(
    'Buy groceries',
    'Milk, eggs, bread, vegetables',
  );

  if (success) {
    print('Todo created successfully');
  }
}

// --- READ TODOS ---
Future<void> readTodoExample() async {
  final todoRepo = TodoRepository();

  // Get all
  var todos = await todoRepo.getAllTodos();
  print('Total todos: ${todos.length}');

  // Get by ID
  var todo = await todoRepo.getTodoById('some-id');
  print('Todo: ${todo?.title}');

  // Get completed
  var completed = await todoRepo.getCompletedTodos();
  print('Completed: ${completed.length}');

  // Get incomplete
  var pending = await todoRepo.getIncompleteTodos();
  print('Pending: ${pending.length}');

  // Search
  var results = await todoRepo.searchTodos('groceries');
  print('Results: ${results.length}');
}

// --- UPDATE TODO ---
Future<void> updateTodoExample() async {
  final todoRepo = TodoRepository();

  // Toggle completion
  await todoRepo.toggleTodoCompletion('todo-id');

  // Update title
  await todoRepo.updateTodoTitle('todo-id', 'New Title');

  // Update description
  await todoRepo.updateTodoDescription('todo-id', 'New description');

  // Update full todo
  var todo = await todoRepo.getTodoById('todo-id');
  if (todo != null) {
    var updated = todo.copyWith(title: 'Updated Title');
    await todoRepo.updateTodo(updated);
  }
}

// --- DELETE TODO ---
Future<void> deleteTodoExample() async {
  final todoRepo = TodoRepository();

  // Delete single
  await todoRepo.deleteTodo('todo-id');

  // Delete multiple
  await todoRepo.deleteTodos(['id1', 'id2', 'id3']);

  // Delete all
  await todoRepo.deleteAllTodos();
}

// --- TODO STATISTICS ---
Future<void> todoStatsExample() async {
  final todoRepo = TodoRepository();

  int total = await todoRepo.getTotalTodos();
  int completed = await todoRepo.getCompletedCount();
  int incomplete = await todoRepo.getIncompleteCount();

  print('Total: $total, Completed: $completed, Pending: $incomplete');
}

// ============ UTILITY EXAMPLES ============

Future<void> utilityExamples() async {
  final storage = LocalStorageService();

  // Check key exists
  bool exists = storage.containsKey('user_name');
  print('Key exists: $exists');

  // Get all keys
  Set<String> keys = storage.getAllKeys();
  print('All keys: $keys');

  // Get storage size
  int size = storage.getStorageSize();
  print('Storage items: $size');

  // Debug print all
  storage.debugPrintAll();
}

// ============ USING IN STATEFUL WIDGET ============

import 'package:flutter/material.dart';
import '../services/todo_repository.dart';
import '../models/todo_model.dart';

class ExampleTodoWidget extends StatefulWidget {
  @override
  State<ExampleTodoWidget> createState() => _ExampleTodoWidgetState();
}

class _ExampleTodoWidgetState extends State<ExampleTodoWidget> {
  final TodoRepository _todoRepository = TodoRepository();
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    var todos = await _todoRepository.getAllTodos();
    setState(() {
      // Update UI with todos
    });
  }

  Future<void> _addTodo() async {
    if (_titleController.text.isEmpty) return;

    bool success = await _todoRepository.createTodo(_titleController.text, '');

    if (success) {
      _titleController.clear();
      _loadTodos();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Todo added')),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todo')),
      body: const Center(child: Text('TODO_LIST')),
    );
  }
}

// ============ USING WITH FUTURE BUILDER ============

class TodoListWidget extends StatelessWidget {
  final TodoRepository _todoRepository = TodoRepository();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TodoModel>>(
      future: _todoRepository.getAllTodos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final todos = snapshot.data ?? [];

        if (todos.isEmpty) {
          return const Center(child: Text('No todos yet'));
        }

        return ListView.builder(
          itemCount: todos.length,
          itemBuilder: (context, index) {
            final todo = todos[index];
            return ListTile(
              title: Text(todo.title),
              subtitle: Text(todo.description),
              trailing: Checkbox(
                value: todo.isCompleted,
                onChanged: (_) async {
                  await _todoRepository.toggleTodoCompletion(todo.id);
                  // Refresh UI
                },
              ),
            );
          },
        );
      },
    );
  }
}

// ============ EXPORT/IMPORT DATA ============

Future<void> exportData() async {
  final todoRepo = TodoRepository();

  // Export all todos as JSON
  List<Map<String, dynamic>> exported = await todoRepo.exportTodos();
  print('Exported: $exported');
}

// ============ ADVANCED: CUSTOM STORAGE ============

class UserPreferences {
  static final UserPreferences _instance = UserPreferences._internal();
  final LocalStorageService _storage = LocalStorageService();

  factory UserPreferences() {
    return _instance;
  }

  UserPreferences._internal();

  // Saved preferences keys
  static const String _userNameKey = 'user_name';
  static const String _themeKey = 'theme';
  static const String _languageKey = 'language';

  // Save user name
  Future<bool> setUserName(String name) {
    return _storage.saveString(_userNameKey, name);
  }

  // Get user name
  String? getUserName() {
    return _storage.getString(_userNameKey);
  }

  // Save theme
  Future<bool> setTheme(String theme) {
    return _storage.saveString(_themeKey, theme);
  }

  // Get theme
  String getTheme() {
    return _storage.getString(_themeKey, defaultValue: 'light') ?? 'light';
  }

  // Save language
  Future<bool> setLanguage(String lang) {
    return _storage.saveString(_languageKey, lang);
  }

  // Get language
  String getLanguage() {
    return _storage.getString(_languageKey, defaultValue: 'id') ?? 'id';
  }

  // Clear preferences
  Future<bool> clearPreferences() {
    return _storage.deleteMultiple([_userNameKey, _themeKey, _languageKey]);
  }
}

// Usage:
// UserPreferences prefs = UserPreferences();
// await prefs.setUserName('John');
// String? name = prefs.getUserName();

*/
