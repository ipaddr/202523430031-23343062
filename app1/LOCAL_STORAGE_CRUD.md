# CRUD Local Storage Documentation

## Overview

Dokumentasi lengkap untuk implementasi CRUD Local Storage di Flutter menggunakan `shared_preferences`.

## File yang Dibuat

### 1. **local_storage_service.dart**

Service utama untuk semua operasi Local Storage.

#### Features:

- **CREATE**: saveString, saveInt, saveDouble, saveBool, saveStringList, saveObject, saveObjectList
- **READ**: getString, getInt, getDouble, getBool, getStringList, getObject, getObjectList
- **UPDATE**: updateString, updateInt, updateDouble, updateBool, updateObject, updateObjectList
- **DELETE**: delete, deleteAll, deleteMultiple
- **UTILITY**: containsKey, getAllKeys, getStorageSize, debugPrintAll

---

## Usage Examples

### 1. Initialize Storage

```dart
import 'services/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage
  final storage = LocalStorageService();
  await storage.init();

  runApp(const MyApp());
}
```

### 2. Save Data (CREATE)

```dart
final storage = LocalStorageService();

// Save string
await storage.saveString('username', 'John Doe');

// Save int
await storage.saveInt('user_id', 123);

// Save boolean
await storage.saveBool('is_logged_in', true);

// Save object (Map)
final user = {
  'name': 'John',
  'email': 'john@example.com',
  'age': 25
};
await storage.saveObject('user_data', user);

// Save list of objects
final users = [
  {'name': 'John', 'age': 25},
  {'name': 'Jane', 'age': 28},
];
await storage.saveObjectList('users', users);
```

### 3. Read Data (READ)

```dart
final storage = LocalStorageService();

// Read string
String username = storage.getString('username', defaultValue: '');

// Read int
int userId = storage.getInt('user_id', defaultValue: 0);

// Read boolean
bool isLoggedIn = storage.getBool('is_logged_in', defaultValue: false);

// Read object
Map<String, dynamic>? userData = storage.getObject('user_data');

// Read list of objects
List<Map<String, dynamic>>? users = storage.getObjectList('users');
```

### 4. Update Data (UPDATE)

```dart
final storage = LocalStorageService();

// Update string
await storage.updateString('username', 'Jane Doe');

// Update object
final updatedUser = {
  'name': 'Jane',
  'email': 'jane@example.com',
  'age': 28
};
await storage.updateObject('user_data', updatedUser);
```

### 5. Delete Data (DELETE)

```dart
final storage = LocalStorageService();

// Delete single key
await storage.delete('username');

// Delete multiple keys
await storage.deleteMultiple(['user_id', 'username']);

// Delete all data
await storage.deleteAll();
```

---

## Todo Repository Pattern

### Using TodoRepository for Complex Data

```dart
import 'services/todo_repository.dart';

final todoRepo = TodoRepository();

// CREATE - Add new todo
await todoRepo.createTodo('Buy groceries', 'Milk, eggs, bread');

// READ - Get all todos
List<TodoModel> todos = await todoRepo.getAllTodos();

// READ - Get single todo
TodoModel? todo = await todoRepo.getTodoById('todo-id');

// READ - Get completed todos
List<TodoModel> completedTodos = await todoRepo.getCompletedTodos();

// READ - Get incomplete todos
List<TodoModel> incompleteTodos = await todoRepo.getIncompleteTodos();

// READ - Search todos
List<TodoModel> results = await todoRepo.searchTodos('groceries');

// UPDATE - Update entire todo
TodoModel updatedTodo = todo!.copyWith(title: 'New Title');
await todoRepo.updateTodo(updatedTodo);

// UPDATE - Toggle completion
await todoRepo.toggleTodoCompletion('todo-id');

// UPDATE - Update title only
await todoRepo.updateTodoTitle('todo-id', 'New Title');

// DELETE - Delete single todo
await todoRepo.deleteTodo('todo-id');

// DELETE - Delete multiple todos
await todoRepo.deleteTodos(['id-1', 'id-2', 'id-3']);

// DELETE - Delete all todos
await todoRepo.deleteAllTodos();

// UTILITY - Get counts
int total = await todoRepo.getTotalTodos();
int completed = await todoRepo.getCompletedCount();
int incomplete = await todoRepo.getIncompleteCount();
```

