import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

  @override
  void initState() {
    super.initState();
    // Add welcome message
    _messages.add(_ChatMessage(
      text: '',
      isUser: false,
      isWelcome: true,
    ));
  }

  @override
  void dispose() { _controller.dispose(); _scrollController.dispose(); super.dispose(); }

  void _sendMessage(String text, SettingsState settings) async {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isTyping = true;
    });
    _controller.clear();
    _scrollToBottom();

    // Create the AI Agent with current bloc references
    final agent = AiAgentService(
      checklistBloc: context.read<ChecklistBloc>(),
      analyticsBloc: context.read<AnalyticsBloc>(),
      settingsBloc: context.read<SettingsBloc>(),
    );

    // Process through the real AI agent
    try {
      final response = await agent.processMessage(text);

      if (!mounted) return;

      // Show tool execution steps if any
      if (response.toolSteps.isNotEmpty) {
        setState(() {
          _isTyping = false;
          _messages.add(_ChatMessage(
            text: response.toolSteps.join('\n'),
            isUser: false,
            isToolStep: true,
          ));
        });
        _scrollToBottom();

        // Brief delay before showing the final response
        await Future.delayed(const Duration(milliseconds: 400));
        if (!mounted) return;
      }

      setState(() {
        _isTyping = false;
        _messages.add(_ChatMessage(
          text: response.message,
          isUser: false,
        ));
      });
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
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
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
            title: Text(settings.isTamil ? 'AI பயிற்சியாளர்' : 'AI Coach'),
            actions: [
              IconButton(
                icon: const Icon(Icons.lightbulb_outline, color: AppColors.streakGold),
                onPressed: () => _sendMessage(settings.isTamil ? 'ஊக்கம்' : 'motivation', settings),
              ),
            ],
          ),
          body: Column(
            children: [
              // ── Quick Suggestion Chips ────────────────────
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    _SuggestionChip(
                      label: settings.isTamil ? '💪 பயிற்சி' : '💪 Workout',
                      onTap: () => _sendMessage(settings.isTamil ? 'பயிற்சி பரிந்துரை' : 'workout suggestion', settings),
                    ),
                    _SuggestionChip(
                      label: settings.isTamil ? '🥗 உணவு' : '🥗 Diet',
                      onTap: () => _sendMessage(settings.isTamil ? 'உணவு திட்டம்' : 'diet plan', settings),
                    ),
                    _SuggestionChip(
                      label: settings.isTamil ? '📊 சுருக்கம்' : '📊 Summary',
                      onTap: () => _sendMessage(settings.isTamil ? 'முன்னேற்ற சுருக்கம்' : 'progress summary', settings),
                    ),
                    _SuggestionChip(
                      label: settings.isTamil ? '📋 பட்டியல்' : '📋 Checklist',
                      onTap: () => _sendMessage(settings.isTamil ? 'என் பட்டியல் நிலை' : 'my checklist status', settings),
                    ),
                    _SuggestionChip(
                      label: settings.isTamil ? '➕ திட்டம் சேர்' : '➕ Add Plan',
                      onTap: () => _sendMessage(settings.isTamil ? 'பயிற்சி திட்டம் சேர்' : 'add workout plan to checklist', settings),
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
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Container(
                          margin: const EdgeInsets.only(right: 60),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface.withAlpha(128),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.primary.withAlpha(38)),
                          ),
                          child: Text(
                            msg.text,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.primary.withAlpha(200),
                              fontFamily: 'monospace',
                              height: 1.5,
                            ),
                          ),
                        ),
                      ).animate().fadeIn(duration: 200.ms);
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Align(
                        alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: msg.isUser ? AppColors.primary.withAlpha(26) : AppColors.surfaceAltDark,
                            borderRadius: BorderRadius.circular(16).copyWith(
                              bottomRight: msg.isUser ? const Radius.circular(4) : null,
                              bottomLeft: !msg.isUser ? const Radius.circular(4) : null,
                            ),
                            border: Border.all(
                              color: msg.isUser ? AppColors.primary.withAlpha(51) : AppColors.borderDark.withAlpha(51),
                            ),
                          ),
                          child: Text(msg.text, style: Theme.of(context).textTheme.bodyMedium),
                        ),
                      ),
                    ).animate().fadeIn(duration: 300.ms).slideX(begin: msg.isUser ? 0.1 : -0.1);
                  },
                ),
              ),

              // ── Input ────────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  border: Border(top: BorderSide(color: AppColors.borderDark.withAlpha(51))),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: settings.isTamil ? 'உங்கள் கேள்வியை தட்டச்சு செய்க...' : 'Type your question...',
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          onSubmitted: (v) => _sendMessage(v, settings),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send_rounded, color: AppColors.primary),
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
  _ChatMessage({required this.text, required this.isUser, this.isWelcome = false, this.isToolStep = false});
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(label: Text(label, style: const TextStyle(fontSize: 12)), onPressed: onTap),
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
      glowColor: AppColors.secondary,
      glowIntensity: 0.3,
      child: Column(
        children: [
          const Text('🤖', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            settings.isTamil ? 'வணக்கம்! நான் உங்கள் AI பயிற்சியாளர்' : 'Hi! I\'m your AI Coach',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            settings.isTamil
                ? 'நான் உண்மையான செயல்களை செய்ய முடியும் — பணிகள் சேர்ப்பது, முன்னேற்றம் படிப்பது, மற்றும் பல!'
                : 'I can perform real actions — add tasks, read your progress, and more!',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
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
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceAltDark,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) => Container(
            width: 8, height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.textTertiaryDark),
          ).animate(onPlay: (c) => c.repeat())
            .fadeIn(delay: (i * 200).ms, duration: 400.ms)
            .then()
            .fadeOut(duration: 400.ms)),
        ),
      ),
    );
  }
}
