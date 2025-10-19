import 'package:flutter/material.dart';

class TagCarousel extends StatelessWidget {
  final List<String> allFilters;
  final String selectedFilter;
  final Function(String) onSelect;
  final Color primaryColor;

  const TagCarousel({
    Key? key,
    required this.allFilters,
    required this.selectedFilter,
    required this.onSelect,
    required this.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Split filters into two rows
    final half = (allFilters.length / 2).ceil();
    final topRow = allFilters.sublist(0, half);
    final bottomRow = allFilters.sublist(half);

    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRow(topRow),
              _buildRow(bottomRow),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> filters) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: filters.map((filter) {
        final isSelected = selectedFilter == filter;

        // 🍴 Emoji selector
        String emoji = '';
        if (filter.toLowerCase().contains('spag')) emoji = '🍝';
        else if (filter.toLowerCase().contains('poiss')) emoji = '🐟';
        else if (filter.toLowerCase().contains('fouf')) emoji = '🍲';
        else if (filter.toLowerCase().contains('akou')) emoji = '🍛';
        else if (filter.toLowerCase().contains('degue')) emoji = '🥣';
        else if (filter.toLowerCase().contains('tchin')) emoji = '🍢';
        else if (filter.toLowerCase().contains('pizz')) emoji = '🍕';
        else if (filter.toLowerCase().contains('burg')) emoji = '🍔';
        else if (filter.toLowerCase().contains('broch')) emoji = '🍡';
        else if (filter.toLowerCase().contains('poul')) emoji = '🍗';
        else if (filter.toLowerCase().contains('riz')) emoji = '🍚';
        else if (filter.toLowerCase().contains('glac')) emoji = '🍦';

        return ChoiceChip(
          labelPadding: const EdgeInsets.symmetric(horizontal: 6),
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "#$filter",
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
              if (emoji.isNotEmpty) ...[
                const SizedBox(width: 3),
                Text(emoji, style: const TextStyle(fontSize: 14)),
              ],
            ],
          ),
          showCheckmark: false,
          selected: isSelected,
          selectedColor: primaryColor,
          backgroundColor: Colors.grey.shade200,
          side: BorderSide(
            color: isSelected
                ? Colors.transparent
                : Color(0xFFFC90A8),
            width: 1.4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          onSelected: (_) => onSelect(filter),
        );
      }).toList(),
    );
  }
}
