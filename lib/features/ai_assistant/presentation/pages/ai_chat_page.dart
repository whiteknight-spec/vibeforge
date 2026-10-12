import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/neon_card.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../checklist/presentation/bloc/checklist_bloc.dart';
import '../../../analytics/presentation/bloc/analytics_bloc.dart';
import '../../domain/ai_agent_service.dart';
import '../../domain/exercise_guides_data.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isTyping = false;

  Box get _chatBox => Hive.box(AppConstants.hiveAiChatBox);

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  void _loadChatHistory() {
    final stored = _chatBox.get('history', defaultValue: []) as List;
    if (stored.isNotEmpty) {
      for (final item in stored) {
        if (item is Map) {
          _messages.add(_ChatMessage.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    if (_messages.isEmpty) {
      _messages.add(_ChatMessage(
        text: '',
        isUser: false,
        isWelcome: true,
      ));
    }
  }

  void _persistChatHistory() {
    final toSave = _messages
        .where((m) => !m.isWelcome)
        .map((m) => m.toJson())
        .toList();
    _chatBox.put('history', toSave);
  }

  void _clearChat(SettingsState settings) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(settings.isTamil ? 'உரையாடலை அழிக்கவா?' : 'Clear Conversation?'),
        content: Text(settings.isTamil
            ? 'அனைத்து பழைய AI உரையாடல்களும் அழிக்கப்படும்.'
            : 'All previous AI agent conversation history will be cleared.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(settings.isTamil ? 'ரத்துசெய்' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _messages.clear();
                _messages.add(_ChatMessage(text: '', isUser: false, isWelcome: true));
              });
              _chatBox.delete('history');
            },
            child: Text(settings.isTamil ? 'அழி' : 'Clear'),
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
    for (final m in _messages) {
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
    setState(() {
      _messages.add(_ChatMessage(text: trimmed, isUser: true));
      _isTyping = true;
    });
    _persistChatHistory();
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
          _messages.add(_ChatMessage(
            text: response.toolSteps.join('\n'),
            isUser: false,
            isToolStep: true,
          ));
        });
        _persistChatHistory();
        _scrollToBottom();

        await Future.delayed(const Duration(milliseconds: 300));
        if (!mounted) return;
      }

      setState(() {
        _isTyping = false;
        _messages.add(_ChatMessage(
          text: response.message,
          isUser: false,
        ));
      });
      _persistChatHistory();
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(_ChatMessage(
          text: settings.isTamil ? '❌ பிழை ஏற்பட்டது: $e' : '❌ Error occurred: $e',
          isUser: false,
        ));
      });
      _persistChatHistory();
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
              Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.borderDark, borderRadius: BorderRadius.circular(2))),
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
          appBar: AppBar(
            title: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.success,
                    boxShadow: [
                      BoxShadow(color: AppColors.success, blurRadius: 6, spreadRadius: 1),
                    ],
                  ),
                ),
                Text(settings.isTamil ? 'AI பயிற்சியாளர்' : 'AI Coach'),
              ],
            ),
            actions: [
              IconButton(
                tooltip: settings.isTamil ? 'அழி' : 'Clear Chat',
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: () => _clearChat(settings),
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

              // ── Messages List ────────────────────────────
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isTyping) {
                      return _TypingIndicator().animate().fadeIn();
                    }

                    final msg = _messages[index];
                    if (msg.isWelcome) {
                      return _WelcomeCard(
                        settings: settings,
                        onViewGuides: () => _showAllExerciseGuidesModal(context, settings),
                      );
                    }

                    // Collapsible & Clean Autonomous Tool Actions
                    if (msg.isToolStep) {
                      return _ToolActionWidget(
                        text: msg.text,
                        isTamil: settings.isTamil,
                      );
                    }

                    // Regular Message with Markdown & Visual Exercise Guides
                    final matchingGuides = !msg.isUser
                        ? ExerciseGuidesData.findMatching(msg.text)
                        : <ExerciseGuide>[];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Align(
                        alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * (msg.isUser ? 0.82 : 0.90),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: msg.isUser
                                ? primary.withAlpha(35)
                                : (isDark ? AppColors.surfaceAltDark : AppColors.surfaceAltLight),
                            borderRadius: BorderRadius.circular(16).copyWith(
                              bottomRight: msg.isUser ? const Radius.circular(4) : null,
                              bottomLeft: !msg.isUser ? const Radius.circular(4) : null,
                            ),
                            border: Border.all(
                              color: msg.isUser
                                  ? primary.withAlpha(80)
                                  : (isDark ? AppColors.borderDark.withAlpha(77) : AppColors.borderLight),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(isDark ? 50 : 10),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (msg.isUser)
                                SelectableText(
                                  msg.text,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    height: 1.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              else ...[
                                // Clean Rich Markdown Rendering
                                MarkdownBody(
                                  data: msg.text,
                                  selectable: true,
                                  styleSheet: MarkdownStyleSheet(
                                    p: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      height: 1.6,
                                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                    ),
                                    h1: GoogleFonts.outfit(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: primary,
                                    ),
                                    h2: GoogleFonts.outfit(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: primary,
                                    ),
                                    h3: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: primary,
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
                                      color: primary,
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
                                      color: primary,
                                      backgroundColor: isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceAltLight,
                                    ),
                                    codeblockDecoration: BoxDecoration(
                                      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppColors.borderDark.withAlpha(80)),
                                    ),
                                  ),
                                ),

                                // Visual Exercise Guides Carousel if workout routine detected
                                if (matchingGuides.isNotEmpty) ...[
                                  const SizedBox(height: 14),
                                  _ExerciseGuideCarousel(
                                    guides: matchingGuides,
                                    isTamil: settings.isTamil,
                                  ),
                                ],
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ── Input Bar ────────────────────────────────
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
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

class _ChatMessage {
  final String text;
  final bool isUser;
  final bool isWelcome;
  final bool isToolStep;

  _ChatMessage({
    required this.text,
    required this.isUser,
    this.isWelcome = false,
    this.isToolStep = false,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'isUser': isUser,
        'isWelcome': isWelcome,
        'isToolStep': isToolStep,
      };

  factory _ChatMessage.fromJson(Map<String, dynamic> json) => _ChatMessage(
        text: json['text'] as String? ?? '',
        isUser: json['isUser'] as bool? ?? false,
        isWelcome: json['isWelcome'] as bool? ?? false,
        isToolStep: json['isToolStep'] as bool? ?? false,
      );
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
