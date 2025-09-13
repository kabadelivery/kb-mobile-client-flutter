/* Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0), // internal padding
    decoration: BoxDecoration(
      color: Color(0xFFF3F3F5), // grey background
      borderRadius: BorderRadius.circular(8), // small border radius
    ),
    child: Row(
      children: [
       Container(
  width: 40, // small square container
  height: 40,
  decoration: BoxDecoration(
    color: Color(0xFFFFC8D4), // background color
    borderRadius: BorderRadius.circular(8), // rounded corners
  ),
  child: Padding(
    padding: const EdgeInsets.all(8.0), // inner padding for the image
    child: Image.asset(
      "assets/images/png/abonnement-icons/Package.png", // your image
      fit: BoxFit.contain,
    ),
  ),
 ), SizedBox(width: 15,) , Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Livraisons",
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 4), // spacing between texts
          Text(
            "0/0",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),  
      ],
    ),
  ),
) */