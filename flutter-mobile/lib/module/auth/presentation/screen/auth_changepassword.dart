import 'package:Appointly/core/common/main_tab_screen.dart';
import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:Appointly/module/auth/presentation/bloc/auth_bloc.dart';
import 'package:Appointly/module/auth/presentation/widget/auth_button.dart';
import 'package:Appointly/module/auth/presentation/widget/auth_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthChangepassword extends StatefulWidget {
  const AuthChangepassword({super.key});

  @override
  State<AuthChangepassword> createState() => _AuthChangepasswordState();
}

class _AuthChangepasswordState extends State<AuthChangepassword> {
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Add listeners to update UI when text changes
    passwordController.addListener(() {
      setState(() {});
    });
    confirmPasswordController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isPasswordValid() {
    return passwordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty &&
        passwordController.text == confirmPasswordController.text &&
        _isPasswordStrong(passwordController.text) &&
        _isNotSequential(passwordController.text);
  }

  bool _isPasswordStrong(String password) {
    // Regex untuk validasi password yang kuat
    final regex = RegExp(
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*#?&^])[A-Za-z\d@$!%*#?&^]{8,}$');
    return regex.hasMatch(password);
  }

  bool _hasLowercase(String password) {
    return RegExp(r'[a-z]').hasMatch(password);
  }

  bool _hasUppercase(String password) {
    return RegExp(r'[A-Z]').hasMatch(password);
  }

  bool _hasDigit(String password) {
    return RegExp(r'\d').hasMatch(password);
  }

  bool _hasSpecialChar(String password) {
    return RegExp(r'[@$!%*#?&^]').hasMatch(password);
  }

  bool _isMinLength(String password) {
    return password.length >= 8;
  }

  bool _isNotSequential(String password) {
    // Cek apakah password berupa angka berurutan 1-8 atau pola berurutan lainnya
    const sequential = [
      '12345678',
      '87654321',
      '11111111',
      '22222222',
      '33333333',
      '44444444',
      '55555555',
      '66666666',
      '77777777',
      '88888888',
      '99999999',
      '00000000'
    ];
    return !sequential.contains(password) && password != '12345678';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPallete.backgroundBody,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_rounded),
          iconSize: 32.0,
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthResetPasswordSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Password berhasil diubah'),
                backgroundColor: Colors.green,
              ),
            );
            // Navigate to login screen or main screen
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => MainTabScreen()),
              (route) => false,
            );
          } else if (state is AuthResetPasswordFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.failure),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Padding(
          padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reset Password?',
                      style: GoogleFonts.ubuntu(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: ColorPallete.darkBlack,
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text(
                      'Create new password for your account.',
                      style: GoogleFonts.ubuntu(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: ColorPallete.darkGreySilver,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 24.0,
                ),
                Column(
                  children: [
                    AuthField(
                      hintText: 'Min. 8 Character',
                      isPassword: true,
                      controller: passwordController,
                      labelText: 'New Password',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password tidak boleh kosong';
                        }
                        if (!_isPasswordStrong(value)) {
                          return 'Password harus memenuhi semua kriteria';
                        }
                        if (!_isNotSequential(value)) {
                          return 'Password tidak boleh berupa angka berurutan';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24.0),
                    AuthField(
                      hintText: 'Min. 8 Character',
                      isPassword: true,
                      controller: confirmPasswordController,
                      labelText: 'Confirm Password',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Konfirmasi password tidak boleh kosong';
                        }
                        if (value != passwordController.text) {
                          return 'Password tidak sama';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0), // Password requirements
                    Container(
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Password Requirements:',
                            style: GoogleFonts.ubuntu(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: ColorPallete.darkBlack,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          _buildRequirement(
                            'Minimal 8 karakter',
                            _isMinLength(passwordController.text),
                          ),
                          _buildRequirement(
                            'Mengandung huruf kecil (a-z)',
                            _hasLowercase(passwordController.text),
                          ),
                          _buildRequirement(
                            'Mengandung huruf besar (A-Z)',
                            _hasUppercase(passwordController.text),
                          ),
                          _buildRequirement(
                            'Mengandung angka (0-9)',
                            _hasDigit(passwordController.text),
                          ),
                          _buildRequirement(
                            'Mengandung karakter khusus (@\$!%*#?&^)',
                            _hasSpecialChar(passwordController.text),
                          ),
                          _buildRequirement(
                            'Bukan angka berurutan (1-8) atau sama',
                            _isNotSequential(passwordController.text),
                          ),
                          _buildRequirement(
                            'Password harus sama',
                            passwordController.text.isNotEmpty &&
                                confirmPasswordController.text.isNotEmpty &&
                                passwordController.text ==
                                    confirmPasswordController.text,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Spacer(),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return AuthButton(
                      text: state is AuthLoading ? 'Processing...' : 'Continue',
                      onTap: state is AuthLoading || !_isPasswordValid()
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                context.read<AuthBloc>().add(
                                      ResetPassword(
                                        password:
                                            passwordController.text.trim(),
                                        confirmPassword:
                                            confirmPasswordController.text
                                                .trim(),
                                      ),
                                    );
                              }
                            },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequirement(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 16,
          color: isValid ? Colors.green : Colors.grey,
        ),
        SizedBox(width: 8.0),
        Text(
          text,
          style: GoogleFonts.ubuntu(
            fontSize: 12,
            color: isValid ? Colors.green : Colors.grey,
          ),
        ),
      ],
    );
  }
}
