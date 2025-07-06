import 'package:flutter/material.dart';

class CourseCard extends StatelessWidget {
  final String courseTitle;
  final String courseSubtitle;
  final String teacherInitial;

  const CourseCard({
    super.key,
    required this.courseTitle,
    required this.courseSubtitle,
    required this.teacherInitial,
  });

  @override
  Widget build(BuildContext context) {
    const double fixedCardWidth = 380.0; // Your desired fixed width
    const double fixedCardHeight = 120.0; // <--- INCREASED HEIGHT HERE. Adjust this value!

    // Calculate space needed for the circle and a margin
    const double circleAreaReservedWidth = (25.0 * 2) + 16.0 + 8.0;

    return Align(
      child: SizedBox(
        width: fixedCardWidth,
        height: fixedCardHeight, // <--- Apply the fixed height here
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 2,
          clipBehavior: Clip.antiAlias,
          child: Container(
            color: const Color(0xFFE0ECFC),
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: circleAreaReservedWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Course Title
                      Text(
                        courseTitle,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Course Subtitle
                      Text(
                        courseSubtitle,
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Teacher Initial Circle Avatar
                Positioned(
                  top: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white,
                    child: Text(
                      teacherInitial,
                      style: const TextStyle(
                        color: Color(0xFF3F51B5),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}