import 'package:intl/intl.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final bool isWelcome;
  final bool isToolStep;
  final DateTime timestamp;

  ChatMessage({
    String? id,
    required this.text,
    required this.isUser,
    this.isWelcome = false,
    this.isToolStep = false,
    DateTime? timestamp,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'isUser': isUser,
        'isWelcome': isWelcome,
        'isToolStep': isToolStep,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String?,
        text: json['text'] as String? ?? '',
        isUser: json['isUser'] as bool? ?? false,
        isWelcome: json['isWelcome'] as bool? ?? false,
        isToolStep: json['isToolStep'] as bool? ?? false,
        timestamp: json['timestamp'] != null
            ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
            : DateTime.now(),
      );
}

class ChatSession {
  final String id;
  String title;
  final DateTime createdAt;
  DateTime updatedAt;
  List<ChatMessage> messages;

  ChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    List<ChatMessage>? messages,
  }) : messages = messages ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'messages': messages.where((m) => !m.isWelcome).map((m) => m.toJson()).toList(),
      };

  factory ChatSession.fromJson(Map<String, dynamic> json) => ChatSession(
        id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: json['title'] as String? ?? 'New Chat',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
        messages: (json['messages'] as List? ?? [])
            .map((m) => ChatMessage.fromJson(Map<String, dynamic>.from(m as Map)))
            .toList(),
      );

  static String generateTitle(String firstPrompt) {
    var cleaned = firstPrompt
        .replaceAll(RegExp(r'[\r\n]+'), ' ')
        .trim();
    if (cleaned.isEmpty) return 'New Chat';
    if (cleaned.length > 36) {
      cleaned = '${cleaned.substring(0, 36).trim()}...';
    }
    return cleaned;
  }

  static String getSessionGroup(DateTime date, bool isTamil) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDay = DateTime(date.year, date.month, date.day);
    final diff = today.difference(sessionDay).inDays;

    if (diff == 0) return isTamil ? 'இன்று' : 'Today';
    if (diff == 1) return isTamil ? 'நேற்று' : 'Yesterday';
    if (diff <= 7) return isTamil ? 'கடந்த 7 நாட்கள்' : 'Previous 7 Days';
    return isTamil ? 'பழைய உரையாடல்கள்' : 'Older Chats';
  }

  String get formattedTime => DateFormat('h:mm a').format(updatedAt);
  String get formattedDate => DateFormat('MMM d, yyyy').format(updatedAt);
}
