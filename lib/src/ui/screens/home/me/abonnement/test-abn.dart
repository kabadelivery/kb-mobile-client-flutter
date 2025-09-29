/* // ------------------- Active Subscription Card -------------------
  Widget _buildActiveCard(Map<String, dynamic> data) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 30, bottom: 10),
            child: Row(
              children: [
                Image.asset(
                  "assets/images/png/abonnement-icons/Package.png",
                  width: 30,
                  height: 30,
                ),
                SizedBox(width: 12),
                Text(
                  "Mon abonnement",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(8)),
                  child: Text("Actif", style: TextStyle(color: Colors.white)),
                )
              ],
            ),
          ),
          _buildCardRow(
            icon: "Package.png",
            title: "Livraisons",
            subtitle: "${data["deliveriesUsed"] ?? 0}/${data["deliveriesTotal"] ?? 0}",
            isSvg: false,
            iconBgColor: Color(0xFFFFC8D4),
          ),
          _buildCardRow(
            icon: "Clock.svg",
            title: "Expire dans",
            subtitle: data["end_date"] ?? "********",
            isSvg: true,
            iconColor: Color(0xFFCD1F45),
            iconBgColor: Color(0xFFFFC8D4),
          ),
          _buildCardRow(
            icon: "code",
            title: "Code",
            subtitle: data["codeAbonnement"] ?? "********",
            isIcon: true,
            iconColor: Color(0xFFCD1F45),
            iconBgColor: Color(0xFFFFC8D4),
          ),
        ],
      ),
    );
  }


   */