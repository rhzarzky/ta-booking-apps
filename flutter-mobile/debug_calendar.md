# Debug Google Calendar Integration

## Langkah-langkah untuk Memperbaiki Masalah Calendar Sync

### 1. **Restart Aplikasi Setelah Update Permission**

```bash
flutter clean
flutter pub get
flutter run
```

### 2. **Check Permission di Device Settings**

- Buka **Settings** > **Apps** > **Appointly**
- Pilih **Permissions**
- Pastikan **Calendar** permission **ENABLED**

### 3. **Testing Permission Flow**

Tambahkan code ini untuk testing di development:

```dart
// Tambahkan di initState untuk testing
Future<void> _testPermissions() async {
  final hasPermission = await PermissionService.hasCalendarPermission();
  print('📅 Has calendar permission: $hasPermission');

  if (!hasPermission) {
    final granted = await PermissionService.requestCalendarPermission();
    print('📅 Permission request result: $granted');
  }
}
```

### 4. **Debug Google Authentication**

Check apakah Google sign-in berfungsi:

```dart
// Test Google sign-in
final isSignedIn = await _serviceRepository.isGoogleSignedIn();
print('🔐 Google signed in: $isSignedIn');
```

### 5. **Enable Debug Logging**

Di `main.dart`, pastikan logging aktif:

```dart
void main() {
  // Enable debug logging
  Logger.level = Level.debug;
  runApp(MyApp());
}
```

### 6. **Common Issues & Solutions**

#### **Issue 1: "No permissions found in manifest"**

**Solution:**

- Pastikan AndroidManifest.xml sudah diupdate dengan permissions
- Restart aplikasi setelah update manifest

#### **Issue 2: "Calendar permission denied"**

**Solutions:**

1. Manual enable di device settings
2. Uninstall & reinstall app
3. Check permission permanently denied status

#### **Issue 3: "Authentication failed"**

**Solutions:**

1. Check Google Cloud Console configuration
2. Pastikan OAuth 2.0 client ID benar
3. Check SHA1 fingerprint

#### **Issue 4: "Calendar event not created"**

**Solutions:**

1. Check network connection
2. Verify Google Calendar API enabled
3. Check API quota limits

### 7. **Test Commands**

```bash
# Clean and rebuild
flutter clean && flutter pub get && flutter run

# Check device logs
flutter logs

# Run with verbose output
flutter run -v

# Check connected devices
flutter devices
```

### 8. **Manual Testing Steps**

1. **Enable Calendar Toggle** di UI
2. **Fill booking form** dengan valid data
3. **Click "Book Appointment Now"**
4. **Check permission dialog** muncul
5. **Grant permission** jika diminta
6. **Check Google sign-in** dialog
7. **Verify calendar event** created in Google Calendar

### 9. **Debug Output yang Diharapkan**

```
I/flutter: 📅 Starting calendar event creation...
I/flutter: 📅 Checking calendar permission...
I/flutter: 📅 Has calendar permission: true
I/flutter: 📅 Parsing booking time: 10:00
I/flutter: 📅 Creating calendar event: Service Name on 2024-01-15 10:00:00.000
I/flutter: 📅 Event successfully added to Google Calendar
```

### 10. **Fallback Solutions**

Jika masih gagal, coba:

1. **Disable calendar sync** untuk sementara
2. **Use device calendar** app untuk test permission
3. **Check device calendar** settings
4. **Try different Google account**
5. **Update Google services** di device

### 11. **Production Notes**

Untuk production build, pastikan:

- [ ] Release keystore SHA1 fingerprint ditambahkan di Google Console
- [ ] ProGuard rules untuk Google services
- [ ] Production OAuth client ID
- [ ] Error handling yang user-friendly
