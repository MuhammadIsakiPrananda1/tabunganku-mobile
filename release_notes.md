## 🚀 TabunganKu v1.4.0 - Premium Shopping & Smart Reminders

We are excited to announce version 1.4.0, which brings a more premium shopping experience and significant reliability fixes to your daily saving reminders!

### ✨ Highlights
- **Premium Shopping List**: The "Catatan Belanja" feature has been completely migrated from a modal bottom sheet to a standalone, full-page experience. Enjoy more space and a cleaner UI.
- **Reliable Daily Reminders**: We've overhauled the notification system to ensure your 6:00 AM reminders trigger accurately, every single day.
- **Timezone Robustness**: Automatic local timezone detection with smart fallbacks to ensure total accuracy across different regions.

### 🛠️ Audit Logs (Technical Improvements)
- **Feature Migration**: Removed 800+ lines of legacy code in `dashboard_page.dart` and migrated to `ShoppingListPage`.
- **System Priority**: Notifications now use `Importance.max` and `Priority.max` to ensure visibility on all Android versions.
- **Auto-Sync**: Reminders are now automatically re-scheduled every time the app is opened to keep the system alarm fresh and accurate.
- **Clean Architecture**: Cleaned up unused imports and optimized the codebase for 1.4.0 release.

### 📦 Installation
Please download the APK suited for your device architecture:
- **arm64-v8a**: Most modern Android phones.
- **armeabi-v7a**: Older Android phones.
- **x86_64**: Tablets or Emulators.
