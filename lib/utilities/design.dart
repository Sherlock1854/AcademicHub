import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Design{
  final primaryColor = Color.fromRGBO(185, 211, 251, 1); //blue
  final secondaryColor = Color.fromRGBO(231,238,253,1); //light blue
  final primaryButton = Color.fromRGBO(255, 236, 185, 1); //yellow
  final secondaryButton = Color.fromRGBO(236, 157, 171, 1); //pink
  final submitButton = Color.fromRGBO(180, 248, 200, 1); //green
  final titleText = GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 38);
  final subtitleText = GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 26);
  final contentText = GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18);
  final captionText = GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 12, color: Colors.grey);
  final pieChartText = GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white);
  final pieChartInnerTitle = GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54);
  final pieChartInnerText = GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87);
  final detailText = GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black54);
  final viewAllText = GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black);
  final recordImportantText = GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold);
  final filterTitle = GoogleFonts.poppins(fontSize: 16);
  final labelTitle = GoogleFonts.poppins(fontSize: 12);
  final saveRecordText = GoogleFonts.poppins(fontSize: 16, color: Colors.black);
  final formTitleText = GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500);

  static const Map<String, Color> _categoryColors = {
    'shops': Colors.blue,
    'food': Colors.green,
    'entertainment': Colors.orange,
    'repairs': Colors.purple,
    'health': Colors.red,
    'travel': Colors.teal,
    'transport': Colors.cyan,
    'utility': Colors.pink,
    'salary': Colors.blue,
    'investments': Colors.green,
    'bonus': Colors.orange,
    'others': Colors.purple,
  };

  Color categoryColor(String category) {
    return _categoryColors[category.toLowerCase()] ?? Colors.grey.shade400;
  }

  static const Map<String, IconData> _categoryIcons = {
    'shops': Icons.shopping_cart,
    'food': Icons.fastfood,
    'entertainment': Icons.movie,
    'repairs': Icons.build,
    'health': Icons.health_and_safety,
    'travel': Icons.card_travel,
    'transport': Icons.directions_bus,
    'utility': Icons.power,
    'salary': Icons.monetization_on,
    'investments': Icons.trending_up,
    'bonus': Icons.card_giftcard,
    'others': Icons.more_horiz,
  };

  IconData categoryIcon(String category) => _categoryIcons[category.toLowerCase()] ?? Icons.category;
}