import 'package:uuid/uuid.dart';
import '../models/todo_model.dart';
import 'local_storage_service.dart';

/// Repository untuk mengelola Todo dengan Local Storage
class TodoRepository {
  static final TodoRepository _instance = TodoRepository._internal();
  final LocalStorageService _storage = LocalStorageService();

  static const String _todosKey = 'todos';

  factory TodoRepository() {
    return _instance;
  }

  TodoRepository._internal();

  // ==================== CREATE ====================

  /// Menambah todo baru
  Future<bool> createTodo(String title, String description) async {
    try {
      const uuid = Uuid();
      final newTodo = TodoModel(
        id: uuid.v4(),
        title: title,
        description: description,
        createdAt: DateTime.now(),
      );

      List<TodoModel> todos = await getAllTodos();
      todos.add(newTodo);

      List<Map<String, dynamic>> jsonList = todos
          .map((todo) => todo.toJson())
          .toList();
      return await _storage.saveObjectList(_todosKey, jsonList);
    } catch (e) {
      print('Error creating todo: $e');
      return false;
    }
  }

  // ==================== READ ====================

  /// Mendapatkan semua todo
  Future<List<TodoModel>> getAllTodos() async {
    try {
      List<Map<String, dynamic>>? jsonList = _storage.getObjectList(_todosKey);

      if (jsonList == null || jsonList.isEmpty) {
        return [];
      }

      return jsonList.map((json) => TodoModel.fromJson(json)).toList();
    } catch (e) {
      print('Error getting all todos: $e');
      return [];
    }
  }

  /// Mendapatkan todo berdasarkan id
  Future<TodoModel?> getTodoById(String id) async {
    try {
      List<TodoModel> todos = await getAllTodos();
      return todos.firstWhere((todo) => todo.id == id);
    } catch (e) {
      print('Error getting todo by id: $e');
      return null;
    }
  }

  /// Mendapatkan todo yang completed
  Future<List<TodoModel>> getCompletedTodos() async {
    try {
      List<TodoModel> todos = await getAllTodos();
      return todos.where((todo) => todo.isCompleted).toList();
    } catch (e) {
      print('Error getting completed todos: $e');
      return [];
    }
  }

  /// Mendapatkan todo yang belum completed
  Future<List<TodoModel>> getIncompleteTodos() async {
    try {
      List<TodoModel> todos = await getAllTodos();
      return todos.where((todo) => !todo.isCompleted).toList();
    } catch (e) {
      print('Error getting incomplete todos: $e');
      return [];
    }
  }

  /// Cari todo berdasarkan title
  Future<List<TodoModel>> searchTodos(String query) async {
    try {
      List<TodoModel> todos = await getAllTodos();
      return todos
          .where(
            (todo) =>
                todo.title.toLowerCase().contains(query.toLowerCase()) ||
                todo.description.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    } catch (e) {
      print('Error searching todos: $e');
      return [];
    }
  }

  // ==================== UPDATE ====================

  /// Update todo
  Future<bool> updateTodo(TodoModel updatedTodo) async {
    try {
      List<TodoModel> todos = await getAllTodos();
      int index = todos.indexWhere((todo) => todo.id == updatedTodo.id);

      if (index == -1) {
        print('Todo not found');
        return false;
      }

      final todoWithTimestamp = updatedTodo.copyWith(updatedAt: DateTime.now());
      todos[index] = todoWithTimestamp;

      List<Map<String, dynamic>> jsonList = todos
          .map((todo) => todo.toJson())
          .toList();
      return await _storage.saveObjectList(_todosKey, jsonList);
    } catch (e) {
      print('Error updating todo: $e');
      return false;
    }
  }

  /// Update title
  Future<bool> updateTodoTitle(String id, String newTitle) async {
    try {
      TodoModel? todo = await getTodoById(id);
      if (todo == null) return false;

      TodoModel updatedTodo = todo.copyWith(title: newTitle);
      return await updateTodo(updatedTodo);
    } catch (e) {
      print('Error updating todo title: $e');
      return false;
    }
  }

  /// Update description
  Future<bool> updateTodoDescription(String id, String newDescription) async {
    try {
      TodoModel? todo = await getTodoById(id);
      if (todo == null) return false;

      TodoModel updatedTodo = todo.copyWith(description: newDescription);
      return await updateTodo(updatedTodo);
    } catch (e) {
      print('Error updating todo description: $e');
      return false;
    }
  }

  /// Toggle completed status
  Future<bool> toggleTodoCompletion(String id) async {
    try {
      TodoModel? todo = await getTodoById(id);
      if (todo == null) return false;

      TodoModel updatedTodo = todo.copyWith(isCompleted: !todo.isCompleted);
      return await updateTodo(updatedTodo);
    } catch (e) {
      print('Error toggling todo completion: $e');
      return false;
    }
  }

  // ==================== DELETE ====================

  /// Menghapus todo berdasarkan id
  Future<bool> deleteTodo(String id) async {
    try {
      List<TodoModel> todos = await getAllTodos();
      todos.removeWhere((todo) => todo.id == id);

      if (todos.isEmpty) {
        return await _storage.delete(_todosKey);
      }

      List<Map<String, dynamic>> jsonList = todos
          .map((todo) => todo.toJson())
          .toList();
      return await _storage.saveObjectList(_todosKey, jsonList);
    } catch (e) {
      print('Error deleting todo: $e');
      return false;
    }
  }

  /// Menghapus multiple todos
  Future<bool> deleteTodos(List<String> ids) async {
    try {
      List<TodoModel> todos = await getAllTodos();
      todos.removeWhere((todo) => ids.contains(todo.id));

      if (todos.isEmpty) {
        return await _storage.delete(_todosKey);
      }

      List<Map<String, dynamic>> jsonList = todos
          .map((todo) => todo.toJson())
          .toList();
      return await _storage.saveObjectList(_todosKey, jsonList);
    } catch (e) {
      print('Error deleting todos: $e');
      return false;
    }
  }

  /// Menghapus semua todo
  Future<bool> deleteAllTodos() async {
    try {
      return await _storage.delete(_todosKey);
    } catch (e) {
      print('Error deleting all todos: $e');
      return false;
    }
  }

  // ==================== UTILITY ====================

  /// Dapatkan total todo
  Future<int> getTotalTodos() async {
    try {
      List<TodoModel> todos = await getAllTodos();
      return todos.length;
    } catch (e) {
      print('Error getting total todos: $e');
      return 0;
    }
  }

  /// Dapatkan jumlah todo yang completed
  Future<int> getCompletedCount() async {
    try {
      List<TodoModel> todos = await getCompletedTodos();
      return todos.length;
    } catch (e) {
      print('Error getting completed count: $e');
      return 0;
    }
  }

  /// Dapatkan jumlah todo yang incomplete
  Future<int> getIncompleteCount() async {
    try {
      List<TodoModel> todos = await getIncompleteTodos();
      return todos.length;
    } catch (e) {
      print('Error getting incomplete count: $e');
      return 0;
    }
  }

  /// Export semua todo sebagai JSON
  Future<List<Map<String, dynamic>>> exportTodos() async {
    try {
      List<TodoModel> todos = await getAllTodos();
      return todos.map((todo) => todo.toJson()).toList();
    } catch (e) {
      print('Error exporting todos: $e');
      return [];
    }
  }
}
