import 'package:flutter/material.dart';
import 'package:academichub/bottom_nav.dart';
import 'package:academichub/course/models/course.dart';
import 'package:academichub/course/views/course_details_page.dart';

class CoursesPageScreen extends StatefulWidget {
  const CoursesPageScreen({super.key});

  @override
  State<CoursesPageScreen> createState() => _CoursesPageScreenState();
}

class _CoursesPageScreenState extends State<CoursesPageScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> categories = [
    'Science', 'Math', 'History', 'Literature', 'Arts', 'Technology'
  ];

  int _selectedCategoryIndex = 0;

  final Map<String, List<Map<String, dynamic>>> categorizedCourses = {
    'Science': [
      {
        'title': 'Astrophysics 101',
        'subtitle': 'Explore the wonders of the universe.',
        'instructor': 'Dr. Celeste Nova',
        'subject': 'Science',
        'imageUrl': 'https://via.placeholder.com/400x200.png?text=Astrophysics+101',
      },
      {
        'title': 'Genetics & Evolution',
        'subtitle': 'Dive into the world of biology.',
        'instructor': 'Prof. Gene Splice',
        'subject': 'Biology',
        'imageUrl': 'https://via.placeholder.com/400x200.png?text=Genetics+Evolution',
      },
      {
        'title': 'Quantum Physics Basics',
        'subtitle': 'The fundamental laws of the universe.',
        'instructor': 'Dr. Particle X',
        'subject': 'Physics',
        'imageUrl': 'https://via.placeholder.com/400x200.png?text=Quantum+Physics',
      },
    ],
    'Math': [
      {
        'title': 'Calculus Made Easy',
        'subtitle': 'Master the art of calculus.',
        'instructor': 'Dr. Isaac Newton',
        'subject': 'Math',
        'imageUrl': 'https://via.placeholder.com/400x200.png?text=Calculus',
      },
      {
        'title': 'Algebra for Beginners',
        'subtitle': 'Understand the basics of numbers.',
        'instructor': 'Prof. Al Gebra',
        'subject': 'Math',
        'imageUrl': 'https://via.placeholder.com/400x200.png?text=Algebra',
      },
      {
        'title': 'Linear Algebra Fundamentals',
        'subtitle': 'Vector spaces and matrices.',
        'instructor': 'Dr. Vector Space',
        'subject': 'Math',
        'imageUrl': 'https://via.placeholder.com/400x200.png?text=Linear+Algebra',
      },
    ],
    'History': [
      {
        'title': 'World War II: A Deep Dive',
        'subtitle': 'Learn about global conflicts.',
        'instructor': 'Dr. Historical Figure',
        'subject': 'History',
        'imageUrl': 'https://via.placeholder.com/400x200.png?text=WWII',
      },
      {
        'title': 'Ancient Civilizations',
        'subtitle': 'Journey through past empires.',
        'instructor': 'Prof. Indiana Jones',
        'subject': 'History',
        'imageUrl': 'https://via.placeholder.com/400x200.png?text=Ancient+Civilizations',
      },
    ],
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double topIconsHeight = kToolbarHeight;
    final double searchBarHeight = 56.0;
    final double verticalPadding = 16.0;
    final double appBarTotalHeight = topIconsHeight + searchBarHeight + verticalPadding;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarTotalHeight),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined, color: Colors.black54),
                          onPressed: () {
                            debugPrint('Notifications tapped');
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.chat_bubble_outline, color: Colors.black54),
                          onPressed: () {
                            debugPrint('Chat tapped');
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: searchBarHeight,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search courses...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Filters
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              child: SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final isSelected = index == _selectedCategoryIndex;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(categories[index]),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategoryIndex = index;
                          });
                        },
                        selectedColor: Colors.blue.shade100,
                        backgroundColor: Colors.grey.shade200,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.blue.shade700 : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Course Categories
            ...categorizedCourses.keys.map((categoryName) {
              final coursesInSection = categorizedCourses[categoryName]!;

              if (coursesInSection.isEmpty) {
                return const SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$categoryName Courses',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            debugPrint('See All $categoryName Courses tapped');
                          },
                          child: const Text(
                            'See All',
                            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 250,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: coursesInSection.length,
                      itemBuilder: (context, index) {
                        final course = coursesInSection[index];

                        final cardWidget = Course(
                          courseTitle: course['title'] ?? 'Untitled',
                          subtitle: course['subtitle'] ?? '',
                          instructorName: course['instructor'] ?? 'Unknown',
                          subject: course['subject'] ?? '',
                          imageUrl: course['imageUrl'] ?? 'https://via.placeholder.com/400x200.png?text=Course+Image',
                        );

                        if (course['title'] == 'Astrophysics 101') {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CourseDetailsPage(
                                    title: course['title'] ?? 'Untitled',
                                    instructor: course['instructor'] ?? 'Unknown Instructor',
                                    duration: '12 weeks',
                                    imageUrl: course['imageUrl'] ?? 'https://via.placeholder.com/400x200.png?text=Course+Image',
                                    overview: course['subtitle'] ?? 'No description available.',
                                    features: [
                                      '30 Lessons',
                                      'Advanced',
                                      'English',
                                      'Certificate',
                                      'Online',
                                    ],
                                  ),
                                ),
                              );
                            },
                            child: cardWidget,
                          );
                        } else {
                          return cardWidget;
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              );
            }).toList(),
          ],
        ),
      ),
      bottomNavigationBar: const AppNavigationBar(selectedIndex: 1),
    );
  }
}
