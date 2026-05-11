import 'package:flutter/material.dart';
import '../../../models/chat_message.dart';
import '../../../constants/app_colors.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    // 1. Detect Theme Mode
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 2. Determine Colors using Constants ONLY
    Color bubbleColor;
    Color textColor;

    if (message.isUser) {
      // User: Electric Blue background, White text
      bubbleColor = AppColors.electricBlue;
      textColor = Colors.white;
    } else {
      // Turing: Surface color based on theme
      if (isDark) {
        bubbleColor = AppColors.darkSurface;
        textColor = AppColors.darkText;
      } else {
        bubbleColor = AppColors.lightSurface;
        textColor = AppColors.lightText;
      }
    }

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),

        decoration: BoxDecoration(
          color: bubbleColor,
          // Shadow only in Light Mode to separate white bubble from light grey bg
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: message.isUser
                ? const Radius.circular(16)
                : Radius.zero,
            bottomRight: message.isUser
                ? Radius.zero
                : const Radius.circular(16),
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: _buildContent(textColor),
      ),
    );
  }

  Widget _buildContent(Color textColor) {
    switch (message.type) {
      case MessageType.loading:
        return SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2, color: textColor),
        );

      case MessageType.deviceStatus:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message.text, style: TextStyle(color: textColor)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                // Use a subtle transparency for inner cards
                color: Colors.black.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lightbulb, color: Colors.orangeAccent),
                  const SizedBox(width: 8),
                  Text(
                    "Living Room: ON",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

      case MessageType.text:
        return Text(
          message.text,
          style: TextStyle(color: textColor, fontSize: 16),
        );
    }
  }
}
