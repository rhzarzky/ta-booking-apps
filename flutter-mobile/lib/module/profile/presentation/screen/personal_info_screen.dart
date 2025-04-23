// ignore_for_file: depend_on_referenced_packages

import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:Appointly/module/profile/presentation/screen/profile_screen.dart';
import 'package:Appointly/module/profile/presentation/widget/button.dart';
import 'package:Appointly/module/profile/presentation/widget/field_profile.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:logger/logger.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
    final Logger _logger = Logger();
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final fullNameController = TextEditingController();
  XFile? _selectedImage; // To store the selected image

  // Method to pick an image from the gallery
  Future<void> pickImageFromGallery() async {
    final imagePicker = ImagePicker();
    try {
      final pickedFile =
          await imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = pickedFile;
        });
      }
    } catch (e) {
      _logger.e("Error picking image from gallery: $e");
    }
  }

  // Method to pick an image from the camera
  Future<void> pickImageFromCamera() async {
    final imagePicker = ImagePicker();
    try {
      final pickedFile =
          await imagePicker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = pickedFile;
        });
      }
    } catch (e) {
      _logger.e("Error picking image from camera: $e");
    }
  }

  // Show a dialog to let the user choose between gallery and camera
  Future<void> _showImagePickerDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Text(
            "Choose Image Source",
            style: GoogleFonts.ubuntu(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: ColorPallete.darkBlack,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: Row(
                    children: [
                      Icon(
                        Icons.image_outlined,
                        color: ColorPallete.primaryColor,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        "Gallery",
                        style: GoogleFonts.ubuntu(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: ColorPallete.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    pickImageFromGallery();
                  },
                ),
                SizedBox(height: 20),
                GestureDetector(
                  child: Row(
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        color: ColorPallete.primaryColor,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        "Camera",
                        style: GoogleFonts.ubuntu(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: ColorPallete.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    pickImageFromCamera();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
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
    setState(() {});
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

  PreferredSizeWidget _buildAppBar() {
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
              GestureDetector(
                onTap: _showImagePickerDialog, // Show the image picker dialog
                child: CircleAvatar(
                  backgroundImage: _selectedImage != null
                      ? FileImage(
                          File(_selectedImage!.path)) // Use selected image
                      : AssetImage('assets/image/avatar.png')
                          as ImageProvider, // Default image
                  radius: 64,
                ),
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
