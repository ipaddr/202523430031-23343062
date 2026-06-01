/*
# QUICK REFERENCE - NOTES READ VIEW

Cheat sheet untuk NotesReadView integration dan usage

## NAVIGATION

// Push to NotesReadView
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const NotesReadView(),
  ),
);

// Or with go_router
context.go('/notes-read');

// Via button
ElevatedButton(
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const NotesReadView()),
  ),
  child: const Text('Read Notes'),
)


## ROUTE SETUP (go_router)

GoRoute(
  path: '/notes-read',
  name: 'notesRead',
  builder: (context, state) => const NotesReadView(),
),


## DRAWER NAVIGATION

ListTile(
  leading: const Icon(Icons.note),
  title: const Text('Read Notes'),
  onTap: () {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NotesReadView(),
      ),
    );
  },
),


## FEATURES

View Modes:
  - List View (default) - Full width notes
  - Grid View (2-column) - Compact cards

Sorting Options:
  - Newest First (default)
  - Oldest First
  - Title A-Z

Filtering:
  - Search (title & content)
  - Category filter
  - Show pinned only

Actions:
  - Tap note → open detail dialog
  - Pin/Unpin from dialog
  - Archive/Unarchive from dialog
  - Delete with confirmation


## STATE VARIABLES

_searchQuery        // Search input
_sortBy             // 0:newest, 1:oldest, 2:title
_viewMode           // 0:list, 1:grid
_showOnlyPinned     // true/false
_filterCategory     // 'All' or category name


## SORTING METHODS

_sortNotes() returns sorted list
  - By createdAt descending (newest first)
  - By createdAt ascending (oldest first)
  - By title alphabetically


## FILTERING LOGIC

_filterNotes() applies:
  - Search query (ignores case)
  - Category filter
  - Pinned filter

Multiple filters combined with AND logic


## KEY METHODS

// Initialize service and widgets
_initializeService() async

// Show note detail dialog
_showNoteDetail(NoteModel note) async

// Toggle pin status
_togglePin(String noteId) async

// Toggle archive status
_toggleArchive(String noteId) async

// Delete note with confirmation
_deleteNote(String noteId) async

// Format date for display
_formatDate(DateTime date) -> String

// Build list view
_buildListView(List<NoteModel> notes) -> Widget

// Build grid view
_buildGridView(List<NoteModel> notes) -> Widget

// Build single note card
_buildNoteCard(NoteModel note) -> Widget

// Build category filter chips
_buildCategoryFilter() -> Widget


## STREAM INTEGRATION

// Get notes stream
StreamBuilder<List<NoteModel>>(
  stream: _notesService.getAllNotesStream(),
  builder: (context, snapshot) {
    if (snapshot.hasError) return ErrorWidget();
    if (!snapshot.hasData) return LoadingWidget();
    
    final notes = snapshot.data ?? [];
    // Process and display
  },
)

// Get categories for filtering
StreamBuilder<List<NoteCategoryModel>>(
  stream: _notesService.getCategoriesStream(),
  builder: (context, snapshot) {
    final categories = snapshot.data ?? [];
    // Build category filters
  },
)


## UI FLOW

1. AppBar
   - Title: "All Notes"
   - Actions: Sort, View Mode, Pin Filter

2. Search Bar
   - TextField with search icon
   - Real-time filtering

3. Category Filter
   - Horizontal chip list
   - "All" + category names
   - Scroll for more

4. Content Area
   - List or Grid view
   - StreamBuilder for notes
   - Note cards with preview

5. Detail Dialog (on tap)
   - Full title and content
   - Category badge
   - Dates (created/updated)
   - Action buttons


## APPBAR ACTIONS

Sort Menu (3 dots):
  └─ Newest First
  └─ Oldest First
  └─ Title (A-Z)

View Toggle:
  └─ List icon (show list view)
  └─ Grid icon (show grid view)

Pin Filter:
  └─ Toggle pinned-only filter
  └─ Icon color changes when active


## NOTE CARD (LIST VIEW)

┌────────────────────────────┐
│ Title (bold)         📌    │
├────────────────────────────┤
│ Content preview (2 lines)  │
├────────────────────────────┤
│ [Category]    Date         │
└────────────────────────────┘

Click → Open detail dialog


## NOTE CARD (GRID VIEW)

┌─────────────┐
│ Title  📌   │
│             │
│ Content     │
│ (3 lines)   │
│             │
│ [Category]  │
└─────────────┘

Click → Open detail dialog


## DETAIL DIALOG

Title: Note Title
Content:
  - Category: [name]
  - Full content
  - Created: [date]
  - Updated: [date]
  - Pin indicator

Buttons:
  [Pin] [Archive] [Delete] [Close]


## KEYBOARD SHORTCUTS (Possible Enhancement)

Ctrl+F   → Focus search
Ctrl+A   → Select all results
Escape   → Close dialog
Delete   → Delete selected


## ERROR HANDLING

Search Error:
  - Show error icon
  - Display error message
  - Suggest retry

Load Error:
  - Show error icon in center
  - "Error: [message]"

Empty State:
  - Show note icon
  - "No notes found"


## PERFORMANCE

Typical performance:
  - < 100 notes: instant
  - 100-1000 notes: < 500ms
  - 1000+ notes: consider backend search

Optimization tips:
  - Use const constructors
  - Filter at stream level if possible
  - Lazy load images (future)


## DATE FORMATTING EXAMPLES

Today 14:30      → DateTime.now()
Yesterday 10:15  → DateTime.now() - 1 day
15/01/2024       → Older dates


## CATEGORY FILTER

Default: "All" shows all notes

Select category: Shows only that category

Categories come from:
  - getAllNotesStream() via category field
  - getCategoriesStream() via CategoryModel

Add category in NotesStreamScreen
  → Automatically appears in filter


## OPERATIONS FROM DETAIL DIALOG

Pin:
  await notesService.togglePinStatus(noteId)
  → Icon updates
  → Stream broadcasts change

Archive:
  await notesService.toggleArchiveStatus(noteId)
  → Dialog closes
  → Note disappears from view

Delete:
  Show confirmation
  await notesService.deleteNote(noteId)
  → Note disappears
  → Soft delete (not permanent)


## COMPLETE EXAMPLE - HOME SCREEN

import 'package:flutter/material.dart';
import 'screens/notes_read_view.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.note_outlined),
          label: const Text('View All Notes'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const NotesReadView(),
              ),
            );
          },
        ),
      ),
    );
  }
}


## INTEGRATION CHECKLIST

✓ Copy notes_read_view.dart to lib/screens/
✓ Import in home screen: import 'screens/notes_read_view.dart';
✓ Add navigation button or route
✓ Test opening NotesReadView
✓ Test search (type in search bar)
✓ Test sort (click sort menu)
✓ Test view mode (click grid/list toggle)
✓ Test category filter (tap category chip)
✓ Test pin filter (click pin icon)
✓ Test note detail (tap any note)
✓ Test actions in dialog (pin/archive/delete)
✓ Check that changes reflect in UI


## DEPENDENCIES

Already included in project:
  - flutter/material.dart
  - models/note_model.dart
  - services/notes_stream_service.dart

Optional enhancements:
  - rxdart: advanced stream operations
  - intl: better date formatting
  - cached_network_image: image caching


## TROUBLESHOOTING

Issue: Notes not showing
  Fix: Ensure getAllNotesStream() working
  Fix: Check NotesStreamService initialized

Issue: Search not working
  Fix: Verify onChanged updates _searchQuery
  Fix: Check _filterNotes() logic

Issue: Categories not loading
  Fix: Ensure categories added via NotesStreamScreen
  Fix: Check getCategoriesStream() working

Issue: Memory leak
  Fix: dispose() called in _NotesReadViewState.dispose()
  Fix: TextEditingController disposed properly

Issue: Sorting not changing
  Fix: Check _sortBy value updates
  Fix: Verify _sortNotes() called after setState()


## COMPARISON WITH NOTES STREAM SCREEN

NotesReadView = Read & Browse
  → Optimized for viewing
  → Sorting, filtering
  → Grid view support
  → Rich detail dialog
  → NO create form

NotesStreamScreen = Create & Manage
  → Create new notes
  → Quick manage
  → Tabs (all/pinned/archived)
  → Inline actions
  → NO sorting/grid view

Use both for complete application!


## FUTURE ENHANCEMENTS

1. Add "Favorites" toggle
2. Add bulk selection (select multiple)
3. Add bulk delete
4. Add note preview (read-only mode)
5. Add export (JSON/PDF)
6. Add search history
7. Add custom colors per category
8. Add rich text display
9. Add image thumbnails
10. Add note duration/reading time estimate


## STYLING CUSTOMIZATION

Colors:
  - Blue for category badges
  - Orange for pin icon
  - Grey for dates
  - Red for delete button

Dimensions:
  - Card padding: 12
  - List spacing: 8
  - Search bar margin: 12
  - Grid cross spacing: 8

Fonts:
  - Title: bold, 16
  - Content: regular, 14
  - Category: regular, 12
  - Date: regular, 12


## API SUMMARY

NotesStreamService usage in NotesReadView:

init()                    // Initialize on build
dispose()                 // Cleanup on destroy
getAllNotesStream()       // Get all notes
getCategoriesStream()     // Get categories
togglePinStatus(id)       // Pin/unpin
toggleArchiveStatus(id)   // Archive/unarchive
deleteNote(id)            // Soft delete


## LIFECYCLE

initState()
  └─ Create TextEditingController
  └─ Call _initializeService()

build()
  └─ Build AppBar with actions
  └─ Build search bar
  └─ Build category filter
  └─ Build StreamBuilder for notes
  └─ Apply filters and sorting
  └─ Build list or grid view

dispose()
  └─ Dispose TextEditingController
  └─ Dispose NotesStreamService
  └─ Call super.dispose()


## QUICK TIPS

1. Search is case-insensitive
2. Filters combine with AND logic
3. Sorting done after filtering
4. View mode persists in state
5. Sort preference persists in state
6. Category filter resets on screen exit
7. All changes instant (stream-driven)
8. Detail dialog modal (blocks interaction below)
9. Confirmation dialogs required for destructive ops
10. Snackbars show action feedback


## TESTING

Manual tests:
  ✓ Create notes in NotesStreamScreen
  ✓ See notes in NotesReadView
  ✓ Search for specific note
  ✓ Filter by category
  ✓ Sort by different options
  ✓ Switch between list/grid
  ✓ Toggle pin filter
  ✓ Open detail dialog
  ✓ Pin/archive/delete from detail
  ✓ Verify changes reflected immediately


## SUPPORT

Documentation: NOTES_READ_VIEW_GUIDE.md
Code Reference: This file (QUICK_REFERENCE_NOTES_READ_VIEW.dart)
Related: NotesStreamScreen for create/manage

*/
