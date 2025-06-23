# Google OAuth Setup untuk Development

## Masalah: "Access blocked: appointly has not completed the Google verification process"

### Solusi untuk Development Testing

#### 1. **OAuth Consent Screen Setup**

**A. Buka Google Cloud Console:**

- URL: https://console.cloud.google.com/apis/credentials/consent
- Login dengan account developer

**B. Configure App Information:**

```
App name: Appointly
User support email: [your-developer-email]
App logo: (optional untuk testing)
App domain: (optional untuk testing)
Developer contact: [your-developer-email]
```

**C. Set User Type:**

- Pilih **EXTERNAL** (untuk testing)
- Publishing status: **Testing**

#### 2. **Add Test Users**

**Sangat Penting:** Tambahkan email yang akan digunakan untuk testing

```
Test users:
- fabdurrahman904@gmail.com (dari screenshot error)
- [email developer lainnya jika ada]
```

**Steps:**

1. Di OAuth consent screen > **Test users**
2. Klik **ADD USERS**
3. Masukkan email: `fabdurrahman904@gmail.com`
4. Klik **SAVE**

#### 3. **Add Required Scopes**

Klik **ADD OR REMOVE SCOPES** dan pilih:

```
✅ https://www.googleapis.com/auth/calendar
✅ https://www.googleapis.com/auth/calendar.events
✅ https://www.googleapis.com/auth/userinfo.email
✅ https://www.googleapis.com/auth/userinfo.profile
```

#### 4. **OAuth 2.0 Client ID Setup**

**A. Create Credentials:**

1. APIs & Services > Credentials
2. CREATE CREDENTIALS > OAuth 2.0 Client ID
3. Application type: **Android**

**B. Android Configuration:**

```
Package name: com.example.appointly (sesuaikan dengan pubspec.yaml)
SHA-1 certificate fingerprint: [generate dari debug keystore]
```

**Generate SHA-1:**

```bash
keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore
Password: android
```

#### 5. **Testing Flow**

**A. User yang Bisa Testing:**

- Hanya email yang ditambahkan di **Test users**
- Developer account (owner project)
- User dengan role Editor/Viewer di project

**B. Expected Behavior:**

- User test akan melihat warning "This app isn't verified"
- Klik **Advanced** > **Go to Appointly (unsafe)**
- Grant permissions
- App akan berfungsi normal

#### 6. **Alternative: Internal App**

Jika semua user dalam satu organisasi Google Workspace:

```
User Type: INTERNAL
Publishing status: In production
Scopes: Tidak perlu review Google
```

#### 7. **Production Ready**

Untuk production (users unlimited):

**A. App Verification Required:**

- Submit app untuk Google verification
- Provide demo video
- Wait for Google approval (1-6 weeks)

**B. Requirements:**

- Domain verification
- Privacy policy
- Terms of service
- Detailed app description

## Testing Commands

### Clean & Rebuild

```bash
cd flutter-mobile
flutter clean
flutter pub get
flutter run
```

### Check Google Services

```bash
# Check if Google services configured
cat android/app/google-services.json

# Check SHA-1 fingerprint
keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore
```

## Troubleshooting

### Error: "access_denied"

**Cause:** User not in test users list
**Solution:** Add user email to Test users in OAuth consent screen

### Error: "unauthorized_client"

**Cause:** OAuth client not configured properly
**Solution:** Check package name and SHA-1 fingerprint

### Error: "invalid_client"

**Cause:** Client ID mismatch
**Solution:** Check google-services.json or client ID in code

## Best Practices for Development

1. **Always use TESTING mode** untuk development
2. **Add all developers** sebagai test users
3. **Use debug keystore** untuk development
4. **Don't submit for verification** until ready for production
5. **Test with actual test users** before production

## Next Steps

1. ✅ Setup OAuth consent screen (Testing mode)
2. ✅ Add test users (fabdurrahman904@gmail.com)
3. ✅ Add required scopes
4. ✅ Create Android OAuth client
5. ✅ Test with authorized users
6. 🔄 Clean & rebuild Flutter app
7. 🔄 Test Google Calendar integration

## Production Checklist (Untuk Nanti)

- [ ] Domain verification
- [ ] Privacy policy URL
- [ ] Terms of service URL
- [ ] App verification submission
- [ ] Demo video creation
- [ ] Security assessment (jika perlu)
- [ ] Google approval process
