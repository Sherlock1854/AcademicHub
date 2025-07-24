import 'package:flutter/material.dart';

class Course extends StatelessWidget {
  final String courseTitle;
  final String subtitle;
  final String instructorName;
  final String subject;
  final String imageUrl;

  const Course({
    super.key,
    required this.courseTitle,
    required this.subtitle,
    required this.instructorName,
    required this.subject,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    const double cardWidth = 200.0;
    const double cardHeight = 220.0;

    return Card(
      margin: const EdgeInsets.only(right: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Colors.blue.shade100, width: 1.5),
      ),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: cardWidth,
        height: cardHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOP IMAGE (60%)
            SizedBox(
              height: cardHeight * 0.6,
              width: double.infinity,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: Icon(Icons.image, color: Colors.grey[600]),
                    ),
                  );
                },
              ),
            ),

            // BOTTOM TEXT SECTION (40%)
            Container(
              color: Colors.grey[50],
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              height: cardHeight * 0.4,
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(), // prevent accidental scrolling
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Instructor and Subject
                    Text(
                      '$instructorName · $subject',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),

                    // Course Title
                    Text(
                      courseTitle,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),

                    // SUBTITLE / DESCRIPTION
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
