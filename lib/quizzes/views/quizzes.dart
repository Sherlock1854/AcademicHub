import 'package:flutter/material.dart';

class Quizzes extends StatelessWidget {
  final String quizTitle;
  final String description;  // optional for now
  final String category;     // optional for now
  final String imageUrl;

  const Quizzes({
    Key? key,
    required this.quizTitle,
    this.description = '',
    this.category = '',
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const cardWidth = 200.0;
    const cardHeight = 220.0;

    return Card(
      margin: const EdgeInsets.only(right: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Colors.blue.shade100, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: cardWidth,
        height: cardHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // COVER IMAGE (60%)
            SizedBox(
              height: cardHeight * 0.6,
              width: double.infinity,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.broken_image)),
                ),
              ),
            ),

            // TEXT (40%)
            Container(
              color: Colors.grey[50],
              padding:
              const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              height: cardHeight * 0.4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (category.isNotEmpty) ...[
                    Text(
                      category,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    quizTitle,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  if (description.isNotEmpty)
                    Text(
                      description,
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
          ],
        ),
      ),
    );
  }
}
