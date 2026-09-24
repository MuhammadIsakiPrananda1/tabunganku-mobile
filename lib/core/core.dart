/// Barrel export untuk `lib/core`.
///
/// Import satu baris ini untuk mengakses semua core utilities:
/// ```dart
/// import 'package:tabunganku/core/core.dart';
/// ```
library;

// ── Constants ──────────────────────────────────────────────────────────────
export 'constants/app_constants.dart';
export 'constants/app_version.dart';
export 'constants/prefs_keys.dart';
export 'constants/quick_action_type.dart';

// ── Routing ────────────────────────────────────────────────────────────────
export 'routing/app_router.dart';

// ── Security ───────────────────────────────────────────────────────────────
export 'security/secure_storage_service.dart';

// ── Services (core) ────────────────────────────────────────────────────────
export 'services/local_data_mixin.dart';

// ── Theme ──────────────────────────────────────────────────────────────────
export 'theme/app_colors.dart';
export 'theme/app_theme.dart';
export 'theme/theme_provider.dart';

// ── Utils ──────────────────────────────────────────────────────────────────
export 'utils/bottom_sheet_helper.dart';
export 'utils/currency_formatter.dart';

// ── Widgets ────────────────────────────────────────────────────────────────
export 'widgets/widgets.dart';
