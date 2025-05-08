// ignore_for_file: depend_on_referenced_packages

import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:Appointly/module/profile/model/profile_model.dart';
import 'package:Appointly/module/profile/presentation/bloc/profile_bloc.dart';
import 'package:Appointly/module/profile/presentation/widget/button.dart';
import 'package:Appointly/module/profile/presentation/widget/field_profile.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final formKey = GlobalKey<FormState>();
  final oldPassword = TextEditingController();
  final newPassword = TextEditingController();
  final confirmPassword = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Add listeners to the controllers to update the UI when text changes
    oldPassword.addListener(_updateButtonVisibility);
    newPassword.addListener(_updateButtonVisibility);
    confirmPassword.addListener(_updateButtonVisibility);
  }

  @override
  void dispose() {
    oldPassword.removeListener(_updateButtonVisibility);
    newPassword.removeListener(_updateButtonVisibility);
    confirmPassword.removeListener(_updateButtonVisibility);
    oldPassword.dispose();
    newPassword.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  void _updateButtonVisibility() {
    setState(() {
      // This will trigger a rebuild of the widget with the updated button visibility
    });
  }

  bool _areFieldsFilled() {
    return oldPassword.text.isNotEmpty &&
        newPassword.text.isNotEmpty &&
        confirmPassword.text.isNotEmpty;
  }

  bool _isPasswordMatching() {
    return newPassword.text == confirmPassword.text;
  }

  void _updatePassword() {
    if (!_isPasswordMatching()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('New password and confirmation do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Create a profile model with only password fields
    final profile = ProfileModel(
      currentPassword: oldPassword.text,
      password: newPassword.text,
      passwordConfirmation: confirmPassword.text,
    );

    // Use the existing UpdateProfileEvent since we're using the same endpoint
    context.read<ProfileBloc>().add(UpdateProfileEvent(
          profile: profile,
          imagePath: null,
        ));
  }

  void _confirmChangePassword() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            title: Text(
              'Save New Password',
              style: GoogleFonts.sourceSans3(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: ColorPallete.darkBlack,
              ),
            ),
            content: Text(
              'Are you sure you want to change your password?',
              style: GoogleFonts.ubuntu(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: ColorPallete.darkGreySilver,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.ubuntu(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: ColorPallete.darkBlack,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _updatePassword();
                },
                child: Text(
                  'Save',
                  style: GoogleFonts.ubuntu(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: ColorPallete.primaryColor,
                  ),
                ),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Password updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.failure}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: ColorPallete.backgroundBody,
          appBar: _buildAppBar(),
          body: state is ProfileLoading
              ? Center(child: CircularProgressIndicator())
              : ListView(
                  children: [
                    _fieldItem(isKeyboardVisible),
                  ],
                ),
        );
      },
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      scrolledUnderElevation: 0,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: ColorPallete.darkBlack,
            ),
          ),
          Text(
            'Change Password',
            style: GoogleFonts.sourceSans3(
              fontSize: 20,
              color: ColorPallete.darkBlack,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldItem(bool isKeyboardVisible) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 24.0,
        bottom: 24.0,
        left: 16.0,
        right: 16.0,
      ),
      child: Column(
        children: [
          FieldProfile(
            labelText: 'Old Password',
            hintText: 'Min.8 Characters',
            controller: oldPassword,
            isPassword: true,
          ),
          SizedBox(
            height: 24.0,
          ),
          FieldProfile(
            labelText: 'New Password',
            hintText: 'Min.8 Characters',
            controller: newPassword,
            isPassword: true,
          ),
          SizedBox(
            height: 24.0,
          ),
          FieldProfile(
            labelText: 'Confirm Password',
            hintText: 'Min.8 Characters',
            controller: confirmPassword,
            isPassword: true,
          ),
          SizedBox(
            height: 32.0,
          ),
          Visibility(
            visible: _areFieldsFilled(),
            child: Button(
              text: 'Save Changes',
              onTap: _confirmChangePassword,
            ),
          ),
        ],
      ),
    );
  }
}
