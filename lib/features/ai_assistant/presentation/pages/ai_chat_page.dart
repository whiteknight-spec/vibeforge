import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/neon_card.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../checklist/presentation/bloc/checklist_bloc.dart';
import '../../../analytics/presentation/bloc/analytics_bloc.dart';
import '../../domain/ai_agent_service.dart';

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

  void _sendMessage(String text, SettingsState settings) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(text: trimmed, isUser: true));
      _isTyping = true;
    });
    _controller.clear();
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settings) {
        if (!settings.isAiEnabled) {
          return Scaffold(
            appBar: AppBar(title: Text(settings.isTamil ? 'AI பயிற்சியாளர்' : 'AI Autonomous Coach')),
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
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      settings.isTamil ? 'அமைப்புகளில் இயக்கவும்' : 'Enable in Settings',
                      style: Theme.of(context).textTheme.bodySmall,
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
              // ── Autonomous Action Chips ────────────────────
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  children: [
                    _SuggestionChip(
                      label: settings.isTamil ? '🎯 இன்று திட்டம் செய்' : '🎯 Plan Routine',
                      onTap: () => _sendMessage(
                        settings.isTamil
                            ? 'என் பட்டியலை பரிசோதித்து இன்றைய ஆரோக்கிய வழக்கங்களை தானாக உருவாக்கு.'
                            : 'Analyze my current checklist and autonomously create a balanced transformation routine for today.',
                        settings,
                      ),
                    ),
                    _SuggestionChip(
                      label: settings.isTamil ? '💪 உடற்பயிற்சி சேர்' : '💪 Add Workout',
                      onTap: () => _sendMessage(
                        settings.isTamil
                            ? 'இன்றைய உடற்பயிற்சி இலக்குகளை (Pushups, Squats, Walk) என் பட்டியலில் சேர்.'
                            : 'Add 3 effective daily workout habits to my checklist using batchCreateHabits.',
                        settings,
                      ),
                    ),
                    _SuggestionChip(
                      label: settings.isTamil ? '📈 நிலைமை ஆய்வு' : '📈 Diagnose Habits',
                      onTap: () => _sendMessage(
                        settings.isTamil
                            ? 'என் தொடர் மற்றும் முடித்த பணிகளை ஆராய்ந்து முன்னேற்ற சுருக்கம் கொடு.'
                            : 'Diagnose my completion streak and give me an honest progress summary.',
                        settings,
                      ),
                    ),
                    _SuggestionChip(
                      label: settings.isTamil ? '📋 பட்டியல் சரிபார்' : '📋 Check Status',
                      onTap: () => _sendMessage(
                        settings.isTamil
                            ? 'இன்று நான் முடிக்க வேண்டிய மீதமுள்ள பணிகள் என்னென்ன?'
                            : 'What are my pending tasks for today? Check my checklist status.',
                        settings,
                      ),
                    ),
                    _SuggestionChip(
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
              const Divider(height: 1),

              // ── Messages ─────────────────────────────────
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (_, index) {
                    if (index == _messages.length && _isTyping) {
                      return _TypingIndicator().animate().fadeIn();
                    }

                    final msg = _messages[index];
                    if (msg.isWelcome) {
                      return _WelcomeCard(settings: settings).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1);
                    }

                    // Tool execution steps
                    if (msg.isToolStep) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          margin: const EdgeInsets.only(right: 40),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceAltDark,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.primary.withAlpha(77)),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withAlpha(26),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.bolt, size: 16, color: AppColors.primary),
                                  const SizedBox(width: 6),
                                  Text(
                                    settings.isTamil ? 'தன்னியக்க செயல்பாடு (Autonomous Tools)' : 'Autonomous Tool Actions',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                msg.text,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textPrimaryDark,
                                      fontFamily: 'monospace',
                                      fontSize: 12,
                                      height: 1.5,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(duration: 200.ms);
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Align(
                        alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: msg.isUser ? AppColors.primary.withAlpha(35) : AppColors.surfaceAltDark,
                            borderRadius: BorderRadius.circular(16).copyWith(
                              bottomRight: msg.isUser ? const Radius.circular(4) : null,
                              bottomLeft: !msg.isUser ? const Radius.circular(4) : null,
                            ),
                            border: Border.all(
                              color: msg.isUser ? AppColors.primary.withAlpha(80) : AppColors.borderDark.withAlpha(51),
                            ),
                          ),
                          child: SelectableText(
                            msg.text,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                          ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 200.ms);
                  },
                ),
              ),

              // ── Input Bar ────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  border: Border(
                    top: BorderSide(color: AppColors.borderDark.withAlpha(77)),
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
                              borderSide: BorderSide(color: AppColors.borderDark.withAlpha(77)),
                            ),
                            filled: true,
                            fillColor: AppColors.surfaceAltDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        icon: const Icon(Icons.send_rounded, size: 20),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.backgroundDark,
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
  final VoidCallback onTap;
  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
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
  const _WelcomeCard({required this.settings});

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
                : 'I am not just a chatbot. I am an autonomous agent that can directly manage your habits, create workout routines, log body stats, and optimize your transformation.',
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
                icon: Icons.analytics_outlined,
                label: settings.isTamil ? 'முன்னேற்ற பகுப்பாய்வு' : 'Progress Analytics',
              ),
            ],
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceAltDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withAlpha(51)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, size: 14, color: AppColors.primary),
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
                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
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
