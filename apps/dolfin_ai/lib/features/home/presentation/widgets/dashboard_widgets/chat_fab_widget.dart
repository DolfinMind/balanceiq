import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:feature_chat/presentation/pages/chat_page.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ChatFabWidget extends StatelessWidget {
  final VoidCallback? onReturn;
  final bool isDark;

  const ChatFabWidget({
    super.key,
    this.onReturn,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(
          right: 16.0, bottom: 100.0), // Above the bottom nav
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChatPage(
                      botId: "nai kichu",
                      botName: 'Donfin AI',
                    ),
                  ),
                );
                onReturn?.call();
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    LucideIcons.bot, // Using the bot icon to signify AI
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
