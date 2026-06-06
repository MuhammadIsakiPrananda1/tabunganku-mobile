import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabunganku/models/note_model.dart';

abstract class NoteService {
  Future<List<NoteModel>> getNotes();
  Future<void> addNote(NoteModel note);
  Future<void> updateNote(NoteModel note);
  Future<void> deleteNote(String id);
  Stream<List<NoteModel>> watchNotes();
}

class SharedPreferencesNoteService implements NoteService {
  static const String _storageKey = 'general_notes_user_';
  static Future<SharedPreferences>? _prefsFuture;
  static final Map<String, List<NoteModel>> _userNotes = {};
  static final StreamController<List<NoteModel>> _streamController =
      StreamController<List<NoteModel>>.broadcast();

  Future<SharedPreferences> _getPrefs() {
    _prefsFuture ??= SharedPreferences.getInstance();
    return _prefsFuture!;
  }

  Future<String> _getCurrentUserId() async {
    return 'default_user';
  }

  Future<void> _ensureUserLoaded(String userId) async {
    if (_userNotes.containsKey(userId)) {
      return;
    }

    final prefs = await _getPrefs();
    final raw = prefs.getString('$_storageKey$userId');
    if (raw == null || raw.isEmpty) {
      _userNotes[userId] = [];
      return;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        _userNotes[userId] = decoded
            .whereType<Map>()
            .map((item) => NoteModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      } else {
        _userNotes[userId] = [];
      }
    } catch (_) {
      _userNotes[userId] = [];
    }
  }

  Future<void> _saveUserNotes(String userId) async {
    final prefs = await _getPrefs();
    final list = _userNotes[userId] ?? const <NoteModel>[];
    final raw = jsonEncode(list.map((e) => e.toJson()).toList());
    await prefs.setString('$_storageKey$userId', raw);
  }

  Future<void> _emitNotes(String userId) async {
    await _ensureUserLoaded(userId);
    final notes = _userNotes[userId] ?? const <NoteModel>[];
    _streamController.add(List.unmodifiable(notes));
  }

  @override
  Future<List<NoteModel>> getNotes() async {
    final userId = await _getCurrentUserId();
    await _ensureUserLoaded(userId);
    return List.unmodifiable(_userNotes[userId] ?? const <NoteModel>[]);
  }

  @override
  Future<void> addNote(NoteModel note) async {
    final userId = await _getCurrentUserId();
    await _ensureUserLoaded(userId);
    _userNotes[userId]!.add(note);
    await _saveUserNotes(userId);
    await _emitNotes(userId);
  }

  @override
  Future<void> updateNote(NoteModel note) async {
    final userId = await _getCurrentUserId();
    await _ensureUserLoaded(userId);
    final notes = _userNotes[userId]!;
    final index = notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      notes[index] = note;
      await _saveUserNotes(userId);
      await _emitNotes(userId);
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    final userId = await _getCurrentUserId();
    await _ensureUserLoaded(userId);
    _userNotes[userId]!.removeWhere((n) => n.id == id);
    await _saveUserNotes(userId);
    await _emitNotes(userId);
  }

  @override
  Stream<List<NoteModel>> watchNotes() {
    return Stream<List<NoteModel>>.multi((controller) {
      Future<void>(() async {
        final userId = await _getCurrentUserId();
        await _ensureUserLoaded(userId);
        controller.add(List.unmodifiable(_userNotes[userId] ?? const <NoteModel>[]));
      });
      final subscription = _streamController.stream.listen(controller.add);
      controller.onCancel = subscription.cancel;
    });
  }
}
