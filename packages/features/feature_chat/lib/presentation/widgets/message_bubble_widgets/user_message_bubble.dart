import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:dolfin_core/utils/snackbar_utils.dart';
import '../../../domain/entities/message.dart';
import 'chat_message_image_view.dart';

class UserMessageBubble extends StatelessWidget {
  final Message message;
  final VoidCallback? onRetry;

  const UserMessageBubble({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = message.hasError;

    return GestureDetector(
      onLongPress: () async {
        await Clipboard.setData(ClipboardData(text: message.content));
        if (context.mounted) {
          SnackbarUtils.showInfo(context, 'Message copied to clipboard');
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: hasError
                  ? Theme.of(context).colorScheme.errorContainer
                  : Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.all(
                Radius.circular(24),
              ),
              border: hasError
                  ? Border.all(
                      color: Theme.of(context).colorScheme.error,
                      width: 1.5,
                    )
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.content,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: hasError
                            ? Theme.of(context).colorScheme.onErrorContainer
                            : Theme.of(context).colorScheme.onPrimary,
                        fontSize: 16,
                        height: 1.4,
                      ),
                ),
                if (message.imageUrl != null &&
                    message.imageUrl!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ChatMessageImageView(imageUrl: message.imageUrl!),
                  ),
                ],
              ],
            ),
          ),
          if (hasError) ...[
            const SizedBox(height: 4),
            GestureDetector(
              onTap: onRetry,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.circleAlert,
                    size: 14,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Failed to send',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    LucideIcons.refreshCw,
                    size: 14,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Retry',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
