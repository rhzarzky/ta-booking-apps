// ignore_for_file: depend_on_referenced_packages

import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:Appointly/module/auth/presentation/bloc/auth_bloc.dart';
import 'package:Appointly/module/onboarding/presentation/screen/onboarding_screen.dart';
import 'package:Appointly/module/profile/presentation/screen/change_password_screen.dart';
import 'package:Appointly/module/profile/presentation/screen/personal_info_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool showOnboarding = true;

  final List<Map<String, dynamic>> settingsItems = [
    {
      'iconPath': 'assets/icons/icon-profile.svg',
      'title': 'Personal Information',
      'titleColor': null,
    },
    {
      'iconPath': 'assets/icons/icon-security.svg',
      'title': 'Change Password',
      'titleColor': null,
    },
    {
      'iconPath': 'assets/icons/icon-logout.svg',
      'title': 'Logout Account',
      'titleColor': ColorPallete.redCinnabar,
    },
  ];

  void completeOnboarding() {
    setState(() {
      showOnboarding = false;
    });
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Logout',
            style: GoogleFonts.sourceSans3(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: ColorPallete.darkBlack,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: GoogleFonts.ubuntu(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: ColorPallete.darkGreySilver,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
              },
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
                Navigator.pop(context); // Tutup dialog
                context.read<AuthBloc>().add(LogoutUser()); // Trigger logout
              },
              child: Text(
                'Logout',
                style: GoogleFonts.ubuntu(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: ColorPallete.redCinnabar,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OnboardingScreen(
                onComplete: completeOnboarding,
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: ColorPallete.backgroundBody,
        appBar: _buildAppBar(),
        body: ListView(
          children: [
            _buildProfileHeader(),
            _buildAccountSettings(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      title: Text(
        'My Profile',
        style: GoogleFonts.sourceSans3(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: ColorPallete.darkBlack,
        ),
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
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/image/Gradient-BG.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          left: 24,
          bottom: 40,
          child: Row(
            children: [
              const CircleAvatar(
                backgroundImage: AssetImage('assets/image/avatar.png'),
                radius: 64,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'John Doe',
                    style: GoogleFonts.ubuntu(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'JohnDoe@gmail.com',
                    style: GoogleFonts.ubuntu(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSettings() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Account Settings',
              style: GoogleFonts.ubuntu(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: ColorPallete.darkBlack,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: settingsItems.length,
            itemBuilder: (context, index) {
              final item = settingsItems[index];
              return _buildSettingItem(
                iconPath: item['iconPath'],
                title: item['title'],
                onTap: () {
                  if (index == 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PersonalInfoScreen(),
                      ),
                    );
                  } else if (index == 1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChangePasswordScreen(),
                      ),
                    );
                  } else if (index == 2) {
                    _showLogoutConfirmationDialog(
                        context); // Tampilkan dialog konfirmasi
                  }
                },
                titleColor: item['titleColor'],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required String iconPath,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return ListTile(
      leading: SvgPicture.asset(iconPath),
      title: Text(
        title,
        style: GoogleFonts.ubuntu(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: titleColor ?? ColorPallete.darkBlack,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_outward_sharp,
        color: ColorPallete.greySilverChalice,
      ),
      onTap: onTap,
    );
  }
}
