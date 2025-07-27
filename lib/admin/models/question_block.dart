class QuestionBlock {
  final String type; // 'text' or 'image'
  final String content;

  QuestionBlock({required this.type, required this.content});

  factory QuestionBlock.fromMap(Map<String, dynamic> map) {
    return QuestionBlock(
      type: map['type'],
      content: map['content'],
    );
  }

  Map<String, dynamic> toMap() => {
    'type': type,
    'content': content,
  };
}
