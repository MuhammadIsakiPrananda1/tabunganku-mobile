import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:tabunganku/models/note_model.dart';
import 'package:tabunganku/providers/note_provider.dart';

class NoteDetailPage extends ConsumerStatefulWidget {
  final NoteModel? note;

  const NoteDetailPage({super.key, this.note});

  @override
  ConsumerState<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends ConsumerState<NoteDetailPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late int _selectedColorValue;
  late bool _isPinned;
  late bool _isFavorite;
  bool _hasSaved = false;
  String _previousText = '';
  bool _isFormatting = false;

  final List<Map<String, dynamic>> _pastelColors = [
    {'name': 'Sky Blue', 'value': 0xFFE3F2FD, 'darkVariant': 0xFF0D47A1},
    {'name': 'Mint', 'value': 0xFFE8F5E9, 'darkVariant': 0xFF1B5E20},
    {'name': 'Peach', 'value': 0xFFFFE0B2, 'darkVariant': 0xFFE65100},
    {'name': 'Rose', 'value': 0xFFFCE4EC, 'darkVariant': 0xFF880E4F},
    {'name': 'Lavender', 'value': 0xFFF3E5F5, 'darkVariant': 0xFF4A148C},
    {'name': 'Silver', 'value': 0xFFECEFF1, 'darkVariant': 0xFF37474F},
  ];

  @override
  void initState() {
    super.initState();
    final note = widget.note;
    _titleController = TextEditingController(text: note?.title ?? '');
    _contentController = TextEditingController(text: note?.content ?? '');
    _selectedColorValue = note?.colorValue ?? 0xFFE3F2FD;
    _isPinned = note?.isPinned ?? false;
    _isFavorite = note?.isFavorite ?? false;

    _previousText = _contentController.text;
    _contentController.addListener(_onContentChanged);
  }

