import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabunganku/models/note_model.dart';
import 'package:tabunganku/services/note_service.dart';

// Provider for NoteService singleton
final noteServiceProvider = Provider<NoteService>((ref) {
  return SharedPreferencesNoteService();
});

// StreamProvider for watching all notes dynamically in the UI
final notesStreamProvider = StreamProvider.autoDispose<List<NoteModel>>((ref) {
  final service = ref.watch(noteServiceProvider);
  return service.watchNotes();
});
