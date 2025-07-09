import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:Appointly/module/auth/presentation/bloc/auth_bloc.dart';
import 'package:Appointly/module/auth/presentation/screen/auth_signIn.dart';
import 'package:Appointly/module/auth/presentation/screen/verification_regis.dart';
import 'package:Appointly/module/auth/presentation/widget/auth_button.dart';
import 'package:Appointly/module/auth/presentation/widget/auth_field.dart';
import 'package:Appointly/module/auth/presentation/widget/link_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthRegister extends StatefulWidget {
  const AuthRegister({super.key});

  @override
  State<AuthRegister> createState() => _AuthRegisterState();
}

class _AuthRegisterState extends State<AuthRegister> {
  final formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

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
    fullNameController.dispose();
    emailController.dispose();
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
      body: SafeArea(
        child: Form(
          key: formKey,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            children: [
              header(),
              SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Join Us Today!',
                    style: GoogleFonts.sourceSans3(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: ColorPallete.darkBlack,
                    ),
                  ),
                  Text(
                    'Create an account and unlock your next great scheduling.',
                    style: GoogleFonts.ubuntu(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: ColorPallete.darkGreySilver,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Column(
                spacing: 16.0,
                children: [
                  AuthField(
                    controller: fullNameController,
                    hintText: 'John Doe',
                    labelText: 'Full Name',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama lengkap tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  AuthField(
                    controller: emailController,
                    hintText: 'johndoe@gmail.com',
                    labelText: 'Email Address',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email tidak boleh kosong';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Email tidak valid';
                      }
                      return null;
                    },
                  ),
                  AuthField(
                    controller: passwordController,
                    hintText: 'Min. 8 Characters',
                    labelText: 'Password',
                    isPassword: true,
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
                  AuthField(
                    controller: confirmPasswordController,
                    hintText: 'Min. 8 Characters',
                    labelText: 'Confirm Password',
                    isPassword: true,
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
                ],
              ),
              SizedBox(height: 16.0),
              // Password requirements
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
              SizedBox(height: 24),
              BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Registered successfully!')),
                    );
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VerificationRegis(),
                      ),
                      (route) => false,
                    );
                  } else if (state is AuthFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.failure)),
                    );
                  }
                },
                builder: (context, state) {
                  return AuthButton(
                    text: state is AuthLoading ? 'Loading...' : 'Get Started',
                    onTap: state is AuthLoading || !_isPasswordValid()
                        ? null
                        : () {
                            if (formKey.currentState!.validate()) {
                              context.read<AuthBloc>().add(RegisterUser(
                                    name: fullNameController.text,
                                    email: emailController.text,
                                    password: passwordController.text,
                                    confirmPassword:
                                        confirmPasswordController.text,
                                  ));
                            }
                          },
                  );
                },
              ),
              SizedBox(height: 4.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account?',
                    style: GoogleFonts.ubuntu(
                      fontSize: 14,
                      color: ColorPallete.darkBlack,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 4.0),
                  LinkButton(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AuthSignin()),
                      );
                    },
                    text: 'Sign In',
                  ),
                ],
              ),
            ],
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

  Widget header() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 36.0),
        Image.asset('assets/image/Logo.png'),
      ],
    );
  }
}
