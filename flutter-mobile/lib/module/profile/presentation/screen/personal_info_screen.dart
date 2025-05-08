import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:Appointly/module/profile/model/profile_model.dart';
import 'package:Appointly/module/profile/presentation/bloc/profile_bloc.dart';
import 'package:Appointly/module/profile/presentation/widget/button.dart';
import 'package:Appointly/module/profile/presentation/widget/field_profile.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:logger/logger.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
  XFile? _selectedImage; // For newly selected images
  String? _currentProfileImageUrl;

  @override
  void initState() {
    super.initState();
    emailController.addListener(_updateButtonVisibility);
    fullNameController.addListener(_updateButtonVisibility);

    context.read<ProfileBloc>().add(GetProfileEvent());
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

  // Method to pick an image from the gallery
  Future<void> pickImageFromGallery() async {
    final imagePicker = ImagePicker();
    try {
      final pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800, // Optional: resize gambar
        maxHeight: 800, // Optional: resize gambar
        imageQuality: 85, // Kualitas gambar (0-100)
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = pickedFile;
          _currentProfileImageUrl = pickedFile.path;
        });
      }
    } catch (e) {
      _logger.e("Error picking image from gallery: $e");
    }
  }

  Future<void> pickImageFromCamera() async {
    final imagePicker = ImagePicker();
    try {
      final pickedFile = await imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = pickedFile;
          _currentProfileImageUrl = pickedFile.path;
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

  void _updateProfile() {
    final profile = ProfileModel(
      name: fullNameController.text.isNotEmpty ? fullNameController.text : null,
      email: emailController.text.isNotEmpty ? emailController.text : null,
    );

    context.read<ProfileBloc>().add(UpdateProfileEvent(
          profile: profile,
          imagePath: _selectedImage?.path,
        ));
  }


  @override
  Widget build(BuildContext context) {
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return BlocConsumer<ProfileBloc, ProfileState>(builder: (context, state) {
      return Scaffold(
        backgroundColor: ColorPallete.backgroundBody,
        appBar: _buildAppBar(),
        body: state is ProfileLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        _buildProfileHeader(),
                        _fieldItem(isKeyboardVisible),
                        _passwordChangeSection(isKeyboardVisible),
                        SizedBox(height: 80), // Add space for the button
                      ],
                    ),
                  ),
                  // Fixed positioned button at the bottom
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Button(
                      text: 'Save Changes',
                      onTap: _updateProfile,
                    ),
                  ),
                ],
              ),
      );
    }, listener: (context, state) {
      if (state is ProfileLoaded) {
        fullNameController.text = state.profile.name ?? "";
        emailController.text = state.profile.email ?? "";

        setState(() {
          _currentProfileImageUrl = state.profile.image;
        });
      } else if (state is ProfileSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        context.read<ProfileBloc>().add(GetProfileEvent());
        Navigator.pop(context);
      } else if (state is ProfileError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${state.failure}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
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

  ImageProvider _getProfileImage() {
    if (_selectedImage != null) {
      return FileImage(File(_selectedImage!.path));
    } else if (_currentProfileImageUrl != null &&
        _currentProfileImageUrl!.isNotEmpty) {
      return NetworkImage(_currentProfileImageUrl!);
    } else {
      return AssetImage('assets/image/avatar.png') as ImageProvider;
    }
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
                onTap: _showImagePickerDialog,
                child: CircleAvatar(
                  backgroundImage: _getProfileImage(),
                  radius: 64,
                  child: ClipOval(
                    child: _selectedImage != null
                        ? Image.file(
                            File(_selectedImage!.path),
                            width: 128,
                            height: 128,
                            fit: BoxFit.cover,
                          )
                        : (_currentProfileImageUrl != null &&
                                _currentProfileImageUrl!.isNotEmpty)
                            ? CachedNetworkImage(
                                imageUrl: _currentProfileImageUrl!,
                                width: 128,
                                height: 128,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              )
                            : Image.asset('assets/image/avatar.png'),
                  ),
                ),
              ),
              SizedBox(height: 8.0),
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
    return Padding(
      padding: const EdgeInsets.only(
        top: 24.0,
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
        ],
      ),
    );
  }

  Widget _passwordChangeSection(bool isKeyboardVisible) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 24.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 32.0),
        ],
      ),
    );
  }
}
