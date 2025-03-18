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
    return Scaffold(
      appBar: AppBar(
        title: SearchAnchor.bar(
          searchController: _controller,
          viewLeading: IconButton(
            onPressed: () {
              _controller.closeView(_controller.text);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
          ),
          viewTrailing: [
            IconButton(
              onPressed: () {
                _controller.clear();
              },
              icon: const Icon(Icons.close),
            )
          ],
          viewHintText: 'Type to search',
          viewBackgroundColor: Colors.white,
          viewElevation: 8,
          viewShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          suggestionsBuilder:
              (BuildContext context, SearchController controller) {
            return List<ListTile>.generate(5, (int index) {
              final String item = 'Item $index';
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
                  onPressed: () {
                    setState(() {
                      controller.closeView(item);
                      _controller.text = item;
                    });
                  },
                  icon: const Icon(Icons.north_west),
                ),
              );
            });
          },
        ),
      ),
    );
  }
}
