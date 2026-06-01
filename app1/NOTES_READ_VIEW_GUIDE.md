# Notes Read View - Complete Reading Experience

## Overview

`NotesReadView` adalah screen khusus yang dioptimalkan untuk membaca dan menjelajahi semua notes dengan fitur lengkap.

Ini adalah views dedicated untuk **READ operations** yang berbeda dari `NotesStreamScreen` yang fokus pada **CREATE & MANAGE operations**.

---

## Features

### 1. **Display Modes**

- **List View** - Default view, menampilkan notes dalam format list dengan preview
- **Grid View** - 2-column grid layout, lebih visual dan compact

Toggle dengan icon grid/list di appbar.

### 2. **Sorting Options**

- **Newest First** (Default) - Catatan terbaru di atas
- **Oldest First** - Catatan paling lama di atas
- **Title A-Z** - Sorted berdasarkan title alphabet

Akses via dropdown menu di appbar.

### 3. **Filtering**

- **Search** - Real-time search di title dan content
- **Category Filter** - Filter by catatan category
- **Pinned Filter** - Show only pinned notes atau all

### 4. **Note Details**

- Tap any note untuk lihat detail lengkap dalam dialog
- Dialog menampilkan:
  - Full title dan content
  - Category (jika ada)
  - Created/Updated dates
  - Pin status indicator
  - Action buttons (Pin/Archive/Delete)

### 5. **Quick Actions**

- **Pin/Unpin** - Dari detail dialog
- **Archive/Unarchive** - Dari detail dialog
- **Delete** - Dengan confirmation dialog

### 6. **Visual Enhancements**

- Note cards dengan info preview
- Category badges dengan warna
- Pin icons untuk pinned notes
- Date formatting (Today, Yesterday, atau date)
- Empty state dengan icon

---

## Code Structure

```dart
class NotesReadView extends StatefulWidget {
  // UI untuk membaca semua notes
}

class _NotesReadViewState extends State<NotesReadView> {
  final NotesStreamService _notesService;

  // State variables
  String _searchQuery = '';
  int _sortBy = 0;          // 0:newest, 1:oldest, 2:title
  int _viewMode = 0;        // 0:list, 1:grid
  bool _showOnlyPinned = false;
  String _filterCategory = 'All';

  // Methods
  _initializeService()      // Load service
  _sortNotes()              // Apply sorting
  _filterNotes()            // Apply filters
  _showNoteDetail()         // Show note dialog
  _togglePin()              // Toggle pin status
  _toggleArchive()          // Toggle archive status
  _deleteNote()             // Delete with confirmation
  _formatDate()             // Format datetime display
  _buildListView()          // Render list view
  _buildGridView()          // Render grid view
  _buildNoteCard()          // Single note card widget
  _buildCategoryFilter()    // Category filter chips
}
```

---

## Usage

### Add to Navigation

```dart
// In HomeScreen or navigation menu
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NotesReadView(),
      ),
    );
  },
  child: const Text('Read All Notes'),
)

// Or with go_router
// context.go('/notes-read');
```

### Integrate in Routes

```dart
// In app_router.dart
GoRoute(
  path: '/notes-read',
  name: 'notesRead',
  builder: (context, state) => const NotesReadView(),
),
```

### Add to AppBar Menu

```dart
// In main screen appbar
PopupMenuButton(
  itemBuilder: (context) => [
    PopupMenuItem(
      child: const Text('Read Notes'),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const NotesReadView(),
        ),
      ),
    ),
  ],
),
```

---

## User Interactions

### Search Notes

1. Tap search bar di atas list
2. Type keywords (title atau content)
3. Hasil update real-time
4. Tap X untuk clear search

### Filter by Category

1. Swipe atau scroll category chips
2. Tap category chip untuk filter
3. "All" shows semua catatan
4. Category terupdate saat ada catatan baru

### Change View Mode

1. Tap grid/list icon di appbar
2. List view (default) - full width dengan preview
3. Grid view (2-column) - compact layout

### Sort Notes

1. Tap sort menu (3 dots) di appbar
2. Pilih sort option:
   - Newest First
   - Oldest First
   - Title A-Z

### Filter Pinned Only

1. Tap pin icon di appbar
2. Icon berubah warna (orange = active)
3. Shows hanya pinned notes

### View Note Details

1. Tap any note card
2. Dialog muncul dengan:
   - Full title dan content
   - Date info
   - Action buttons
3. Tap action button untuk pin/archive/delete
4. Tap "Close" untuk tutup dialog

