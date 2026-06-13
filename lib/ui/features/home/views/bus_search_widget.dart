import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../data/repositories/bus_repository.dart';
import '../../../../domain/models/bus_suggestion.dart';

class BusSearchWidget extends StatefulWidget {
  final BusRepository busRepo;
  final double? myLat;
  final double? myLon;
  final ValueChanged<String> onAddStop;
  final VoidCallback onLocate;

  const BusSearchWidget({
    super.key,
    required this.busRepo,
    this.myLat,
    this.myLon,
    required this.onAddStop,
    required this.onLocate,
  });

  @override
  State<BusSearchWidget> createState() => _BusSearchWidgetState();
}

class _BusSearchWidgetState extends State<BusSearchWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<BusSuggestion> _suggestions = [];
  bool _showSuggestions = false;
  bool _searching = false;
  Timer? _debounceTimer;

  bool get _hasLocation =>
      widget.myLat != null && widget.myLon != null;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onInput(String val) {
    _debounceTimer?.cancel();
    if (val.trim().isEmpty) {
      setState(() {
        _showSuggestions = false;
      });
      return;
    }
    _debounceTimer = Timer(const Duration(milliseconds: 250), () {
      _doSearch(val.trim());
    });
  }

  Future<void> _doSearch(String keyword) async {
    setState(() => _searching = true);
    try {
      final results = await widget.busRepo.searchStops(
        keyword,
        myLat: widget.myLat,
        myLon: widget.myLon,
      );
      if (!mounted) return;
      setState(() {
        _suggestions = results;
        _showSuggestions = results.isNotEmpty;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  void _selectStop(BusSuggestion s) {
    widget.onAddStop(s.name);
    _controller.clear();
    setState(() => _showSuggestions = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: _onInput,
          decoration: InputDecoration(
            hintText: '搜尋站牌名稱…',
            prefixIcon: Icon(
              Icons.search,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_searching)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                IconButton(
                  icon: Icon(
                    _hasLocation
                        ? Icons.location_on
                        : Icons.location_on_outlined,
                    color: _hasLocation ? Colors.green : null,
                  ),
                  onPressed: widget.onLocate,
                ),
              ],
            ),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
        if (_showSuggestions)
          Card(
            margin: const EdgeInsets.only(top: 4),
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _suggestions.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final s = _suggestions[index];
                return ListTile(
                  dense: true,
                  title: Text(
                    s.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: s.distanceText != null
                      ? Text(
                          s.distanceText!,
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        )
                      : null,
                  onTap: () => _selectStop(s),
                );
              },
            ),
          ),
      ],
    );
  }
}
