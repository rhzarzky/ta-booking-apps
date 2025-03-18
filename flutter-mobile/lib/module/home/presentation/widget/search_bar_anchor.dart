import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Appointly/core/theme/color_pallete.dart';
import 'dart:async';

class SearchBarAnchor extends StatefulWidget {
  const SearchBarAnchor({super.key});

  @override
  State<SearchBarAnchor> createState() => _SearchBarAnchorState();
}

class _SearchBarAnchorState extends State<SearchBarAnchor> {
  String? _currentQuery;
  late Iterable<Widget> _lastOptions = <Widget>[];
  late final _Debounceable<Iterable<String>?, String> _debouncedSearch;
  static const Duration debounceDuration = Duration(milliseconds: 500);

  Future<Iterable<String>?> _search(String query) async {
    _currentQuery = query;
    final Iterable<String> options = await _searchData(query);

    if (_currentQuery != query) {
      return null;
    }
    _currentQuery = null;

    return options;
  }

  Future<Iterable<String>> _searchData(String query) async {
    const List<String> items = <String>[
      'Appointment 1',
      'Meeting 2',
      'Event 3',
      'Conference 4',
    ];

    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (query.isEmpty) {
      return const Iterable<String>.empty();
    }

    return items.where((String item) {
      return item.toLowerCase().contains(query.toLowerCase());
    });
  }

  @override
  void initState() {
    super.initState();
    _debouncedSearch = _debounce<Iterable<String>?, String>(_search);
  }

  @override
  Widget build(BuildContext context) {
    return SearchAnchor(
      builder: (BuildContext context, SearchController controller) {
        return IconButton.filled(
          onPressed: () {
            controller.openView();
          },
          icon: SvgPicture.asset('assets/icons/icon-search.svg'),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            padding: const EdgeInsets.all(12),
          ),
          iconSize: 24,
          color: Colors.white,
        );
      },
      suggestionsBuilder:
          (BuildContext context, SearchController controller) async {
        final List<String>? options =
            (await _debouncedSearch(controller.text))?.toList();
        if (options == null) {
          return _lastOptions;
        }
        _lastOptions = List<ListTile>.generate(options.length, (int index) {
          final String item = options[index];
          return ListTile(
            title: Text(
              item,
              style: GoogleFonts.ubuntu(
                fontSize: 14,
                color: ColorPallete.darkBlack,
              ),
            ),
            onTap: () {
              controller.closeView(item);
              // Tambahkan logika ketika item dipilih
            },
          );
        });
        return _lastOptions;
      },
    );
  }
}

// Helper classes
typedef _Debounceable<S, T> = Future<S?> Function(T parameter);

_Debounceable<S, T> _debounce<S, T>(_Debounceable<S?, T> function) {
  _DebounceTimer? debounceTimer;

  return (T parameter) async {
    if (debounceTimer != null && !debounceTimer!.isCompleted) {
      debounceTimer!.cancel();
    }
    debounceTimer = _DebounceTimer();
    try {
      await debounceTimer!.future;
    } on _CancelException {
      return null;
    }
    return function(parameter);
  };
}

class _DebounceTimer {
  _DebounceTimer() {
    _timer = Timer(debounceDuration, _onComplete);
  }

  late final Timer _timer;
  final Completer<void> _completer = Completer<void>();
  static const Duration debounceDuration = Duration(milliseconds: 500);

  void _onComplete() {
    _completer.complete();
  }

  Future<void> get future => _completer.future;

  bool get isCompleted => _completer.isCompleted;

  void cancel() {
    _timer.cancel();
    _completer.completeError(const _CancelException());
  }
}

class _CancelException implements Exception {
  const _CancelException();
}