### Pin/Archive/Delete from Detail

1. Open note detail dialog
2. Tap "Pin" button untuk toggle
3. Tap "Archive" untuk archive/unarchive
4. Tap "Delete" untuk delete dengan confirmation
5. Dialog tutup otomatis setelah action

---

## Display Details

### List View Layout

```
┌─────────────────────────────┐
│ Note Title (bold)      📌   │ ← Pin indicator
├─────────────────────────────┤
│ Note content preview...     │
│ ...more content preview...  │
├─────────────────────────────┤
│ Category       Today 14:30   │ ← Date
└─────────────────────────────┘
```

### Grid View Layout

```
┌──────────────┬──────────────┐
│ Title   📌   │ Title        │
├──────────────┼──────────────┤
│ Content      │ Content      │
│ preview...   │ preview...   │
│              │              │
│ [Category]   │ [Category]   │
└──────────────┴──────────────┘
```

---

## Detail Dialog Layout

```
┌─────────────────────────────────┐
│ Note Title                      │
├─────────────────────────────────┤
│ Category: Work                  │
│                                 │
│ Full note content is displayed  │
│ here with no character limit.   │
│ User can read everything.       │
│                                 │
│ Created: 15/01/2024       📌    │
│ Updated: 15/01/2024             │
├─────────────────────────────────┤
│ [Pin] [Archive] [Delete] [Close]│
└─────────────────────────────────┘
```

---

## Stream Integration

### Primary Stream: getAllNotesStream()

```dart
StreamBuilder<List<NoteModel>>(
  stream: _notesService.getAllNotesStream(),
  builder: (context, snapshot) {
    // Receives data updates automatically
    // Updates when any note is created/updated/deleted
    // Rebuilds UI with new data
  },
)
```

### Category Filter Stream: getCategoriesStream()

```dart
StreamBuilder<List<NoteCategoryModel>>(
  stream: _notesService.getCategoriesStream(),
  builder: (context, snapshot) {
    // Builds category filter chips
    // Updates when new category added
  },
)
```

---

## Sorting Logic

### Newest First (Default)

```dart
notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
// Later dates first
```

### Oldest First

```dart
notes.sort((a, b) => a.createdAt.compareTo(b.createdAt));
// Earlier dates first
```

### Title A-Z

```dart
notes.sort((a, b) => a.title.compareTo(b.title));
// Alphabetical by title
```

---

## Filtering Logic

### Search Filter

```dart
final matchesSearch = _searchQuery.isEmpty ||
  note.title.toLowerCase().contains(_searchQuery) ||
  note.content.toLowerCase().contains(_searchQuery);
```

### Category Filter

```dart
final matchesCategory = _filterCategory == 'All' ||
  note.category == _filterCategory;
```

### Pinned Filter

```dart
final matchesPinned = !_showOnlyPinned || note.isPinned;
```

---

## Date Formatting

```
Today [hour]:[minute]
  ↓ Shows "Today 14:30"

Yesterday [hour]:[minute]
  ↓ Shows "Yesterday 10:15"

Other dates: [day]/[month]/[year]
  ↓ Shows "15/01/2024"
```

---

## Methods Reference

### Dialog & Actions

```dart
_showNoteDetail(NoteModel note)
  // Tampilkan note detail dalam AlertDialog
  // User dapat melihat semua info dan perform actions

_togglePin(String noteId)
  // Ubah pin status
  // Show snackbar feedback

_toggleArchive(String noteId)
  // Ubah archive status
  // Show snackbar feedback

_deleteNote(String noteId)
  // Hapus dengan confirmation dialog
  // Soft delete (sets deletedAt)
```

### Data Processing

```dart
_filterNotes(List<NoteModel> notes)
  // Apply search, category, dan pinned filters
  // Return filtered list

_sortNotes(List<NoteModel> notes)
  // Apply sorting option
  // Return sorted list

_formatDate(DateTime date)
  // Convert DateTime ke user-friendly format
  // "Today", "Yesterday", atau date string
```

### UI Building

```dart
_buildListView(List<NoteModel> notes)
  // Render ListView dengan note cards
  // Handle empty state

_buildGridView(List<NoteModel> notes)
  // Render GridView 2-column
  // Handle empty state

_buildNoteCard(NoteModel note)
  // Single card widget untuk one note
  // Tap untuk open detail

_buildCategoryFilter()
  // Build category filter chips
  // Consume getCategoriesStream()
```

---

## State Management

### Mutable State

