import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Appointly/module/meetings/presentation/bloc/service_bloc.dart';
import 'package:Appointly/module/meetings/presentation/screen/detail_meeting_screen.dart';
import 'package:logger/logger.dart';

class CustomSearchBar extends StatefulWidget {
  final Function onSearch;
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Filter services based on search text
  void _filterServices(String searchText, List<dynamic> allServices) {
    if (searchText.isEmpty) {
      setState(() {
        _filteredServices = [];
      });
      return;
    }

    final searchLower = searchText.toLowerCase();
    final filtered = allServices.where((service) {
      // Search by title
      final titleMatch = service.title.toLowerCase().contains(searchLower);

      // Search by description
      final descMatch = service.description.toLowerCase().contains(searchLower);

      // Search by location
      final locationMatch =
          service.location.toLowerCase().contains(searchLower);

      // Search by days
      final daysMatch =
          service.days.any((day) => day.toLowerCase().contains(searchLower));

      // Search by service options (Online/Offline)
      final optionMatch = service.option
          .any((option) => option.toLowerCase().contains(searchLower));

      return titleMatch ||
          descMatch ||
          locationMatch ||
          daysMatch ||
          optionMatch;
    }).toList();

    setState(() {
      _filteredServices = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServiceBloc, ServiceState>(
      builder: (context, state) {
        List<dynamic> allServices = [];

        if (state is ServiceLoaded) {
          allServices = state.services;
        }

        return SearchAnchor.bar(
          searchController: _controller,
          barHintText: 'Search any services',
          barLeading: const Icon(Icons.search),
          barTrailing: [],
          barShape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          barElevation: WidgetStateProperty.all(0),
          barBackgroundColor: WidgetStateProperty.all(Colors.white),
          viewConstraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6),
          onChanged: (text) {
            _logger.d('Searching: $text');
            _filterServices(text, allServices);
            widget.onSearch(text);
          },
          viewLeading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              _controller.closeView(_controller.text);
            },
          ),
          viewTrailing: [
            IconButton(
              onPressed: () {
                _controller.clear();
                setState(() {
                  _filteredServices = [];
                });
                widget.onSearch('');
              },
              icon: const Icon(Icons.close_rounded),
            ),
          ],
          viewHintText: 'Type to search services...',
          viewBackgroundColor: Colors.white,
          viewElevation: 8,
          viewShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          suggestionsBuilder:
              (BuildContext context, SearchController controller) {
            if (_filteredServices.isEmpty) {
              return [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'No matching services found',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
              ];
            }

            return _filteredServices
                .map((service) => Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 8.0),
                      child: Card(
                        child: InkWell(
                          onTap: () {
                            controller.closeView(service.title);
                            _controller.text = service.title;

                            // Navigate to detail view
                            context
                                .read<ServiceBloc>()
                                .add(GetServiceIdEvent(id: service.id));
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailMeetingScreen(
                                  bookingId: widget.bookingId,
                                  serviceId: service.id,
                                  userId: widget.userId,
                                ),
                              ),
                            );
                          },
                          child: ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: (service.image != null &&
                                        service.image.isNotEmpty)
                                    ? DecorationImage(
                                        image: service.image.startsWith('http')
                                            ? NetworkImage(service.image)
                                            : AssetImage(service.image)
                                                as ImageProvider,
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: (service.image == null ||
                                      service.image.isEmpty)
                                  ? Icon(Icons.image_not_supported)
                                  : null,
                            ),
                            title: Text(
                              service.title,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              service.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Icon(Icons.arrow_forward_ios, size: 16),
                          ),
                        ),
                      ),
                    ))
                .toList();
          },
        );
      },
    );
  }
}