---

## Complete Example - Todo Management Screen

See `local_storage_crud_screen.dart` for complete implementation with:

- Form input untuk create
- List view dengan update/delete
- Search functionality
- Statistics display
- Error handling

---

## Model Classes

### TodoModel

```dart
class TodoModel {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Methods:
  // - toJson()      : Convert to JSON
  // - fromJson()    : Create from JSON
  // - copyWith()    : Create copy with modified fields
}
```

---

## Best Practices

### 1. **Singleton Pattern**

```dart
// LocalStorageService dan TodoRepository menggunakan singleton pattern
final storage = LocalStorageService();  // Always returns same instance
final todoRepo = TodoRepository();       // Always returns same instance
```

### 2. **Error Handling**

```dart
try {
  await storage.saveString('key', 'value');
} catch (e) {
  print('Error: $e');
}
```

### 3. **Default Values**

```dart
// Selalu gunakan default value untuk safety
String value = storage.getString('key', defaultValue: 'default');
int count = storage.getInt('count', defaultValue: 0);
bool flag = storage.getBool('flag', defaultValue: false);
```

### 4. **Async/Await**

```dart
// Semua operasi adalah async
Future<void> loadData() async {
  List<TodoModel> todos = await _todoRepository.getAllTodos();
  // Use todos...
}
```

### 5. **Debug**

```dart
// Print semua data untuk debugging
_storage.debugPrintAll();

// Check key existence
bool exists = _storage.containsKey('username');

// Get all keys
Set<String> keys = _storage.getAllKeys();
```

---

## Data Types Supported

| Type                 | Methods                       | Example            |
| -------------------- | ----------------------------- | ------------------ |
| String               | saveString, getString         | `'Hello'`          |
| Int                  | saveInt, getInt               | `123`              |
| Double               | saveDouble, getDouble         | `3.14`             |
| Bool                 | saveBool, getBool             | `true`             |
| List<String>         | saveStringList, getStringList | `['a','b','c']`    |
| Map<String, dynamic> | saveObject, getObject         | `{'key': 'value'}` |
| List<Map>            | saveObjectList, getObjectList | `[{...}, {...}]`   |

---

## Integration with UI

### 1. **Using with StateManagement**

```dart
class TodoProvider extends ChangeNotifier {
  final TodoRepository _repo = TodoRepository();
  List<TodoModel> _todos = [];

  Future<void> loadTodos() async {
    _todos = await _repo.getAllTodos();
    notifyListeners();
  }

  Future<void> addTodo(String title, String desc) async {
    await _repo.createTodo(title, desc);
    await loadTodos();
  }
}
```

### 2. **Using with FutureBuilder**

```dart
FutureBuilder<List<TodoModel>>(
  future: _todoRepository.getAllTodos(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const LoadingWidget();
    }
    if (snapshot.hasError) {
      return ErrorWidget(error: snapshot.error.toString());
    }
    return ListView.builder(
      itemCount: snapshot.data?.length ?? 0,
      itemBuilder: (context, index) {
        final todo = snapshot.data![index];
        return TodoTile(todo: todo);
      },
    );
  },
)
```

---

## Troubleshooting

### 1. **Data Not Persisting**

- Ensure `init()` is called before using storage
- Check that `Future` is properly awaited

### 2. **JSON Serialization Issues**

- Make sure data types match expected format
- Use `fromJson()` factory constructor for models

### 3. **Accessing Before Init**

- Always call `await storage.init()` in `main()`
- Use `late` keyword for async initialization

---

## Dependencies Required

```yaml
dependencies:
  shared_preferences: ^2.2.2
  uuid: ^4.0.0
```

---

## File Structure

```
lib/
├── models/
│   └── todo_model.dart
├── screens/
│   └── local_storage_crud_screen.dart
├── services/
│   ├── local_storage_service.dart
│   └── todo_repository.dart
└── main.dart
```

---

## License

Free to use and modify for your project.