```dart
String _searchQuery = '';          // Changed by search input
int _sortBy = 0;                  // Changed by sort menu
int _viewMode = 0;                // Changed by view toggle
bool _showOnlyPinned = false;      // Changed by pin filter
String _filterCategory = 'All';    // Changed by category chip
```

All changes trigger `setState()` untuk rebuild UI.

### Immutable State

```dart
final NotesStreamService _notesService;
final TextEditingController _searchController;
```

Initialized in `initState()` dan disposed di `dispose()`.

---

## Error Handling

### Stream Error

```dart
if (snapshot.hasError) {
  return Center(
    child: Column(
      children: [
        Icon(Icons.error_outline),
        Text('Error: ${snapshot.error}'),
      ],
    ),
  );
}
```

### Empty State

```dart
if (notes.isEmpty) {
  return Center(
    child: Column(
      children: [
        Icon(Icons.note_outlined),
        Text('No notes found'),
      ],
    ),
  );
}
```

### Confirmation Dialog

```dart
// Before delete
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('Delete Note?'),
    content: const Text('Catatan akan dihapus. Lanjutkan?'),
    // ...
  ),
);
```

---

## Performance Tips

1. **StreamBuilder** immediately rebuilds when data changes
2. **Filters** applied in-memory (fast for ~100-1000 notes)
3. **Sorting** done on each filter (could cache if slow)
4. **lazy loading** untuk grid view dengan many images (future enhancement)

---

## Integration Checklist

- [ ] Copy `notes_read_view.dart` to `lib/screens/`
- [ ] Ensure `NotesStreamService` is available
- [ ] Add import: `import '../screens/notes_read_view.dart';`
- [ ] Add route to app router atau navigator
- [ ] Test navigation to NotesReadView
- [ ] Verify all features work (sort, filter, search)
- [ ] Test CRUD actions from detail dialog

---

## Comparison: NotesStreamScreen vs NotesReadView

| Feature                | NotesStreamScreen      | NotesReadView        |
| ---------------------- | ---------------------- | -------------------- |
| **Purpose**            | Create & Manage        | Read & Browse        |
| **Create Form**        | ✅ Yes                 | ❌ No                |
| **Tab View**           | ✅ All/Pinned/Archived | ❌ Separate screen   |
| **Sorting**            | ❌ No                  | ✅ Yes (3 types)     |
| **Grid View**          | ❌ Only list           | ✅ List + Grid       |
| **Category Filter**    | ❌ No                  | ✅ Yes               |
| **Search**             | ✅ Yes                 | ✅ Yes               |
| **Detail Dialog**      | ❌ Basic               | ✅ Rich with actions |
| **Pin/Archive/Delete** | ✅ Yes                 | ✅ Yes               |

**Recommendation:**

- Use **NotesStreamScreen** untuk create/manage notes
- Use **NotesReadView** untuk browse/read notes
- Both screens feed from same `getAllNotesStream()`

---

## Customization Ideas

1. **Color Themes** - Add dark mode support
2. **Custom Sorting** - Add "by category" sort option
3. **Multi-Select** - Select multiple notes for bulk delete
4. **Share Notes** - Add share button in detail dialog
5. **Export** - Export selected notes as JSON/PDF
6. **Search History** - Remember previous searches
7. **Favorites** - Alternative to pinned
8. **Labels** - Multi-tag system instead of single category
9. **Rich Text** - Support formatted content display
10. **Images** - Thumbnail support untuk note dengan images

---

## Files Reference

**Created:**

- `lib/screens/notes_read_view.dart` - The main screen

**Dependencies:**

- `lib/models/note_model.dart` - NoteModel structure
- `lib/services/notes_stream_service.dart` - Stream provider

**Related Screens:**

- `lib/screens/notes_stream_screen.dart` - Create & Manage screen

---

## API Methods Used

From `NotesStreamService`:

```dart
init()                    // Initialize service
dispose()                 // Cleanup
getAllNotesStream()       // Get notes stream
getCategoriesStream()     // Get categories stream
togglePinStatus(id)       // Pin/unpin note
toggleArchiveStatus(id)   // Archive/unarchive note
deleteNote(id)            // Soft delete note
```

---

## Complete Example Integration

```dart
// In main app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize if needed
  // NotesStreamService handles init internally

  runApp(const MyApp());
}

// In HomeScreen
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.note),
              label: const Text('Browse All Notes'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotesReadView(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

---

**Status:** ✅ Complete & Ready to Use

**Version:** 1.0

**Next Steps:**

1. Copy file to your project
2. Add route to AppRouter
3. Test all features
4. Customize styling if needed
