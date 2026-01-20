import 'package:flutter/material.dart';

class PerformanceCard extends StatefulWidget {
  final double initialRating;
  final int totalReviews;

  const PerformanceCard({
    super.key,
    this.initialRating = 4.7,
    this.totalReviews = 120,
  });

  @override
  State<PerformanceCard> createState() => _PerformanceCardState();
}

class _PerformanceCardState extends State<PerformanceCard> {
  bool _isClosing = false; // Internal state example

  void _handleDismiss() async {
    setState(() {
      _isClosing = true;
    });

    // Simulate a small delay or API call before closing
    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- Header ---
              _buildHeader(),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 30),
                child: Column(
                  children: [
                    // Main Rating Display
                    _buildMainRating(),

                    Text(
                      "Basé sur ${widget.totalReviews} avis",
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),

                    const SizedBox(height: 25),

                    // Metrics List
                    _buildMetricRow(Icons.access_time, "Rapidité", "5"),
                    _buildMetricRow(Icons.location_on_outlined, "Respect de Géolocalistion", "5"),
                    _buildMetricRow(Icons.sentiment_satisfied_outlined, "Attitude des livreurs", "4,5"),
                    _buildMetricRow(Icons.person_outline, "Aspect/Image des livreurs", "4,3"),

                    const SizedBox(height: 30),

                    // --- Action Button with State Change ---
                    SizedBox(
                      width: 130,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: _isClosing ? null : _handleDismiss,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE53E65), width: 1.5),
                          shape: StadiumBorder(),
                        ),
                        child: _isClosing
                            ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE53E65))
                        )
                            : const Text(
                          "Compris",
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI Helper Methods ---

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22),
      color: const Color(0xFFE53E65),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.flash_on, color: Colors.yellow, size: 28),
          SizedBox(width: 8),
          Text(
            "Performance en temps réel",
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.sentiment_very_satisfied, color: Color(0xFFE53E65), size: 42),
        const SizedBox(width: 10),
        const Text(
          "Note actuelle ",
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        Text(
          widget.initialRating.toString().replaceAll('.', ','),
          style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: Color(0xFFE53E65)
          ),
        ),
        const Text(
          " /5",
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildMetricRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.black45, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}