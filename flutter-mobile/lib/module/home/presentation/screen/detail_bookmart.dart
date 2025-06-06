import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:Appointly/module/home/presentation/widget/item_card_bookmark.dart';
import 'package:Appointly/module/meetings/model/saved_service_model.dart';
import 'package:Appointly/module/meetings/repository/saved_service_repository.dart';
import 'package:Appointly/module/meetings/presentation/screen/detail_meeting_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Appointly/module/meetings/presentation/bloc/service_bloc.dart';

class DetailBookmark extends StatefulWidget {
  final String title;
  const DetailBookmark({
    super.key,
    required this.title,
  });

  @override
  State<DetailBookmark> createState() => _DetailBookmarkState();
}

class _DetailBookmarkState extends State<DetailBookmark> {
  final _savedServiceRepository = SavedServiceRepository();

  Future<void> _removeService(int serviceId) async {
    await _savedServiceRepository.removeService(serviceId);
    setState(() {}); // Refresh the UI

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Service removed from bookmarks'),
        backgroundColor: ColorPallete.primaryDark,
      ),
    );
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
                widget.title,
                style: GoogleFonts.sourceSans3(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: ColorPallete.darkBlack,
                ),
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          child: Column(
            children: [
              FutureBuilder<List<SavedServiceModel>>(
                future: widget.title == 'Online Collection'
                    ? _savedServiceRepository.getOnlineServices()
                    : _savedServiceRepository.getOfflineServices(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final services = snapshot.data ?? [];
                  if (services.isEmpty) {
                    return Center(
                      child: Text(
                        'No saved ${widget.title} yet',
                        style: GoogleFonts.sourceSans3(
                          fontSize: 16,
                          color: ColorPallete.darkBlack,
                        ),
                      ),
                    );
                  }

                  return Expanded(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: services.map((service) {
                          return Dismissible(
                            key: Key(service.id.toString()),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.only(right: 20),
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (direction) {
                              _removeService(service.id);
                            },
                            child: ItemCardBookmark(
                              titleCard: service.title,
                              descCard: service.description,
                              imageCard: service.image ?? '',
                              locationCard: service.location,
                              statusCard: 'Saved',
                              onTap: () {
                                context
                                    .read<ServiceBloc>()
                                    .add(GetServiceIdEvent(id: service.id));
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DetailMeetingScreenProvider(
                                      bookingId:
                                          0, // Since this is from bookmarks, no booking yet
                                      serviceId: service.id,
                                      userId:
                                          '0', // Since this is from bookmarks, no user context needed
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
