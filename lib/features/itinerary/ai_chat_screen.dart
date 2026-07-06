import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/trip_model.dart';
import '../providers/app_providers.dart';

/// AI Travel Assistant chat screen with premium Black & White glassmorphism and Lucide Icons.
class AIChatScreen extends ConsumerStatefulWidget {
  const AIChatScreen({super.key});
  @override
  ConsumerState<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends ConsumerState<AIChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _isTyping = false;

  void _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    setState(() => _isTyping = true);
    await ref.read(chatProvider.notifier).sendMessage(text);
    setState(() => _isTyping = false);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  void dispose() { _controller.dispose(); _scrollController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(decoration: BoxDecoration(gradient: AppColors.mainBgGradient)),
          Column(
            children: [
              // Custom Glass AppBar
              ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 10, 24, 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                    ),
                    child: Row(children: [
                      if (Navigator.canPop(context))
                        IconButton(
                          icon: const Icon(LucideIcons.chevronLeft, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                        child: const Center(child: Text('🤖', style: TextStyle(fontSize: 20)))),
                      const SizedBox(width: 14),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('AI ASSISTANT', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        Text(_isTyping ? 'PLANNING...' : 'SYSTEM READY', style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.4), fontWeight: FontWeight.w800, letterSpacing: 1)),
                      ]),
                    ]),
                  ),
                ),
              ),

              // Messages
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  itemCount: messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isTyping && index == messages.length) return _TypingIndicator();
                    return _MessageBubble(message: messages[index]);
                  },
                ),
              ),

              // Input bar
              Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, MediaQuery.of(context).padding.bottom + 100),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Row(children: [
                        Expanded(child: TextField(
                          controller: _controller,
                          onSubmitted: (_) => _send(),
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                          decoration: InputDecoration(
                            hintText: 'Ask your travel companion...',
                            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                            filled: false,
                          ),
                        )),
                        GestureDetector(
                          onTap: _send,
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                            child: Icon(LucideIcons.arrowUp, color: Colors.black, size: 20),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: message.isUser ? Colors.white : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(24), 
            topRight: const Radius.circular(24),
            bottomLeft: Radius.circular(message.isUser ? 24 : 4),
            bottomRight: Radius.circular(message.isUser ? 4 : 24),
          ),
          border: message.isUser ? null : Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Text(
          message.message, 
          style: TextStyle(color: message.isUser ? Colors.black : Colors.white, fontSize: 15, fontWeight: message.isUser ? FontWeight.w700 : FontWeight.w500, height: 1.4),
        ),
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
        margin: const EdgeInsets.only(bottom: 16), 
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: List.generate(3, (i) => Container(margin: const EdgeInsets.symmetric(horizontal: 2), width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle)))),
      ),
    );
  }
}
