import 'package:KABA/src/ui/screens/newAuth/colors.dart';
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

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10,),
          _buildRow(topRow),
          _buildRow(bottomRow),
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
        if (filter.toLowerCase().contains('promo')) emoji = '🔥';
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
        else if (filter.toLowerCase().contains('glac')) emoji = '🍦';
        else if (filter.toLowerCase().contains('jus')) emoji = '🧃';
        else if (filter.toLowerCase().contains('smooth')) emoji = '🥤';
        else if (filter.toLowerCase().contains('milk')) emoji = '🥛';
        else if (filter.toLowerCase().contains('thé')) emoji = '🍵';
        else if (filter.toLowerCase().contains('crep') || filter.toLowerCase().contains('crêp')) emoji = '🥞';
        else if (filter.toLowerCase().contains('bouill')) emoji = '🥣';

        bool isPromo =  filter.toLowerCase().contains("promo");
        return ChoiceChip(
          labelPadding: const EdgeInsets.symmetric(horizontal: 6),
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isPromo?"$filter":"#$filter",
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected && !isPromo? Colors.white : Colors.black,
                  fontWeight:
                  isSelected && !isPromo? FontWeight.bold : FontWeight.w500,
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
          selectedColor:isPromo?Colors.green.withOpacity(.2): primaryColor.withOpacity(.8),
          backgroundColor: Colors.grey.shade200,
          side: BorderSide(
            color: isSelected
                ?isPromo?Colors.green.withOpacity(.5): Colors.transparent
                : AuthColors.inputBorder,
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
