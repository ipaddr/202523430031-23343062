import 'package:flutter/material.dart';
import '../services/note_sharing_service.dart';

class ShareNoteDialog extends StatefulWidget {
  final String noteId;
  final String noteTitle;

  const ShareNoteDialog({
    super.key,
    required this.noteId,
    required this.noteTitle,
  });

  @override
  State<ShareNoteDialog> createState() => _ShareNoteDialogState();
}

class _ShareNoteDialogState extends State<ShareNoteDialog> {
  final _sharingService = NoteSharingService();
  final _emailController = TextEditingController();
  String _selectedPermission = 'view';
  bool _isLoading = false;
  List<Map<String, dynamic>> _sharedUsers = [];

  @override
  void initState() {
    super.initState();
    _loadSharedUsers();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadSharedUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await _sharingService.getSharedWithUsers(widget.noteId);
      if (mounted) {
        setState(() => _sharedUsers = users);
      }
    } catch (e) {
      print('Error loading shared users: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _shareNote() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email tidak boleh kosong'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final success = await _sharingService.shareNoteWithUser(
        noteId: widget.noteId,
        recipientEmail: _emailController.text,
        permission: _selectedPermission,
      );

      if (success) {
        _emailController.clear();
        await _loadSharedUsers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Catatan berhasil di-share'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✗ Gagal share catatan'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _unshareNote(String recipientId) async {
    setState(() => _isLoading = true);
    try {
      final success = await _sharingService.unshareNoteWithUser(
        noteId: widget.noteId,
        recipientId: recipientId,
      );

      if (success) {
        await _loadSharedUsers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Sharing dihapus'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✗ Gagal hapus sharing'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updatePermission(
    String recipientId,
    String currentPermission,
  ) async {
    final newPermission = currentPermission == 'view' ? 'edit' : 'view';

    setState(() => _isLoading = true);
    try {
      final success = await _sharingService.updateSharePermission(
        noteId: widget.noteId,
        recipientId: recipientId,
        newPermission: newPermission,
      );

      if (success) {
        await _loadSharedUsers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✓ Permission diubah ke $newPermission'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Share Catatan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.noteTitle,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Share Form
                  const Text(
                    'Bagikan dengan:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),

                  // Email Input
                  TextField(
                    controller: _emailController,
                    enabled: !_isLoading,
                    decoration: InputDecoration(
                      hintText: 'Email pengguna',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Permission Selector
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Permission',
                              style: TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            DropdownButton<String>(
                              value: _selectedPermission,
                              isExpanded: true,
                              items: [
                                DropdownMenuItem(
                                  value: 'view',
                                  child: Row(
                                    children: const [
                                      Icon(
                                        Icons.visibility,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(width: 8),
                                      Text('View only'),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: const [
                                      Icon(
                                        Icons.edit,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(width: 8),
                                      Text('Can edit'),
                                    ],
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                setState(
                                  () => _selectedPermission = value ?? 'view',
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        height: 45,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _shareNote,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.share, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Divider
                  if (_sharedUsers.isNotEmpty)
                    Container(
                      height: 1,
                      color: Colors.grey[300],
                      margin: const EdgeInsets.symmetric(vertical: 12),
                    ),

                  // Shared Users List
                  if (_sharedUsers.isNotEmpty) ...[
                    const Text(
                      'Sudah di-share dengan:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _sharedUsers.length,
                      itemBuilder: (context, index) {
                        final user = _sharedUsers[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user['name'] ?? 'Unknown',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      user['email'] ?? '',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Permission badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: user['permission'] == 'view'
                                          ? Colors.blue[100]
                                          : Colors.orange[100],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: GestureDetector(
                                      onTap: _isLoading
                                          ? null
                                          : () => _updatePermission(
                                              user['id'],
                                              user['permission'],
                                            ),
                                      child: Text(
                                        user['permission'] == 'view'
                                            ? 'View'
                                            : 'Edit',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: user['permission'] == 'view'
                                              ? Colors.blue[700]
                                              : Colors.orange[700],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Delete button
                                  GestureDetector(
                                    onTap: _isLoading
                                        ? null
                                        : () => _unshareNote(user['id']),
                                    child: Icon(
                                      Icons.close,
                                      size: 18,
                                      color: Colors.red[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ] else if (!_isLoading)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Belum ada yang di-share',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
