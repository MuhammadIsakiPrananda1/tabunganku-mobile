import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:tabunganku/models/note_model.dart';
import 'package:tabunganku/providers/note_provider.dart';

class NotesPage extends ConsumerStatefulWidget {
  const NotesPage({super.key});

  @override
  ConsumerState<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends ConsumerState<NotesPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  String _searchQuery = '';
  bool _filterFavoritesOnly = false;
  int _selectedColorValue = 0xFFE3F2FD; // Default Sky Blue

  // A premium palette of 6 pastel colors
  final List<Map<String, dynamic>> _pastelColors = [
    {'name': 'Sky Blue', 'value': 0xFFE3F2FD, 'darkVariant': 0xFF0D47A1},
    {'name': 'Mint', 'value': 0xFFE8F5E9, 'darkVariant': 0xFF1B5E20},
    {'name': 'Peach', 'value': 0xFFFFE0B2, 'darkVariant': 0xFFE65100},
    {'name': 'Rose', 'value': 0xFFFCE4EC, 'darkVariant': 0xFF880E4F},
    {'name': 'Lavender', 'value': 0xFFF3E5F5, 'darkVariant': 0xFF4A148C},
    {'name': 'Silver', 'value': 0xFFECEFF1, 'darkVariant': 0xFF37474F},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Color _resolveCardColor(int colorValue, bool isDarkMode) {
    if (!isDarkMode) {
      return Color(colorValue);
    }
    // For Dark Mode, match the original pastel value to its premium dark variant
    final colorMap = _pastelColors.firstWhere(
      (c) => c['value'] == colorValue,
      orElse: () => {'darkVariant': 0xFF1E1E1E},
    );
    return Color(colorMap['darkVariant'] as int).withOpacity(0.5);
  }

  Color _resolveTextColor(int colorValue, bool isDarkMode) {
    if (isDarkMode) {
      return Colors.white;
    }
    // High contrast dark text for light pastel backgrounds
    return Colors.blueGrey.shade900;
  }

  Color _resolveSubtitleColor(int colorValue, bool isDarkMode) {
    if (isDarkMode) {
      return Colors.white70;
    }
    return Colors.blueGrey.shade700;
  }

  void _showNoteForm({NoteModel? note}) {
    final isEditing = note != null;
    if (isEditing) {
      _titleController.text = note.title;
      _contentController.text = note.content;
      _selectedColorValue = note.colorValue;
    } else {
      _titleController.clear();
      _contentController.clear();
      _selectedColorValue = 0xFFE3F2FD; // Reset to default Sky Blue
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = ref.watch(themeProvider) == ThemeMode.dark ||
            (ref.watch(themeProvider) == ThemeMode.system && theme.brightness == Brightness.dark);
        final contentColor = isDark ? Colors.white : AppColors.primaryDark;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white12 : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isEditing ? 'Edit Catatan' : 'Catatan Baru',
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: contentColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _titleController,
                    style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      hintText: 'Judul Catatan',
                      hintStyle: GoogleFonts.quicksand(color: isDark ? Colors.white24 : Colors.grey.shade400, fontWeight: FontWeight.bold),
                      filled: true,
                      fillColor: isDark ? Colors.white.withOpacity(0.03) : AppColors.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _contentController,
                    maxLines: 6,
                    minLines: 3,
                    style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white70 : Colors.black87),
                    decoration: InputDecoration(
                      hintText: 'Tulis sesuatu di sini...',
                      hintStyle: GoogleFonts.quicksand(color: isDark ? Colors.white24 : Colors.grey.shade400, fontWeight: FontWeight.bold),
                      filled: true,
                      fillColor: isDark ? Colors.white.withOpacity(0.03) : AppColors.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Pilih Warna Kartu',
                    style: GoogleFonts.quicksand(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: contentColor.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 48,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _pastelColors.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final colorMap = _pastelColors[index];
                        final int value = colorMap['value'] as int;
                        final isSelected = _selectedColorValue == value;

                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              _selectedColorValue = value;
                            });
                            setState(() {});
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(value),
                              border: Border.all(
                                color: isSelected 
                                    ? (isDark ? Colors.white : AppColors.primary) 
                                    : Colors.transparent,
                                width: isSelected ? 3 : 0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: isSelected
                                ? Icon(
                                    Icons.check_rounded,
                                    size: 16,
                                    color: Colors.blueGrey.shade900,
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_titleController.text.trim().isEmpty && _contentController.text.trim().isEmpty) {
                          Navigator.pop(context);
                          return;
                        }

                        final service = ref.read(noteServiceProvider);
                        if (isEditing) {
                          final updated = note.copyWith(
                            title: _titleController.text.trim(),
                            content: _contentController.text.trim(),
                            colorValue: _selectedColorValue,
                          );
                          service.updateNote(updated);
                        } else {
                          final newNote = NoteModel(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            title: _titleController.text.trim().isEmpty ? 'Catatan Tanpa Judul' : _titleController.text.trim(),
                            content: _contentController.text.trim(),
                            createdAt: DateTime.now(),
                            colorValue: _selectedColorValue,
                            isPinned: false,
                            isFavorite: false,
                          );
                          service.addNote(newNote);
                        }

                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: Text(
                        isEditing ? 'Simpan Perubahan' : 'Tambah Catatan',
                        style: GoogleFonts.quicksand(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = ref.watch(themeProvider) == ThemeMode.dark ||
            (ref.watch(themeProvider) == ThemeMode.system && theme.brightness == Brightness.dark);
        final contentColor = isDark ? Colors.white : AppColors.primaryDark;

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
          title: Text(
            'Hapus Catatan',
            style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 16, color: contentColor),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus catatan ini selamanya?',
            style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white70 : Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                ref.read(noteServiceProvider).deleteNote(id);
                Navigator.pop(context);
              },
              child: Text(
                'Hapus',
                style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system && theme.brightness == Brightness.dark);
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final pageBgColor = isDarkMode ? AppColors.backgroundDark : const Color(0xFFF8FAF9);

    final notesAsync = ref.watch(notesStreamProvider);

    return Scaffold(
      backgroundColor: pageBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: contentColor, size: 18),
        ),
        title: Text(
          'Catatan Harian',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: contentColor,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _filterFavoritesOnly = !_filterFavoritesOnly;
              });
            },
            icon: Icon(
              _filterFavoritesOnly ? Icons.star_rounded : Icons.star_border_rounded,
              color: _filterFavoritesOnly ? Colors.amber : contentColor.withOpacity(0.6),
              size: 24,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNoteForm(),
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
      body: notesAsync.when(
        data: (allNotes) {
          // 1. Filter by Search Query & Favorites
          var filteredNotes = allNotes.where((note) {
            final matchesSearch = note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                note.content.toLowerCase().contains(_searchQuery.toLowerCase());
            final matchesFavorite = !_filterFavoritesOnly || note.isFavorite;
            return matchesSearch && matchesFavorite;
          }).toList();

          // Sort by Pinned status, then by creation date (newest first)
          filteredNotes.sort((a, b) {
            if (a.isPinned && !b.isPinned) return -1;
            if (!a.isPinned && b.isPinned) return 1;
            return b.createdAt.compareTo(a.createdAt);
          });

          if (allNotes.isEmpty) {
            return _buildEmptyState(isDarkMode);
          }

          final pinnedNotes = filteredNotes.where((n) => n.isPinned).toList();
          final otherNotes = filteredNotes.where((n) => !n.isPinned).toList();

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: TextFormField(
                  controller: _searchController,
                  style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: isDarkMode ? Colors.white : Colors.black87),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari catatan...',
                    hintStyle: GoogleFonts.quicksand(color: isDarkMode ? Colors.white24 : Colors.grey.shade400, fontWeight: FontWeight.bold),
                    prefixIcon: Icon(Icons.search_rounded, color: isDarkMode ? Colors.white30 : Colors.grey.shade400, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: isDarkMode ? Colors.white.withOpacity(0.03) : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: isDarkMode ? BorderSide.none : BorderSide(color: Colors.grey.shade100),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: isDarkMode ? BorderSide.none : BorderSide(color: Colors.grey.shade100),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                  children: [
                    if (pinnedNotes.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 12),
                        child: Row(
                          children: [
                            Icon(Icons.push_pin_rounded, color: AppColors.primary, size: 13),
                            const SizedBox(width: 6),
                            Text(
                              'DISEMATKAN',
                              style: GoogleFonts.quicksand(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                                color: isDarkMode ? Colors.white30 : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: pinnedNotes.length,
                        itemBuilder: (context, index) {
                          return _buildNoteCard(pinnedNotes[index], isDarkMode);
                        },
                      ),
                      const SizedBox(height: 24),
                    ],

                    if (otherNotes.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 12),
                        child: Text(
                          pinnedNotes.isNotEmpty ? 'CATATAN LAINNYA' : 'SEMUA CATATAN',
                          style: GoogleFonts.quicksand(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            color: isDarkMode ? Colors.white30 : Colors.grey,
                          ),
                        ),
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: otherNotes.length,
                        itemBuilder: (context, index) {
                          return _buildNoteCard(otherNotes[index], isDarkMode);
                        },
                      ),
                    ] else if (pinnedNotes.isEmpty && filteredNotes.isEmpty) ...[
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Text(
                            'Tidak ada catatan yang cocok dengan pencarian.',
                            style: GoogleFonts.quicksand(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white30 : Colors.grey,
                            ),
                          ),
                        ),
                      )
                    ],
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, _) => Center(child: Text('Gagal memuat catatan: $err')),
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDarkMode ? Colors.white.withOpacity(0.02) : Colors.white,
              border: Border.all(color: isDarkMode ? Colors.white10 : Colors.grey.shade100, width: 2),
            ),
            child: Icon(
              Icons.note_alt_rounded,
              size: 48,
              color: isDarkMode ? Colors.white10 : Colors.grey.shade300,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada catatan',
            style: GoogleFonts.quicksand(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tulis memo penting atau ide harianmu.',
            style: GoogleFonts.quicksand(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white30 : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(NoteModel note, bool isDarkMode) {
    final cardColor = _resolveCardColor(note.colorValue, isDarkMode);
    final textColor = _resolveTextColor(note.colorValue, isDarkMode);
    final subtitleColor = _resolveSubtitleColor(note.colorValue, isDarkMode);
    final dateStr = DateFormat('d MMM, HH:mm', 'id_ID').format(note.createdAt);

    return GestureDetector(
      onTap: () => _showNoteForm(note: note),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
          ),
          boxShadow: isDarkMode
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    note.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.quicksand(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    final updated = note.copyWith(isPinned: !note.isPinned);
                    ref.read(noteServiceProvider).updateNote(updated);
                  },
                  child: Icon(
                    note.isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                    size: 14,
                    color: note.isPinned ? AppColors.primary : textColor.withOpacity(0.4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Text(
                note.content,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.quicksand(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                  color: subtitleColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateStr,
                  style: GoogleFonts.quicksand(
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                    color: subtitleColor.withOpacity(0.6),
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        final updated = note.copyWith(isFavorite: !note.isFavorite);
                        ref.read(noteServiceProvider).updateNote(updated);
                      },
                      child: Icon(
                        note.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                        size: 16,
                        color: note.isFavorite ? Colors.amber : textColor.withOpacity(0.4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _confirmDelete(note.id),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        size: 16,
                        color: isDarkMode ? Colors.redAccent.withOpacity(0.8) : Colors.red.shade700.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
