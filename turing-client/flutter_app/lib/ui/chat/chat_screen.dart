import 'package:flutter/material.dart';
import '../../models/chat_message.dart';
import 'widgets/chat_bubble.dart';
// import '../../services/turing_service.dart'; // Uncomment when ready to connect

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Dummy data to test the UI immediately
  final List<ChatMessage> _messages = [
    ChatMessage(
      id: '1', 
      isUser: false, 
      text: "Hello Miguel. Systems are online. How can I help?"
    ),
  ];

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      // 1. Add User Message
      _messages.add(ChatMessage(
        id: DateTime.now().toString(),
        isUser: true,
        text: text,
      ));

      // 2. Simulate Turing "Thinking"
      _messages.add(ChatMessage(
        id: 'loading',
        isUser: false,
        text: '',
        type: MessageType.loading,
      ));
    });

    _controller.clear();
    _scrollToBottom();

    // Simulate a reply after 2 seconds (We will replace this with real Backend later)
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _messages.removeWhere((m) => m.type == MessageType.loading);
        
        // Example of a Rich Response
        if (text.toLowerCase().contains("light")) {
           _messages.add(ChatMessage(
            id: DateTime.now().toString(),
            isUser: false,
            text: "I've updated the device status.",
            type: MessageType.deviceStatus, // <--- RICH WIDGET
          ));
        } else {
          _messages.add(ChatMessage(
            id: DateTime.now().toString(),
            isUser: false,
            text: "I received: $text",
          ));
        }
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    // wait for frame to render then scroll
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    return Column(
      children: [
        // 1. The Chat List
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              return ChatBubble(message: _messages[index]);
            },
          ),
        ),

        // 2. The Input Area
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).appBarTheme.backgroundColor,
          child: Row(
            children: [
              // Text Field
              Expanded(
                child: TextField(
                  controller: _controller,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: "Ask Turing...",
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.grey[800] 
                        : Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              
              // Send Button
              FloatingActionButton(
                onPressed: _sendMessage,
                mini: true,
                backgroundColor: Colors.blueAccent,
                child: const Icon(Icons.arrow_upward, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}