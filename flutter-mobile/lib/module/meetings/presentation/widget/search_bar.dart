import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Appointly/module/meetings/presentation/bloc/service_bloc.dart';
import 'package:Appointly/module/meetings/presentation/screen/detail_meeting_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';

class CustomSearchBar extends StatefulWidget {
  final Function(String, List<dynamic>) onSearch;
  final String userId;
  final int bookingId;

  const CustomSearchBar({
    required this.onSearch,
    required this.userId,
    required this.bookingId,
    Key? key,
  }) : super(key: key);

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final SearchController _controller = SearchController();
  final Logger _logger = Logger();
  List<dynamic> _filteredServices = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _filterServices(String searchText, List<dynamic> allServices) {
    if (searchText.isEmpty) {
      setState(() {
        _filteredServices = [];
        _isSearching = false;
      });
      widget.onSearch('', []);
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final searchLower = searchText.toLowerCase();
    try {
      final filtered = allServices.where((service) {
        final titleMatch = service.title.toLowerCase().contains(searchLower);
        final descMatch =
            service.description.toLowerCase().contains(searchLower);
        final locationMatch =
            service.location.toLowerCase().contains(searchLower);

        bool daysMatch = false;
        if (service.days != null) {
          for (var day in service.days) {
            if (day.toString().toLowerCase().contains(searchLower)) {
              daysMatch = true;
              break;
            }
          }
        }

        bool optionMatch = false;
        if (service.option != null) {
          for (var option in service.option) {
            if (option.toString().toLowerCase().contains(searchLower)) {
              optionMatch = true;
              break;
            }
          }
        }

        return titleMatch ||
            descMatch ||
            locationMatch ||
            daysMatch ||
            optionMatch;
      }).toList();

      setState(() {
        _filteredServices = filtered;
      });
      widget.onSearch(searchText, filtered);
      _logger.d('Filtered services: ${filtered.length}');
    } catch (e) {
      _logger.e('Error filtering services: $e');
      setState(() {
        _filteredServices = [];
      });
      widget.onSearch(searchText, []);
    }
  }

  void _clearSearch() {
    _controller.clear();
    setState(() {
      _filteredServices = [];
      _isSearching = false;
    });
    widget.onSearch('', []);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServiceBloc, ServiceState>(
      builder: (context, state) {
        List<dynamic> allServices = [];
        if (state is ServiceLoaded) {
          allServices = state.services;
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Modern Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SearchAnchor.bar(
                searchController: _controller,
                barHintText: 'Find a service...',
                barHintStyle: WidgetStateProperty.all(
                  GoogleFonts.ubuntu(
                    color: ColorPallete.darkGreySilver.withOpacity(0.6),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                barLeading: Icon(
                  Icons.search_rounded,
                  color: ColorPallete.primary400,
                ),
                barTrailing: _controller.text.isNotEmpty
                    ? [
                        IconButton(
                          onPressed: _clearSearch,
                          icon: Icon(
                            Icons.close_rounded,
                            color: ColorPallete.darkGreySilver,
                            size: 20,
                          ),
                        ),
                      ]
                    : [],
                barShape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                barElevation: WidgetStateProperty.all(0),
                barBackgroundColor: WidgetStateProperty.all(Colors.white),
                viewConstraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.75,
                ),
                onChanged: (text) {
                  _logger.d('Searching: $text');
                  _filterServices(text, allServices);
                },
                onSubmitted: (text) {
                  _filterServices(text, allServices);
                },
                viewLeading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_rounded,
                    size: 18,
                    color: ColorPallete.primary400,
                  ),
                  onPressed: () {
                    _controller.closeView(_controller.text);
                  },
                ),
                viewTrailing: [
                  IconButton(
                    onPressed: _clearSearch,
                    icon: Icon(
                      Icons.close_rounded,
                      color: ColorPallete.darkGreySilver,
                      size: 20,
                    ),
                  ),
                ],
                viewHintText: 'What service are you looking for?',
                viewBackgroundColor: Colors.white,
                viewElevation: 4,
                viewShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                suggestionsBuilder:
                    (BuildContext context, SearchController controller) {
                  if (controller.text.isEmpty) {
                    return [];
                  }

                  if (_filteredServices.isEmpty) {
                    return [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 16),
                              Icon(
                                Icons.search_off_rounded,
                                size: 48,
                                color: ColorPallete.darkGreySilver
                                    .withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No services found',
                                style: GoogleFonts.ubuntu(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: ColorPallete.darkGreySilver,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try different keywords',
                                style: GoogleFonts.ubuntu(
                                  fontSize: 14,
                                  color: ColorPallete.darkGreySilver
                                      .withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ];
                  }

                  return _filteredServices.map((service) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: 12.0,
                      ),
                      child: Card(
                        color: Colors.white,
                        elevation: 0,
                        shadowColor: ColorPallete.primary400.withOpacity(0.7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: ColorPallete.primaryDark.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            controller.closeView(service.title);
                            _controller.text = service.title;

                            context.read<ServiceBloc>().add(
                                  GetServiceIdEvent(id: service.id),
                                );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DetailMeetingScreenProvider(
                                  bookingId: widget.bookingId,
                                  serviceId: service.id,
                                  userId: widget.userId,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                // Service Image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: SizedBox(
                                    width: 70,
                                    height: 70,
                                    child: (service.image != null &&
                                            service.image.isNotEmpty)
                                        ? service.image.startsWith('http')
                                            ? Image.network(
                                                service.image,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    Image.asset(
                                                        'assets/image/404page.png',
                                                        fit: BoxFit.cover),
                                              )
                                            : Image.asset(service.image,
                                                fit: BoxFit.cover)
                                        : Image.asset(
                                            'assets/image/404page.png',
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Service Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        service.title,
                                        style: GoogleFonts.ubuntu(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: ColorPallete.darkBlack,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        service.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.ubuntu(
                                          fontSize: 14,
                                          color: ColorPallete.darkGreySilver,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Arrow icon
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: ColorPallete.primary400,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.arrow_outward_rounded,
                                    size: 24,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList();
                },
              ),
            ),

            // Search Results
            if (_isSearching && !_controller.isOpen)
              Expanded(
                child: _filteredServices.isNotEmpty
                    ? ListView.builder(
                        padding: const EdgeInsets.only(top: 16.0),
                        itemCount: _filteredServices.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final service = _filteredServices[index];
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: 12.0,
                              left: 8.0,
                              right: 8.0,
                            ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {
                                    // Navigate to detail view
                                    context.read<ServiceBloc>().add(
                                          GetServiceIdEvent(id: service.id),
                                        );
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DetailMeetingScreenProvider(
                                          bookingId: widget.bookingId,
                                          serviceId: service.id,
                                          userId: widget.userId,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // Service Image
                                        Hero(
                                          tag: 'service_image_${service.id}',
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: SizedBox(
                                              width: 80,
                                              height: 80,
                                              child: (service.image != null &&
                                                      service.image.isNotEmpty)
                                                  ? service.image
                                                          .startsWith('http')
                                                      ? Image.network(
                                                          service.image,
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (context,
                                                                  error,
                                                                  stackTrace) =>
                                                              Image.asset(
                                                                  'assets/image/404page.png',
                                                                  fit: BoxFit
                                                                      .cover),
                                                        )
                                                      : Image.asset(
                                                          service.image,
                                                          fit: BoxFit.cover)
                                                  : Image.asset(
                                                      'assets/image/404page.png',
                                                      fit: BoxFit.cover,
                                                    ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        // Service Details
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                service.title,
                                                style: GoogleFonts.ubuntu(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: ColorPallete.darkBlack,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                service.description,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.ubuntu(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: ColorPallete
                                                      .darkGreySilver,
                                                ),
                                              ),
                                              // Location indicator if available
                                              if (service.location != null &&
                                                  service.location.isNotEmpty)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 6.0),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                          Icons
                                                              .location_on_outlined,
                                                          size: 14,
                                                          color: ColorPallete
                                                              .primary400),
                                                      const SizedBox(width: 4),
                                                      Expanded(
                                                        child: Text(
                                                          service.location,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: GoogleFonts
                                                              .ubuntu(
                                                            fontSize: 12,
                                                            color: ColorPallete
                                                                .darkGreySilver,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // View button
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: ColorPallete.primary400
                                                .withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.arrow_forward_rounded,
                                            size: 16,
                                            color: ColorPallete.primary400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : // No results found
                    Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/image/404page.png',
                                height: 120,
                                width: 120,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No services found for "${_controller.text}"',
                                style: GoogleFonts.ubuntu(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: ColorPallete.darkBlack,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try searching with different keywords',
                                style: GoogleFonts.ubuntu(
                                  fontSize: 14,
                                  color: ColorPallete.darkGreySilver,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
          ],
        );
      },
    );
  }
}
