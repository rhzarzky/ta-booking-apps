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

  bool _isPasswordValid() {
    return passwordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty &&
        passwordController.text == confirmPasswordController.text &&
        passwordController.text.length >= 8;
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
                    ),
                    SizedBox(height: 24.0),
                    AuthField(
                      hintText: 'Min. 8 Character',
                      isPassword: true,
                      controller: confirmPasswordController,
                      labelText: 'Confirm Password',
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
                            passwordController.text.length >= 8,
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
                              context.read<AuthBloc>().add(
                                    ResetPassword(
                                      password: passwordController.text.trim(),
                                      confirmPassword:
                                          confirmPasswordController.text.trim(),
                                    ),
                                  );
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

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
