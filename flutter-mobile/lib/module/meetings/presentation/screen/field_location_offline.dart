import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:Appointly/module/meetings/presentation/widget/custom_text_field.dart';
import 'package:Appointly/module/profile/presentation/widget/button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FieldLocationOffline extends StatefulWidget {
  const FieldLocationOffline({super.key});

  @override
  State<FieldLocationOffline> createState() => _FieldLocationOfflineState();
}

class _FieldLocationOfflineState extends State<FieldLocationOffline> {
  final formKey = GlobalKey<FormState>();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final provinceController = TextEditingController();
  final postalCodeController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPallete.backgroundBody,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        title: Row(
          spacing: 8.0,
          children: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back_rounded),
            ),
            Text(
              'Location',
              style: GoogleFonts.sourceSans3(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: ColorPallete.darkBlack,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: ListView(
            padding: EdgeInsets.only(
              right: 16.0,
              left: 16.0,
              top: 24.0,
              bottom: 24.0,
            ),
            children: [
              _buildHeader(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16.0,
                children: [
                  CustomTextField(
                    controller: addressController,
                    hintText: 'your adress',
                    labelText: 'Address',
                  ),
                  CustomTextField(
                    controller: cityController,
                    hintText: 'your city',
                    labelText: 'City',
                  ),
                  CustomTextField(
                    controller: provinceController,
                    hintText: 'your proviance',
                    labelText: 'Proviance',
                  ),
                  CustomTextField(
                    controller: postalCodeController,
                    hintText: 'your postal code',
                    labelText: 'Postal Code',
                  ),
                ],
              ),
              SizedBox(
                height: 24.0,
              ),
              Button(
                onTap: () {},
                text: 'Save Location',
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Specify your meeting location',
            style: GoogleFonts.ubuntu(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: ColorPallete.darkBlack,
            ),
          ),
          SizedBox(
            height: 8.0,
          ),
          Text(
            'Enter the specific address to ensure a clear appoinment location',
            style: GoogleFonts.ubuntu(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ColorPallete.darkGreySilver,
            ),
          ),
        ],
      ),
    );
  }
}
