import 'package:flutter/material.dart';

class CustomSearchBar extends StatefulWidget {
  const CustomSearchBar({super.key});

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final SearchController _controller = SearchController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SearchAnchor.bar(
      searchController: _controller,
      barHintText: 'Search any services',
      barLeading: const Icon(Icons.search),
      barTrailing: [
        // IconButton(
        //   onPressed: () {
        //     _controller.clear();
        //   },
        //   icon: const Icon(Icons.close),
        // ),
      ],
      barShape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      barElevation: WidgetStateProperty.all(0),
      barBackgroundColor: WidgetStateProperty.all(Colors.white),
      viewConstraints: const BoxConstraints(maxHeight: 350),
      onChanged: (text) {
        // Add your search logic here
        print('Searching: $text');
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
          },
          icon: const Icon(Icons.close),
        ),
      ],
      viewHintText: 'Type to search...',
      viewBackgroundColor: Colors.white,
      viewElevation: 8,
      viewShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      suggestionsBuilder: (BuildContext context, SearchController controller) {
        return List<ListTile>.generate(5, (int index) {
          final String item = 'item $index';
          return ListTile(
            leading: const Icon(Icons.history),
            title: Text(item),
            onTap: () {
              setState(() {
                controller.closeView(item);
                _controller.text = item;
              });
            },
            trailing: IconButton(
              icon: const Icon(Icons.north_west),
              onPressed: () {
                setState(() {
                  controller.closeView(item);
                  _controller.text = item;
                });
              },
            ),
          );
        });
      },
    );
  }
}
