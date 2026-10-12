import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/neon_card.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../checklist/presentation/bloc/checklist_bloc.dart';
import '../../../analytics/presentation/bloc/analytics_bloc.dart';
import '../../domain/ai_agent_service.dart';
import '../../domain/chat_session.dart';
import '../../domain/exercise_guides_data.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<ChatSession> _sessions = [];
  String _activeSessionId = '';
  bool _isTyping = false;

  Box get _chatBox => Hive.box(AppConstants.hiveAiChatBox);

  ChatSession get _activeSession {
    if (_sessions.isEmpty) {
      final initial = _createDefaultSession();
      _sessions.add(initial);
      _activeSessionId = initial.id;
      return initial;
    }
    return _sessions.firstWhere(
      (s) => s.id == _activeSessionId,
      orElse: () => _sessions.first,
    );
  }

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  ChatSession _createDefaultSession({String? title}) {
    final now = DateTime.now();
    return ChatSession(
      id: now.millisecondsSinceEpoch.toString(),
      title: title ?? 'New Chat',
      createdAt: now,
      updatedAt: now,
      messages: [
        ChatMessage(
          text: '',
          isUser: false,
          isWelcome: true,
          timestamp: now,
        ),
      ],
    );
  }

  void _loadSessions() {
    final storedSessions = _chatBox.get('sessions') as List?;
    _sessions.clear();

    if (storedSessions != null && storedSessions.isNotEmpty) {
      for (final item in storedSessions) {
        if (item is Map) {
          try {
            _sessions.add(ChatSession.fromJson(Map<String, dynamic>.from(item)));
          } catch (_) {}
        }
      }
    }

    // Migration from single legacy 'history' if present
    if (_sessions.isEmpty) {
      final legacyHistory = _chatBox.get('history') as List?;
      if (legacyHistory != null && legacyHistory.isNotEmpty) {
        final legacyMessages = <ChatMessage>[];
        for (final item in legacyHistory) {
          if (item is Map) {
            try {
              legacyMessages.add(ChatMessage.fromJson(Map<String, dynamic>.from(item)));
            } catch (_) {}
          }
        }
        if (legacyMessages.isNotEmpty) {
          final firstUser = legacyMessages.firstWhere(
            (m) => m.isUser,
            orElse: () => ChatMessage(text: 'Previous Chat', isUser: true),
          );
          final migrated = ChatSession(
            id: 'legacy_${DateTime.now().millisecondsSinceEpoch}',
            title: ChatSession.generateTitle(firstUser.text),
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
            updatedAt: DateTime.now(),
            messages: legacyMessages,
          );
          _sessions.add(migrated);
        }
      }
    }

    if (_sessions.isEmpty) {
      _sessions.add(_createDefaultSession());
    }

    // Sort by recent updatedAt descending
    _sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    final savedActiveId = _chatBox.get('active_session_id') as String?;
    if (savedActiveId != null && _sessions.any((s) => s.id == savedActiveId)) {
      _activeSessionId = savedActiveId;
    } else {
      _activeSessionId = _sessions.first.id;
    }

    // Ensure active session has welcome card if empty
    if (_activeSession.messages.isEmpty) {
      _activeSession.messages.add(ChatMessage(
        text: '',
        isUser: false,
        isWelcome: true,
      ));
    }
  }

  void _persistSessions() {
    final toSave = _sessions.map((s) => s.toJson()).toList();
    _chatBox.put('sessions', toSave);
    _chatBox.put('active_session_id', _activeSessionId);
  }

  void _createNewSession(SettingsState settings) {
    final newSession = _createDefaultSession(
      title: settings.isTamil ? 'புதிய உரையாடல்' : 'New Chat',
    );
    setState(() {
      _sessions.insert(0, newSession);
      _activeSessionId = newSession.id;
      _isTyping = false;
    });
    _persistSessions();
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(settings.isTamil ? 'புதிய உரையாடல் துவக்கப்பட்டது' : 'New conversation started'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _switchSession(String sessionId) {
    setState(() {
      _activeSessionId = sessionId;
      _isTyping = false;
      if (_activeSession.messages.isEmpty) {
        _activeSession.messages.add(ChatMessage(
          text: '',
          isUser: false,
          isWelcome: true,
        ));
      }
    });
    _chatBox.put('active_session_id', _activeSessionId);
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context);
    }
    _scrollToBottom();
  }

  void _renameSession(ChatSession session, SettingsState settings) {
    final titleCtl = TextEditingController(text: session.title);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(settings.isTamil ? 'தலைப்பை மாற்றவும்' : 'Rename Conversation'),
        content: TextField(
          controller: titleCtl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: settings.isTamil ? 'உரையாடல் தலைப்பு...' : 'Conversation title...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(settings.isTamil ? 'ரத்து' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newTitle = titleCtl.text.trim();
              if (newTitle.isNotEmpty) {
                setState(() {
                  session.title = newTitle;
                });
                _persistSessions();
              }
              Navigator.pop(ctx);
            },
            child: Text(settings.isTamil ? 'சேமி' : 'Save'),
          ),
        ],
      ),
    );
  }

  void _deleteSession(String sessionId, SettingsState settings) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(settings.isTamil ? 'உரையாடலை நீக்கவா?' : 'Delete Conversation?'),
        content: Text(settings.isTamil
            ? 'இந்த குறிப்பிட்ட AI உரையாடல் நிரந்தரமாக நீக்கப்படும்.'
            : 'This conversation will be permanently removed from your history.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(settings.isTamil ? 'ரத்து' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _sessions.removeWhere((s) => s.id == sessionId);
                if (_sessions.isEmpty) {
                  _sessions.add(_createDefaultSession());
                }
                if (_activeSessionId == sessionId) {
                  _activeSessionId = _sessions.first.id;
                }
              });
              _persistSessions();
            },
            child: Text(settings.isTamil ? 'நீக்கு' : 'Delete'),
          ),
        ],
      ),
    );
  }

  void _clearCurrentSession(SettingsState settings) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(settings.isTamil ? 'செயலில் உள்ள அரட்டையை அழிக்கவா?' : 'Clear Current Chat?'),
        content: Text(settings.isTamil
            ? 'இந்த உரையாடலின் அனைத்து செய்திகளும் அழிக்கப்படும்.'
            : 'All messages in this conversation will be cleared.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(settings.isTamil ? 'ரத்து' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _activeSession.messages.clear();
                _activeSession.messages.add(ChatMessage(
                  text: '',
                  isUser: false,
                  isWelcome: true,
                ));
              });
              _persistSessions();
            },
            child: Text(settings.isTamil ? 'அழி' : 'Clear'),
          ),
        ],
      ),
    );
  }

  void _clearAllHistory(SettingsState settings) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(settings.isTamil ? 'அனைத்து வரலாற்றையும் அழிக்கவா?' : 'Clear All History?'),
        content: Text(settings.isTamil
            ? 'அனைத்து பழைய AI உரையாடல்களும் நிரந்தரமாக அழிக்கப்படும்.'
            : 'All previous AI conversations across all sessions will be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(settings.isTamil ? 'ரத்து' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _sessions.clear();
                final fresh = _createDefaultSession();
                _sessions.add(fresh);
                _activeSessionId = fresh.id;
              });
              _chatBox.delete('sessions');
              _chatBox.delete('history');
              _chatBox.put('active_session_id', _activeSessionId);
              if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
                Navigator.pop(context);
              }
            },
            child: Text(settings.isTamil ? 'அனைத்தும் அழி' : 'Clear All'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<Map<String, String>> _buildChatHistory() {
    final history = <Map<String, String>>[];
    for (final m in _activeSession.messages) {
      if (m.isWelcome || m.isToolStep) continue;
      history.add({
        'role': m.isUser ? 'user' : 'model',
        'content': m.text,
      });
    }
    return history;
  }

  Future<void> _sendMessage(String text, SettingsState settings) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isTyping) return;

    _controller.clear();
    final now = DateTime.now();

    // Auto-update session title on first user message if it's currently generic
    if (_activeSession.title == 'New Chat' ||
        _activeSession.title == 'புதிய உரையாடல்' ||
        _activeSession.title.isEmpty) {
      _activeSession.title = ChatSession.generateTitle(trimmed);
    }
    _activeSession.updatedAt = now;

    setState(() {
      _activeSession.messages.add(ChatMessage(
        text: trimmed,
        isUser: true,
        timestamp: now,
      ));
      _isTyping = true;
    });
    _persistSessions();
    _scrollToBottom();

    final agent = AiAgentService(
      checklistBloc: context.read<ChecklistBloc>(),
      analyticsBloc: context.read<AnalyticsBloc>(),
      settingsBloc: context.read<SettingsBloc>(),
    );

    try {
      final history = _buildChatHistory();
      final response = await agent.processMessage(trimmed, chatHistory: history);

      if (!mounted) return;

      if (response.toolSteps.isNotEmpty) {
        setState(() {
          _isTyping = false;
          _activeSession.messages.add(ChatMessage(
            text: response.toolSteps.join('\n'),
            isUser: false,
            isToolStep: true,
            timestamp: DateTime.now(),
          ));
        });
        _persistSessions();
        _scrollToBottom();

        await Future.delayed(const Duration(milliseconds: 300));
        if (!mounted) return;
      }

      setState(() {
        _isTyping = false;
        _activeSession.updatedAt = DateTime.now();
        _activeSession.messages.add(ChatMessage(
          text: response.message,
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
      _persistSessions();
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _activeSession.messages.add(ChatMessage(
          text: settings.isTamil ? '❌ பிழை ஏற்பட்டது: $e' : '❌ Error occurred: $e',
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
      _persistSessions();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showAllExerciseGuidesModal(BuildContext context, SettingsState settings) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, scrollCtl) => Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: AppColors.borderDark),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.borderDark, borderRadius: BorderRadius.circular(2)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  children: [
                    Icon(Icons.fitness_center_rounded, color: AppColors.primary, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        settings.isTamil ? 'உடற்பயிற்சி படங்கள் & வழிகாட்டல்' : 'Visual Exercise & Stretch Library',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  controller: scrollCtl,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: ExerciseGuidesData.guides.length,
                  itemBuilder: (context, i) {
                    final guide = ExerciseGuidesData.guides[i];
                    return _ExerciseFullCard(guide: guide, isTamil: settings.isTamil);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settings) {
        if (!settings.isAiEnabled) {
          return Scaffold(
            appBar: AppBar(title: Text(settings.isTamil ? 'AI பயிற்சியாளர்' : 'AI Coach')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome_outlined, size: 60, color: AppColors.textTertiaryDark),
                    const SizedBox(height: 16),
                    Text(
                      settings.isTamil ? 'AI அம்சங்கள் முடக்கப்பட்டுள்ளன' : 'AI Features Disabled',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      settings.isTamil
                          ? 'அமைப்புகள் பக்கத்தில் சென்று AI-ஐ இயக்கவும்.'
                          : 'Please enable AI features in the Settings page to chat with your coach.',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          key: _scaffoldKey,
          drawer: _buildChatHistoryDrawer(context, settings, isDark, primary),
          appBar: AppBar(
            leading: IconButton(
              tooltip: settings.isTamil ? 'உரையாடல் வரலாறு' : 'Chat History',
              icon: const Icon(Icons.menu_rounded),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            titleSpacing: 0,
            title: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.success,
                    boxShadow: [
                      BoxShadow(color: AppColors.success, blurRadius: 6, spreadRadius: 1),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        settings.isTamil ? 'AI பயிற்சியாளர்' : 'AI Coach',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _activeSession.title,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          fontWeight: FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: settings.isTamil ? 'புதிய உரையாடல்' : 'New Chat',
                icon: const Icon(Icons.add_comment_outlined, size: 20),
                onPressed: () => _createNewSession(settings),
              ),
              IconButton(
                tooltip: settings.isTamil ? 'ஊக்கம்' : 'Motivation',
                icon: const Icon(Icons.lightbulb_outline, color: AppColors.streakGold),
                onPressed: () => _sendMessage(
                  settings.isTamil
                      ? 'எனக்கு இன்றைய தினத்திற்கான வலிமையான ஊக்கமும் அறிவுரையும் கொடு.'
                      : 'Give me a powerful motivation quote and habit guidance for today.',
                  settings,
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded),
                onSelected: (val) {
                  switch (val) {
                    case 'rename':
                      _renameSession(_activeSession, settings);
                      break;
                    case 'clear_current':
                      _clearCurrentSession(settings);
                      break;
                    case 'view_guides':
                      _showAllExerciseGuidesModal(context, settings);
                      break;
                    case 'delete_current':
                      _deleteSession(_activeSession.id, settings);
                      break;
                  }
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'rename',
                    child: Row(
                      children: [
                        const Icon(Icons.edit_outlined, size: 18),
                        const SizedBox(width: 8),
                        Text(settings.isTamil ? 'தலைப்பு மாற்று' : 'Rename Chat'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'clear_current',
                    child: Row(
                      children: [
                        const Icon(Icons.refresh_rounded, size: 18),
                        const SizedBox(width: 8),
                        Text(settings.isTamil ? 'உரையாடலை துடை' : 'Clear Chat'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'view_guides',
                    child: Row(
                      children: [
                        const Icon(Icons.photo_library_outlined, size: 18),
                        const SizedBox(width: 8),
                        Text(settings.isTamil ? 'பயிற்சி படங்கள்' : 'Exercise Library'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'delete_current',
                    child: Row(
                      children: [
                        const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                        const SizedBox(width: 8),
                        Text(
                          settings.isTamil ? 'உரையாடலை நீக்கு' : 'Delete Chat',
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              // ── Quick Suggestions Bar ───────────────────────
              SizedBox(
                height: 48,
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  children: [
                    _SuggestionChip(
                      icon: Icons.photo_camera_back_outlined,
                      label: settings.isTamil ? '📸 படங்களுடன் பயிற்சிகள்' : '📸 Visual Exercise Guides',
                      onTap: () => _showAllExerciseGuidesModal(context, settings),
                    ),
                    _SuggestionChip(
                      icon: Icons.track_changes_rounded,
                      label: settings.isTamil ? '🎯 இன்று திட்டம் செய்' : '🎯 Plan Routine',
                      onTap: () => _sendMessage(
                        settings.isTamil
                            ? 'என் பட்டியலை பரிசோதித்து இன்றைய ஆரோக்கிய வழக்கங்களை தானாக உருவாக்கு.'
                            : 'Analyze my current checklist and autonomously create a balanced transformation routine for today.',
                        settings,
                      ),
                    ),
                    _SuggestionChip(
                      icon: Icons.fitness_center_rounded,
                      label: settings.isTamil ? '💪 உடற்பயிற்சி சேர்' : '💪 Add Workout',
                      onTap: () => _sendMessage(
                        settings.isTamil
                            ? 'இன்றைய உடற்பயிற்சி இலக்குகளை (Pushups, Squats, Walk) என் பட்டியலில் சேர்.'
                            : 'Add 3 effective daily workout habits to my checklist using batchCreateHabits.',
                        settings,
                      ),
                    ),
                    _SuggestionChip(
                      icon: Icons.analytics_outlined,
                      label: settings.isTamil ? '📈 நிலைமை ஆய்வு' : '📈 Diagnose Habits',
                      onTap: () => _sendMessage(
                        settings.isTamil
                            ? 'என் தொடர் மற்றும் முடித்த பணிகளை ஆராய்ந்து முன்னேற்ற சுருக்கம் கொடு.'
                            : 'Diagnose my completion streak and give me an honest progress summary.',
                        settings,
                      ),
                    ),
                    _SuggestionChip(
                      icon: Icons.restaurant_rounded,
                      label: settings.isTamil ? '🥗 உணவு வழிகாட்டி' : '🥗 Diet Guidance',
                      onTap: () => _sendMessage(
                        settings.isTamil
                            ? 'ஆரோக்கியமான கொழுப்பு குறைப்பு உணவு திட்டத்தை பரிந்துரைத்து பழக்கங்களை சேர்.'
                            : 'Suggest a high-protein fat-loss daily diet routine and add key reminders to my checklist.',
                        settings,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Messages List (Clean Gemini / ChatGPT / Claude UI) ──
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: _activeSession.messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _activeSession.messages.length && _isTyping) {
                      return _TypingIndicator().animate().fadeIn();
                    }

                    final msg = _activeSession.messages[index];
                    if (msg.isWelcome) {
                      return _WelcomeCard(
                        settings: settings,
                        onViewGuides: () => _showAllExerciseGuidesModal(context, settings),
                      );
                    }

                    // Collapsible Autonomous Tool Actions
                    if (msg.isToolStep) {
                      return _ToolActionWidget(
                        text: msg.text,
                        isTamil: settings.isTamil,
                      );
                    }

                    // Regular Message: User or Clean AI Response
                    if (msg.isUser) {
                      return _UserMessageBubble(
                        text: msg.text,
                        timestamp: msg.timestamp,
                        primaryColor: primary,
                        isDark: isDark,
                      );
                    } else {
                      return _AiMessageCard(
                        msg: msg,
                        isTamil: settings.isTamil,
                        isDark: isDark,
                        primaryColor: primary,
                      );
                    }
                  },
                ),
              ),

              // ── Modern Floating Input Bar ────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  border: Border(
                    top: BorderSide(color: isDark ? AppColors.borderDark.withAlpha(77) : AppColors.borderLight),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (t) => _sendMessage(t, settings),
                          decoration: InputDecoration(
                            hintText: settings.isTamil
                                ? 'பயிற்சி, உணவு, அல்லது பழக்கங்களை நிர்வகிக்க கேட்கவும்...'
                                : 'Ask to add habits, check streak, or plan workout...',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(color: isDark ? AppColors.borderDark.withAlpha(77) : AppColors.borderLight),
                            ),
                            filled: true,
                            fillColor: isDark ? AppColors.surfaceAltDark : AppColors.surfaceAltLight,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        icon: const Icon(Icons.send_rounded, size: 20),
                        style: IconButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: isDark ? AppColors.backgroundDark : Colors.white,
                        ),
                        onPressed: () => _sendMessage(_controller.text, settings),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── ChatGPT / Gemini / Claude Style Navigation Drawer ─────────────
  Widget _buildChatHistoryDrawer(
    BuildContext context,
    SettingsState settings,
    bool isDark,
    Color primary,
  ) {
    // Group sessions by relative date
    final groupedSessions = <String, List<ChatSession>>{};
    for (final s in _sessions) {
      final group = ChatSession.getSessionGroup(s.updatedAt, settings.isTamil);
      groupedSessions.putIfAbsent(group, () => []).add(s);
    }

    return Drawer(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      child: SafeArea(
        child: Column(
          children: [
            // Header with "+ New Chat" button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primary.withAlpha(30),
                        ),
                        child: Icon(Icons.auto_awesome, color: primary, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'VibeForge AI',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            Text(
                              settings.isTamil ? 'உரையாடல் வரலாறு' : 'Chat History',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Prominent "+ New Chat" Action Button
                  InkWell(
                    onTap: () => _createNewSession(settings),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primary.withAlpha(40),
                            primary.withAlpha(15),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: primary.withAlpha(90)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_rounded, color: primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            settings.isTamil ? 'புதிய உரையாடல்' : '+ New Chat',
                            style: TextStyle(
                              color: primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Session List grouped by date
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                children: [
                  for (final entry in groupedSessions.entries) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 12, 8, 6),
                      child: Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                        ),
                      ),
                    ),
                    for (final session in entry.value)
                      _buildSessionTile(session, settings, isDark, primary),
                  ],
                ],
              ),
            ),

            const Divider(height: 1),
            // Footer with "Clear All History"
            ListTile(
              dense: true,
              leading: const Icon(Icons.delete_sweep_outlined, color: AppColors.error, size: 20),
              title: Text(
                settings.isTamil ? 'அனைத்து வரலாற்றையும் அழி' : 'Clear All History',
                style: const TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              onTap: () => _clearAllHistory(settings),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionTile(
    ChatSession session,
    SettingsState settings,
    bool isDark,
    Color primary,
  ) {
    final isSelected = session.id == _activeSessionId;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? primary.withAlpha(25)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? primary.withAlpha(90) : Colors.transparent,
          width: 1,
        ),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        leading: Icon(
          isSelected ? Icons.chat_bubble_rounded : Icons.chat_bubble_outline_rounded,
          size: 18,
          color: isSelected ? primary : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
        ),
        title: Text(
          session.title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? (isDark ? Colors.white : Colors.black)
                : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(shape: BoxShape.circle, color: primary),
              ),
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_horiz_rounded,
                size: 18,
                color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
              ),
              padding: EdgeInsets.zero,
              onSelected: (val) {
                if (val == 'rename') {
                  _renameSession(session, settings);
                } else if (val == 'delete') {
                  _deleteSession(session.id, settings);
                }
              },
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  value: 'rename',
                  child: Row(
                    children: [
                      const Icon(Icons.edit_outlined, size: 16),
                      const SizedBox(width: 8),
                      Text(settings.isTamil ? 'தலைப்பு மாற்று' : 'Rename'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete_outline, size: 16, color: AppColors.error),
                      const SizedBox(width: 8),
                      Text(settings.isTamil ? 'நீக்கு' : 'Delete', style: const TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () => _switchSession(session.id),
      ),
    );
  }
}

// ── Clean User Message Bubble ──────────────────────────────────────
class _UserMessageBubble extends StatelessWidget {
  final String text;
  final DateTime timestamp;
  final Color primaryColor;
  final bool isDark;

  const _UserMessageBubble({
    required this.text,
    required this.timestamp,
    required this.primaryColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('h:mm a').format(timestamp);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.82,
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          decoration: BoxDecoration(
            color: primaryColor.withAlpha(35),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(4),
            ),
            border: Border.all(color: primaryColor.withAlpha(80)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 50 : 10),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SelectableText(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                timeStr,
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Clean AI Message Card (Like Gemini / ChatGPT / Claude) ─────────
class _AiMessageCard extends StatelessWidget {
  final ChatMessage msg;
  final bool isTamil;
  final bool isDark;
  final Color primaryColor;

  const _AiMessageCard({
    required this.msg,
    required this.isTamil,
    required this.isDark,
    required this.primaryColor,
  });

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: msg.text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
            const SizedBox(width: 8),
            Text(isTamil ? 'உரையாடல் நகலெடுக்கப்பட்டது' : 'Copied to clipboard'),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final matchingGuides = ExerciseGuidesData.findMatching(msg.text);
    final timeStr = DateFormat('h:mm a').format(msg.timestamp);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.94,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceAltDark : AppColors.surfaceAltLight,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
          ),
          border: Border.all(
            color: isDark ? AppColors.borderDark.withAlpha(90) : AppColors.borderLight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 60 : 15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header: AI Avatar + Name Badge + Time
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [primaryColor, AppColors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withAlpha(80),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.auto_awesome, size: 13, color: Colors.black),
                ),
                const SizedBox(width: 8),
                Text(
                  'VibeForge AI',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: primaryColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isTamil ? 'பயிற்சியாளர்' : 'Coach',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  timeStr,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Clean Markdown Typography Body
            MarkdownBody(
              data: msg.text,
              selectable: true,
              styleSheet: MarkdownStyleSheet(
                p: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.65,
                      fontSize: 14,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                h1: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: primaryColor,
                ),
                h2: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                ),
                h3: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                ),
                strong: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
                em: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
                listBullet: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
                horizontalRuleDecoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      width: 1,
                    ),
                  ),
                ),
                code: TextStyle(
                  fontFamily: 'monospace',
                  color: primaryColor,
                  backgroundColor: isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceAltLight,
                ),
                codeblockDecoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderDark.withAlpha(90)),
                ),
              ),
            ),

            // Visual Exercise Guides Carousel if workout routine is detected
            if (matchingGuides.isNotEmpty) ...[
              const SizedBox(height: 14),
              _ExerciseGuideCarousel(
                guides: matchingGuides,
                isTamil: isTamil,
              ),
            ],

            const SizedBox(height: 10),
            // Bottom Action Toolbar (Copy to clipboard, etc.)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: isTamil ? 'நகலெடு' : 'Copy Response',
                  visualDensity: VisualDensity.compact,
                  iconSize: 18,
                  icon: Icon(
                    Icons.content_copy_rounded,
                    color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                  ),
                  onPressed: () => _copyToClipboard(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Collapsible & Clean Autonomous Tool Actions Card ───────────────
class _ToolActionWidget extends StatefulWidget {
  final String text;
  final bool isTamil;

  const _ToolActionWidget({required this.text, required this.isTamil});

  @override
  State<_ToolActionWidget> createState() => _ToolActionWidgetState();
}

class _ToolActionWidgetState extends State<_ToolActionWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final lines = widget.text.split('\n').where((l) => l.trim().isNotEmpty).toList();
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        margin: const EdgeInsets.only(right: 32),
        decoration: BoxDecoration(
          color: AppColors.surfaceAltDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: primary.withAlpha(60)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primary.withAlpha(35),
                      ),
                      child: Icon(Icons.auto_awesome, size: 14, color: primary),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.isTamil
                            ? 'தானியங்கி செயல்பாடு (${lines.length} பணிகள்)'
                            : 'Autonomous Tracker Actions (${lines.length} completed)',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: primary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    Icon(
                      _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 18,
                      color: primary,
                    ),
                  ],
                ),
              ),
            ),
            if (_isExpanded) ...[
              const Divider(height: 1, thickness: 1, indent: 12, endIndent: 12),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: lines.map((line) {
                    final cleanLine = line
                        .replaceAll(RegExp(r'\[Tool Call\]\s*'), '')
                        .replaceAll(RegExp(r'\[Verified\]\s*'), '');
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
                          Expanded(
                            child: Text(
                              cleanLine,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textPrimaryDark,
                                    height: 1.4,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Visual Exercise Guides Carousel ───────────────────────────────
class _ExerciseGuideCarousel extends StatelessWidget {
  final List<ExerciseGuide> guides;
  final bool isTamil;

  const _ExerciseGuideCarousel({required this.guides, required this.isTamil});

  @override
  Widget build(BuildContext context) {
    if (guides.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.fitness_center_rounded, size: 16, color: AppColors.accent),
            const SizedBox(width: 6),
            Text(
              isTamil ? 'உடற்பயிற்சி படங்கள் & வழிகாட்டல்' : 'Visual Exercise & Posture Guides',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 190,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: guides.length,
            itemBuilder: (context, idx) {
              final guide = guides[idx];
              return GestureDetector(
                onTap: () => _showExerciseDetailDialog(context, guide, isTamil),
                child: Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderDark.withAlpha(128)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(60),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              guide.imagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Center(
                                child: Icon(Icons.fitness_center, size: 36, color: AppColors.textTertiaryDark),
                              ),
                            ),
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(160),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.zoom_in, size: 14, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isTamil ? guide.titleTa : guide.title,
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isTamil ? guide.targetMusclesTa : guide.targetMuscles,
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: AppColors.primary,
                                      fontSize: 10,
                                    ),
                                maxLines: 1,
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
            },
          ),
        ),
      ],
    );
  }
}

// ── Exercise Detailed Dialog ──────────────────────────────────────
void _showExerciseDetailDialog(BuildContext context, ExerciseGuide guide, bool isTamil) {
  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Image.asset(
                  guide.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.fitness_center, size: 50, color: AppColors.textTertiaryDark),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            isTamil ? guide.titleTa : guide.title,
                            style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primary.withAlpha(100)),
                          ),
                          child: Text(
                            guide.reps,
                            style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.accessibility_new, size: 16, color: AppColors.secondary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            isTamil ? 'இலக்கு: ${guide.targetMusclesTa}' : 'Target: ${guide.targetMuscles}',
                            style: Theme.of(ctx).textTheme.labelSmall?.copyWith(color: AppColors.secondary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isTamil ? 'சரியான முறை (Form Guidance):' : 'Proper Form Cue for Beginners:',
                      style: Theme.of(ctx).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isTamil ? guide.formCuesTa : guide.formCues,
                      style: Theme.of(ctx).textTheme.bodySmall?.copyWith(height: 1.5),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(isTamil ? 'புரிந்தது' : 'Got it!'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// ── Full Card in Library Modal ────────────────────────────────────
class _ExerciseFullCard extends StatelessWidget {
  final ExerciseGuide guide;
  final bool isTamil;

  const _ExerciseFullCard({required this.guide, required this.isTamil});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceAltDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDark.withAlpha(100)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.asset(
              guide.imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(Icons.fitness_center, size: 40, color: AppColors.textTertiaryDark),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        isTamil ? guide.titleTa : guide.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        guide.reps,
                        style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  isTamil ? 'இலக்கு: ${guide.targetMusclesTa}' : 'Target: ${guide.targetMuscles}',
                  style: TextStyle(fontSize: 11, color: AppColors.primary),
                ),
                const SizedBox(height: 6),
                Text(
                  isTamil ? guide.formCuesTa : guide.formCues,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  const _SuggestionChip({
    required this.label,
    this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        avatar: icon != null ? Icon(icon, size: 14, color: AppColors.primary) : null,
        label: Text(label, style: const TextStyle(fontSize: 12)),
        onPressed: onTap,
        backgroundColor: AppColors.primarySurface,
        side: BorderSide(color: AppColors.primary.withAlpha(51)),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  final SettingsState settings;
  final VoidCallback onViewGuides;

  const _WelcomeCard({
    required this.settings,
    required this.onViewGuides,
  });

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      margin: const EdgeInsets.only(bottom: 12),
      showGlow: true,
      glowColor: AppColors.primary,
      glowIntensity: 0.25,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withAlpha(26),
            ),
            child: const Text('⚡', style: TextStyle(fontSize: 32)),
          ),
          const SizedBox(height: 12),
          Text(
            settings.isTamil ? 'வணக்கம்! நான் உங்கள் AI தன்னாட்சி பயிற்சியாளர்' : 'VibeForge Autonomous Agent',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            settings.isTamil
                ? 'நான் வெறும் சாட்பாட் மட்டுமல்ல. உங்கள் பழக்கவழக்கங்கள், உடற்பயிற்சி திட்டங்கள், மற்றும் முன்னேற்றங்களை நேரடியாக நிர்வகிக்கும் தன்னாட்சி ஏஜென்ட்.'
                : 'I am not just a chatbot. I am an autonomous agent that directly manages your habits, creates visual workout routines, logs body stats, and optimizes your transformation.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              _CapabilityBadge(
                icon: Icons.checklist_rounded,
                label: settings.isTamil ? 'பழக்கங்கள் மேலாண்மை' : 'Manage Habits',
              ),
              _CapabilityBadge(
                icon: Icons.fitness_center_rounded,
                label: settings.isTamil ? 'உடற்பயிற்சி வழிகாட்டல்' : 'Workout Coaching',
              ),
              _CapabilityBadge(
                icon: Icons.photo_library_outlined,
                label: settings.isTamil ? 'பயிற்சி படங்கள்' : 'Visual Exercise Guides',
              ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.photo_library_outlined, size: 16),
            label: Text(settings.isTamil ? 'பயிற்சி படங்கள் & போஸ்கள் காண்க' : 'Browse Exercise Picture Guides'),
            onPressed: onViewGuides,
            style: OutlinedButton.styleFrom(
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }
}

class _CapabilityBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CapabilityBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceAltDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark.withAlpha(102)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark)),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceAltDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withAlpha(51)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, size: 14, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text(
              'Autonomous Agent reasoning...',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark, fontStyle: FontStyle.italic),
            ),
            const SizedBox(width: 8),
            ...List.generate(
              3,
              (i) => Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
              )
                  .animate(onPlay: (c) => c.repeat())
                  .fadeIn(delay: (i * 200).ms, duration: 400.ms)
                  .then()
                  .fadeOut(duration: 400.ms),
            ),
          ],
        ),
      ),
    );
  }
}
