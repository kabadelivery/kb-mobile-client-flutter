import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:flutter/material.dart';
import 'package:KABA/src/StateContainer.dart';

class SingleSelectList extends StatefulWidget {
  final List<ListItem> items;
  final int? initialIndex;
  final ValueChanged<int>? onChanged;
  final ValueChanged<String>? onItemSelected; // 👈 callback for logo or direct selection

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
  String? _selectedLogo; // 👈 track selected logo

  void _showBottomSheet(ListItem item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        Widget content;

        // 👇 Decide what to show depending on the clicked item
        if (item.title == "Mobile Money") {
          content = Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLogo("assets/images/png/tmoney_logo.png", "Mix"),
              _buildLogo("assets/images/png/moov_africa_logo.png", "Flooz"),
              _buildLogo("assets/images/jpg/mtn_logo.jpg", "MTN"),
              _buildLogo("assets/images/png/wave_logo.png", "Wave"),
            ],
          );
        } else if (item.title == "Carte Bancaire") {
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
          content = const Text("Votre Solde est de 0");
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
                child: const Text("Fermer"),
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
        setState(() => _selectedLogo = label); // 👈 update state
        widget.onItemSelected?.call(label); // 👈 send selection to parent
        Navigator.pop(context); // close bottomsheet
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

            // 👇 Special case: if item == "PorteFeuille KABA"
            if (item.title == "PorteFeuille KABA") {
              widget.onItemSelected?.call("PorteFeuille");
            } else {
              _showBottomSheet(item); // open bottomsheet for others
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
                      Text(
                        item.subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color:
                          isSelected ? Colors.black : Colors.grey.shade600,
                        ),
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
