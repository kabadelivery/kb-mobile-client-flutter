import 'package:flutter/material.dart';

class TagCarousel extends StatefulWidget {
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
  State<TagCarousel> createState() => _TagCarouselState();
}

class _TagCarouselState extends State<TagCarousel> {
  @override
  Widget build(BuildContext context) {
    final double chipWidth = (MediaQuery.of(context).size.width - 48) / 4;

    // Split filters into pages of 8
    final pages = <List<String>>[];
    for (int i = 0; i < widget.allFilters.length; i += 8) {
      pages.add(widget.allFilters.sublist(
        i,
        (i + 8 > widget.allFilters.length)
            ? widget.allFilters.length
            : i + 8,
      ));
    }

    return SizedBox(
      height: 130,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.95),
        scrollDirection: Axis.horizontal,
        itemCount: pages.length,
        itemBuilder: (context, pageIndex) {
          final filters = pages[pageIndex];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int row = 0; row < 2; row++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(4, (col) {
                        int index = row * 4 + col;
                        if (index >= filters.length) {
                          return SizedBox(width: chipWidth);
                        }

                        final filter = filters[index];
                        final isSelected =
                            widget.selectedFilter == filter;

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

                        return Container(
                          margin: EdgeInsets.only(left: 4),
                          child: ChoiceChip(
                            materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                            labelPadding:
                            const EdgeInsets.symmetric(horizontal: 6),
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    "#$filter",
                                    maxLines: 1,
                                    overflow: TextOverflow.fade,
                                    softWrap: false,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (emoji.isNotEmpty) ...[
                                  const SizedBox(width: 3),
                                  Text(emoji,
                                      style:
                                      const TextStyle(fontSize: 14)),
                                ],
                              ],
                            ),
                            showCheckmark: false,
                            selected: isSelected,
                            selectedColor: widget.primaryColor,
                            backgroundColor: Colors.grey.shade200,
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.transparent
                                  : Colors.red.shade700, // blood red border
                              width: 1.4,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            onSelected: (_) => widget.onSelect(filter),
                          ),
                        );
                      }),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
