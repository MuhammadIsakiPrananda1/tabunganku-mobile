/// Provider: NoteProvider
//
// Menyediakan akses reaktif ke catatan keuangan pengguna.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabunganku/models/note_model.dart';
import 'package:tabunganku/services/note_service.dart';

final noteServiceProvider = Provider<NoteService>((ref) {
  return LocalNoteService();
});

final notesStreamProvider = StreamProvider.autoDispose<List<NoteModel>>((ref) {
  final service = ref.watch(noteServiceProvider);
  return service.watchNotes();
});
