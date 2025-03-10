// ignore_for_file: depend_on_referenced_packages

import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:Appointly/module/profile/presentation/screen/profile_screen.dart';
import 'package:Appointly/module/profile/presentation/widget/button.dart';
import 'package:Appointly/module/profile/presentation/widget/field_profile.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final fullNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Add listeners to the controllers to update the UI when text changes
    emailController.addListener(_updateButtonVisibility);
    fullNameController.addListener(_updateButtonVisibility);
  }

  @override
  void dispose() {
    emailController.removeListener(_updateButtonVisibility);
    fullNameController.removeListener(_updateButtonVisibility);
    emailController.dispose();
    fullNameController.dispose();
    super.dispose();
  }

  void _updateButtonVisibility() {
    setState(() {
      // This will trigger a rebuild of the widget with the updated button visibility
    });
  }

  bool _areFieldsFilled() {
    return fullNameController.text.isNotEmpty &&
        emailController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: ColorPallete.backgroundBody,
      appBar: _buildAppBar(),
      body: ListView(
        children: [
          _buildProfileHeader(),
          _fieldItem(isKeyboardVisible),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
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
            'Personal Information',
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

  Widget _buildProfileHeader() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/image/Gradient-BG.png'),
                fit: BoxFit.cover),
          ),
        ),
        Positioned(
          left: 136,
          top: 20,
          child: Column(
            children: [
              CircleAvatar(
                backgroundImage: AssetImage('assets/image/avatar.png'),
                radius: 64,
              ),
              SizedBox(
                height: 8.0,
              ),
              Text(
                'Edit my profile',
                style: GoogleFonts.sourceSans3(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _fieldItem(bool isKeyboardVisible) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(
          top: 24.0,
          bottom: 24.0,
          left: 16.0,
          right: 16.0,
        ),
        child: Column(
          children: [
            FieldProfile(
              labelText: 'Full Name',
              hintText: 'John Doe',
              controller: fullNameController,
            ),
            SizedBox(
              height: 24.0,
            ),
            FieldProfile(
              labelText: 'Email Address',
              hintText: 'JohnDoe@gmail.com',
              controller: emailController,
            ),
            SizedBox(
              height: isKeyboardVisible ? 24.0 : 320.0,
            ),
            Visibility(
              visible: _areFieldsFilled(),
              child: Button(
                text: 'Save Changes',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
