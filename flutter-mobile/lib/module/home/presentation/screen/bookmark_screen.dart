import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:Appointly/module/home/presentation/screen/detail_bookmart.dart';
import 'package:Appointly/module/home/presentation/widget/card_bookmarks.dart';
import 'package:Appointly/module/meetings/repository/saved_service_repository.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BookmarkScreen extends StatefulWidget {
  final String? serviceType;
  const BookmarkScreen({
    super.key,
    this.serviceType,
  });

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  // Repository to manage saved services
  final SavedServiceRepository _savedServiceRepository =
      SavedServiceRepository();
  // Initialize the counts for online and offline services
  int _onlineCount = 0;
  int _offlineCount = 0;

  Future<void> _loadSavedServicesCounts() async {
    final onlineServices = await _savedServiceRepository.getOnlineServices();
    final offlineServices = await _savedServiceRepository.getOfflineServices();

    setState(() {
      _onlineCount = onlineServices.length;
      _offlineCount = offlineServices.length;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSavedServicesCounts();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: ColorPallete.backgroundBody, 
          appBar: AppBar(
            automaticallyImplyLeading: false,
            foregroundColor: Colors.white,
            backgroundColor: Colors.white,
            scrolledUnderElevation: 0,
            elevation: 0,
            shadowColor: Colors.transparent,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: ColorPallete.darkBlack,
                  ),
                ),
                Text(
                  'Service Collection',
                  style: GoogleFonts.sourceSans3(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: ColorPallete.darkBlack,
                  ),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              CardBookmarks(
                  itemCount: _onlineCount,
                  title: 'Online Collection',
                  onArrowTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetailBookmark(title: 'Online Collection'),
                      ),
                    ).then((_) => _loadSavedServicesCounts());
                  },
                  startColor: ColorPallete.primaryDark,
                  endColor: ColorPallete.primary50,
                  isOnline: true,
                  isOffline: false),
              CardBookmarks(
                itemCount: _offlineCount,
                title: 'Offline Collection',
                onArrowTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DetailBookmark(title: 'Offline Collection'),
                    ),
                  ).then((_) => _loadSavedServicesCounts());
                },
                startColor: ColorPallete.primaryDark,
                endColor: ColorPallete.primary50,
                isOnline: false,
                isOffline: true,
              ),
            ],
          )),
    );
  }
}