  @override
  void dispose() {
    _contentController.removeListener(_onContentChanged);
    // Auto-save on dispose if not explicitly saved/exited
    if (!_hasSaved) {
      _saveNote();
    }
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onContentChanged() {
    if (_isFormatting) return;

    final text = _contentController.text;
    final selection = _contentController.selection;

    if (text.length > _previousText.length) {
      _isFormatting = true;
      try {
        final int cursor = selection.start;

        // 1. Handle ENTER (Newline)
        if (cursor > 0 && text[cursor - 1] == '\n') {
          // Find the start of the line that was just ended
          int lineStart = 0;
          for (int i = cursor - 2; i >= 0; i--) {
            if (text[i] == '\n') {
              lineStart = i + 1;
              break;
            }
          }

          final endedLine = text.substring(lineStart, cursor - 1);

          final numRegExp = RegExp(r'^(\d+)\.\s+');
          final bulletRegExp = RegExp(r'^([\-\*•])\s+');

          if (numRegExp.hasMatch(endedLine)) {
            final match = numRegExp.firstMatch(endedLine)!;
            final numStr = match.group(1)!;

            if (endedLine.trim() == '$numStr.') {
              if (numStr != '1') {
                // Cancel list
                final newText = text.substring(0, lineStart) + text.substring(cursor);
                _contentController.value = TextEditingValue(
                  text: newText,
                  selection: TextSelection.collapsed(offset: lineStart),
                );
                _previousText = newText;
                return;
              } else {
                // First list item. Continue to 2.
                final nextNum = int.parse(numStr) + 1;
                final prefix = '$nextNum. ';
                final newText = text.substring(0, cursor) + prefix + text.substring(cursor);
                _contentController.value = TextEditingValue(
                  text: newText,
                  selection: TextSelection.collapsed(offset: cursor + prefix.length),
                );
                _previousText = newText;
                return;
              }
            } else {
              // Increment and continue list
              final nextNum = int.parse(numStr) + 1;
              final prefix = '$nextNum. ';
              final newText = text.substring(0, cursor) + prefix + text.substring(cursor);
              _contentController.value = TextEditingValue(
                text: newText,
                selection: TextSelection.collapsed(offset: cursor + prefix.length),
              );
              _previousText = newText;
              return;
            }
          } else if (bulletRegExp.hasMatch(endedLine)) {
            final match = bulletRegExp.firstMatch(endedLine)!;
            final bulletChar = match.group(1)!;

            if (endedLine.trim() == bulletChar) {
              // Check if there is a line before this one that starts with a bullet
              bool hasPreviousBulletLine = false;
              if (lineStart > 1) {
                int prevLineStart = 0;
                for (int i = lineStart - 2; i >= 0; i--) {
                  if (text[i] == '\n') {
                    prevLineStart = i + 1;
                    break;
                  }
                }
                final prevLine = text.substring(prevLineStart, lineStart - 1);
                if (bulletRegExp.hasMatch(prevLine)) {
                  hasPreviousBulletLine = true;
                }
              }

              if (hasPreviousBulletLine) {
                // Cancel list
                final newText = text.substring(0, lineStart) + text.substring(cursor);
                _contentController.value = TextEditingValue(
                  text: newText,
                  selection: TextSelection.collapsed(offset: lineStart),
                );
                _previousText = newText;
                return;
              } else {
                // First bullet. Continue list.
                final prefix = '$bulletChar ';
                final newText = text.substring(0, cursor) + prefix + text.substring(cursor);
                _contentController.value = TextEditingValue(
                  text: newText,
                  selection: TextSelection.collapsed(offset: cursor + prefix.length),
                );
                _previousText = newText;
                return;
              }
            } else {
              // Continue bullet list
              final prefix = '$bulletChar ';
              final newText = text.substring(0, cursor) + prefix + text.substring(cursor);
              _contentController.value = TextEditingValue(
                text: newText,
                selection: TextSelection.collapsed(offset: cursor + prefix.length),
              );
              _previousText = newText;
              return;
            }
          }
        }

        // 2. Handle SPACE (Auto-convert list bullet characters)
        if (cursor > 0 && text[cursor - 1] == ' ') {
          int lineStart = 0;
          for (int i = cursor - 2; i >= 0; i--) {
            if (text[i] == '\n') {
              lineStart = i + 1;
              break;
            }
          }
          final currentLine = text.substring(lineStart, cursor);
          if (currentLine == '- ' || currentLine == '* ') {
            final newText = text.substring(0, lineStart) + '• ' + text.substring(cursor);
            _contentController.value = TextEditingValue(
              text: newText,
              selection: TextSelection.collapsed(offset: lineStart + 2),
            );
            _previousText = newText;
            return;
          }
        }
      } finally {
        _isFormatting = false;
      }
    }
    _previousText = text;
  }

  Color _resolvePageColor(int colorValue, bool isDarkMode) {
    if (!isDarkMode) {
      return Color(colorValue);
    }
    final colorMap = _pastelColors.firstWhere(
      (c) => c['value'] == colorValue,
      orElse: () => {'darkVariant': 0xFF1E1E1E},
    );
    return Color(colorMap['darkVariant'] as int).withOpacity(0.4);
  }

  Color _resolveTextColor(int colorValue, bool isDarkMode) {
    if (isDarkMode) {
      return Colors.white;
    }
    return Colors.blueGrey.shade900;
  }

  Color _resolveSubtitleColor(int colorValue, bool isDarkMode) {
    if (isDarkMode) {
      return Colors.white70;
    }
    return Colors.blueGrey.shade700;
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty && widget.note == null) {
      return;
    }

    final service = ref.read(noteServiceProvider);
    if (widget.note != null) {
      final updated = widget.note!.copyWith(
        title: title.isEmpty ? 'Catatan Tanpa Judul' : title,
        content: content,
        colorValue: _selectedColorValue,
        isPinned: _isPinned,
        isFavorite: _isFavorite,
      );
      service.updateNote(updated);
    } else {
      final newNote = NoteModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title.isEmpty ? 'Catatan Tanpa Judul' : title,
        content: content,
        createdAt: DateTime.now(),
        colorValue: _selectedColorValue,
        isPinned: _isPinned,
        isFavorite: _isFavorite,
      );
      service.addNote(newNote);
    }
    _hasSaved = true;
  }

  void _deleteNote() {
    if (widget.note == null) return;
    
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
                ref.read(noteServiceProvider).deleteNote(widget.note!.id);
                _hasSaved = true; // Mark saved so dispose doesn't rewrite it
                Navigator.pop(context); // Close dialog
                Navigator.pop(this.context); // Exit detail page
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

    final pageColor = _resolvePageColor(_selectedColorValue, isDarkMode);
    final textColor = _resolveTextColor(_selectedColorValue, isDarkMode);
    final subtitleColor = _resolveSubtitleColor(_selectedColorValue, isDarkMode);

    final noteDate = widget.note?.createdAt ?? DateTime.now();
    final dateStr = DateFormat('EEEE, d MMMM yyyy - HH:mm', 'id_ID').format(noteDate);

    return WillPopScope(
      onWillPop: () async {
        _saveNote();
        return true;
      },
      child: Scaffold(
        backgroundColor: pageColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              _saveNote();
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 18),
          ),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  _isPinned = !_isPinned;
                });
              },
              icon: Icon(
                _isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                color: _isPinned ? AppColors.primary : textColor.withOpacity(0.6),
                size: 22,
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _isFavorite = !_isFavorite;
                });
              },
              icon: Icon(
                _isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                color: _isFavorite ? Colors.amber : textColor.withOpacity(0.6),
                size: 22,
              ),
            ),
            if (widget.note != null)
              IconButton(
                onPressed: _deleteNote,
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
              ),
            IconButton(
              onPressed: () {
                _saveNote();
                Navigator.pop(context);
              },
              icon: Icon(Icons.check_rounded, color: textColor, size: 22),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date stamp
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text(
                  dateStr,
                  style: GoogleFonts.quicksand(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: subtitleColor.withOpacity(0.5),
                  ),
                ),
              ),
              
              // Title input
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextFormField(
                  controller: _titleController,
                  style: GoogleFonts.quicksand(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Judul Catatan...',
                    filled: false,
                    fillColor: Colors.transparent,
                    hintStyle: GoogleFonts.quicksand(
                      color: textColor.withOpacity(0.35),
                      fontWeight: FontWeight.bold,
                    ),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              
              // Divider Line
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Divider(
                  color: textColor.withOpacity(0.12),
                  thickness: 1,
                  height: 1,
                ),
              ),
              const SizedBox(height: 8), // Perfect spacing right under the line
              
              // Scrollable Note content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextFormField(
                    controller: _contentController,
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: textColor.withOpacity(0.85),
                      height: 1.5,
                    ),
                    maxLines: null,
                    minLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Tulis sesuatu di sini...',
                      filled: false,
                      fillColor: Colors.transparent,
                      hintStyle: GoogleFonts.quicksand(
                        color: textColor.withOpacity(0.3),
                      ),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
              
              // Bottom Color Picker Bar
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.03),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  children: [
                    Text(
                      'Warna:',
                      style: GoogleFonts.quicksand(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: textColor.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: SizedBox(
                        height: 34,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _pastelColors.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final colorMap = _pastelColors[index];
                            final int value = colorMap['value'] as int;
                            final isSelected = _selectedColorValue == value;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedColorValue = value;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(value),
                                  border: Border.all(
                                    color: isSelected 
                                        ? (isDarkMode ? Colors.white : AppColors.primaryDark) 
                                        : Colors.transparent,
                                    width: isSelected ? 2.5 : 0,
                                  ),
                                ),
                                child: isSelected
                                    ? Icon(
                                        Icons.check_rounded,
                                        size: 12,
                                        color: Colors.blueGrey.shade900,
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
