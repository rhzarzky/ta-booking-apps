# Implementasi Fitur Forgot Password

## Overview

Implementasi lengkap untuk fitur forgot password dengan alur:

1. **Forgot Password** - User memasukkan email
2. **OTP Verification** - User memasukkan kode OTP yang diterima via email
3. **Reset Password** - User membuat password baru

## Struktur File yang Diupdate

### 1. Auth Events (`auth_event.dart`)

Ditambahkan events baru:

- `VerifyOTP` - untuk verifikasi kode OTP
- `ResetPassword` - untuk reset password
- `ResendOTP` - untuk mengirim ulang kode OTP

### 2. Auth States (`auth_state.dart`)

States yang sudah tersedia:

- `AuthVerifyOTPSuccess/Failure`
- `AuthResetPasswordSuccess/Failure`
- `AuthResendOTPSuccess/Failure`

### 3. Auth Repository (`auth_repository.dart`)

Diperbaiki typo di fungsi `forgotPassword`:

- `'emaail'` → `'email'`

### 4. Screen Updates

#### AuthForgotpassword

- Integrasi dengan `AuthBloc`
- Validasi form email
- Loading state dan error handling
- Navigate ke OTP screen dengan email parameter

#### AuthOtp

- Menerima parameter email
- Timer countdown untuk resend OTP (60 detik)
- Fungsi mask email untuk privacy
- Auto-enable resend button setelah countdown
- Validasi input OTP 4 digit

#### AuthChangepassword

- Validasi password real-time
- Password requirements checker
- Konfirmasi password match
- Loading state saat reset password

## Cara Penggunaan

### 1. Daftarkan AuthBloc di main app

```dart
BlocProvider<AuthBloc>(
  create: (context) => AuthBloc(
    AuthRepository(),
    serviceBloc, // ServiceBloc instance
  ),
)
```

### 2. Navigation Flow

```dart
// Dari Login Screen ke Forgot Password
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => AuthForgotpassword(),
  ),
);

// Flow otomatis:
// AuthForgotpassword → AuthOtp → AuthChangepassword → MainTabScreen
```

### 3. API Endpoints yang Dibutuhkan

Backend harus menyediakan endpoints:

- `POST /forgot-password` - kirim OTP ke email
- `POST /verify-otp` - verifikasi kode OTP
- `POST /reset-password` - reset password baru
- `POST /resend-otp` - kirim ulang OTP

## Fitur Tambahan

### Timer Countdown

- Countdown 60 detik sebelum bisa resend OTP
- Visual indicator "Resend in X s"
- Auto-enable resend button

### Email Masking

- Format: `ab****@gmail.com`
- Untuk privacy dan keamanan

### Password Validation

- Minimal 8 karakter
- Password dan confirm password harus sama
- Visual indicator dengan checkmark

### Error Handling

- SnackBar untuk success/error messages
- Loading states di semua button
- Disable button saat loading

## State Management Flow

```
1. User input email → ForgotPassword event
2. Success → Navigate to OTP screen
3. User input OTP → VerifyOTP event
4. Success → Navigate to Change Password
5. User input new password → ResetPassword event
6. Success → Navigate to Main App
```

## Testing

Untuk testing, pastikan:

1. Backend API endpoints sudah siap
2. Email service sudah dikonfigurasi
3. Test semua error scenarios
4. Test timer countdown
5. Test validasi form

## Catatan Implementasi

- Semua text dalam bahasa Indonesia sesuai permintaan
- Menggunakan BlocListener untuk handle navigation
- Menggunakan BlocBuilder untuk reactive UI
- Proper disposal of controllers dan timers
- Error messages user-friendly
