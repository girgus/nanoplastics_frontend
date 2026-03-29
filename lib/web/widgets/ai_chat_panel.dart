import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../web_theme.dart';

class AiChatPanel extends StatefulWidget {
  final AppLocalizations l10n;
  final VoidCallback onClose;
  final VoidCallback onMinimize;
  final VoidCallback onOpenLibrary;

  const AiChatPanel({
    super.key,
    required this.l10n,
    required this.onClose,
    required this.onMinimize,
    required this.onOpenLibrary,
  });

  @override
  State<AiChatPanel> createState() => _AiChatPanelState();
}

class _AiChatPanelState extends State<AiChatPanel> {
  final TextEditingController _inputController = TextEditingController();
  final List<_ChatMessage> _messages = [];
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _messages.add(_ChatMessage(
      role: _Role.ai,
      text: widget.l10n.aiChatWelcome,
    ));
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quickTopics = [
      widget.l10n.aiChatTopic1,
      widget.l10n.aiChatTopic2,
      widget.l10n.aiChatTopic3,
      widget.l10n.aiChatTopic4,
      widget.l10n.aiChatTopic5,
    ];

    return Container(
      decoration: BoxDecoration(
        color: WebTheme.surfaceAiPanel(context),
        border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.12))),
      ),
      child: Column(
        children: [
          Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            color: Colors.black.withValues(alpha: 0.4),
            child: Row(
              children: [
                Text(
                  widget.l10n.aiChatTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Minimize',
                  onPressed: widget.onMinimize,
                  icon: const Icon(Icons.remove, color: Colors.white70),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: widget.onClose,
                  icon: const Icon(Icons.close, color: Colors.white70),
                ),
              ],
            ),
          ),
          Expanded(
            child: Semantics(
              liveRegion: true,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ..._messages.map(_buildMessage),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: quickTopics
                        .map((topic) => InputChip(
                              label: Text(topic),
                              onPressed: () => _send(topic),
                            ))
                        .toList(growable: false),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    minLines: 1,
                    maxLines: 3,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(_inputController.text),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: widget.l10n.aiChatInputPlaceholder,
                      hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55)),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.07),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.12)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.12)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 36,
                  height: 36,
                  child: FilledButton(
                    onPressed:
                        _isSending || _inputController.text.trim().isEmpty
                            ? null
                            : () => _send(_inputController.text),
                    style: FilledButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: EdgeInsets.zero,
                    ),
                    child: _isSending
                        ? const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.arrow_upward, size: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(_ChatMessage msg) {
    if (msg.role == _Role.user) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.pastelAqua.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(msg.text, style: const TextStyle(color: Colors.white)),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🤖'),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  msg.text,
                  style: const TextStyle(color: Colors.white, height: 1.4),
                ),
                if (msg.withLibraryCta) ...[
                  const SizedBox(height: 6),
                  TextButton.icon(
                    onPressed: widget.onOpenLibrary,
                    icon: const Icon(Icons.menu_book_outlined, size: 16),
                    label: Text(widget.l10n.aiChatOpenLibrary),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _send(String rawText) async {
    final text = rawText.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _messages.add(_ChatMessage(role: _Role.user, text: text));
      _inputController.clear();
      _isSending = true;
    });

    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;

    setState(() {
      _messages.add(
        _ChatMessage(
          role: _Role.ai,
          text: widget.l10n.aiChatComingSoon,
          withLibraryCta: true,
        ),
      );
      _isSending = false;
    });
  }
}

enum _Role { user, ai }

class _ChatMessage {
  final _Role role;
  final String text;
  final bool withLibraryCta;

  const _ChatMessage({
    required this.role,
    required this.text,
    this.withLibraryCta = false,
  });
}
