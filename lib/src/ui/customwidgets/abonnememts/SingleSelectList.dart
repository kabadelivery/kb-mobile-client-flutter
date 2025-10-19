import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:flutter/material.dart';
import 'package:KABA/src/StateContainer.dart';

class SingleSelectList extends StatefulWidget {
  final List<ListItem> items;
  final int? initialIndex;
  final ValueChanged<int>? onChanged;
  final ValueChanged<String>? onItemSelected;

  const SingleSelectList({
    Key? key,
    required this.items,
    this.initialIndex,
    this.onChanged,
    this.onItemSelected,
  }) : super(key: key);

  @override
  State<SingleSelectList> createState() => _SingleSelectListState();
}

class _SingleSelectListState extends State<SingleSelectList> {
  late int? _selectedIndex = widget.initialIndex;
  String? _selectedLogo;

  void _showBottomSheet(ListItem item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        Widget content;

        if (item.title == "${AppLocalizations.of(context)!.translate('mobile_money')}") {
          content = Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLogo("assets/images/png/tmoney_logo.png", "Mix"),
              _buildLogo("assets/images/png/moov_africa_logo.png", "Flooz"),
              _buildLogo("assets/images/jpg/mtn_logo.jpg", "MTN"),
              _buildLogo("assets/images/png/wave_logo.png", "Wave"),
            ],
          );
        } else if (item.title == "${AppLocalizations.of(context)!.translate('credit_card')}") {
          content = Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLogo("assets/images/png/visa_logo.png", "Visa"),
              _buildLogo("assets/images/png/master_card_logo.png", "MasterCard"),
              _buildLogo("assets/images/png/american_express.png", "American Express"),
              _buildLogo("assets/images/png/solimi_logo.png", "Solimi"),
            ],
          );
        } else {
          content = Text("${AppLocalizations.of(context)!.translate('balance_zero_message')}");
        }

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const SizedBox(width: 10),
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              content,
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text("${AppLocalizations.of(context)!.translate('close')}"),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogo(String url, String label) {
    final isSelected = _selectedLogo == label;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedLogo = label);
        widget.onItemSelected?.call(label);
        Navigator.of(context).pop(true);
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.red : Colors.transparent,
                width: 3,
              ),
            ),
            child: CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage(url),
              backgroundColor: Colors.grey.shade200,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.red : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final isSelected = _selectedIndex == index;
        final item = widget.items[index];

        return InkWell(
          onTap: () {
            setState(() => _selectedIndex = index);
            widget.onChanged?.call(index);

            if (item.title == "${AppLocalizations.of(context)!.translate('kaba_wallet')}") {
              widget.onItemSelected?.call("${AppLocalizations.of(context)!.translate('kaba_wallet')}");
            } else {
              _showBottomSheet(item);
            }
          },
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFFE8ED) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? KColors.primaryColor : Colors.grey.shade300,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                    color: Colors.red.withOpacity(0.2),
                  ),
              ],
            ),
            child: Row(
              children: [
                Icon(item.icon,
                    color: isSelected ? KColors.primaryColor : Colors.grey[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? KColors.primaryColor : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            item.subtitle,
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected
                                  ? Colors.black
                                  : Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 5),
                          item.title == AppLocalizations.of(context)!.translate('kaba_wallet')
                              ? Text(
                            " : ${StateContainer.of(context).balance == null ? "---" : StateContainer.of(context).balance} ${AppLocalizations.of(context)!.translate('currency')}",
                            style: TextStyle(
                              color: KColors.primaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                              : Container(),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check, color: Colors.white, size: 18),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ListItem {
  final String title;
  final String subtitle;
  final IconData icon;

  ListItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
