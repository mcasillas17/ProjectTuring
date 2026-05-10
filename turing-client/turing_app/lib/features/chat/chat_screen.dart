import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/message.dart';
import '../../models/turing_event.dart';
import '../../networking/api_client.dart';
import '../../networking/ws_client.dart';
import '../approvals/approval_card.dart';
import 'model_provider_selector.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.sessionId,
    required this.apiClient,
    required this.wsClient,
  });

  final String sessionId;
  final TuringApi apiClient;
  final TuringEventSource wsClient;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatEntry> _messages = [];
  final Map<String, _ChatEntry> _assistantEntries = {};
  final List<_PendingApproval> _approvals = [];
  StreamSubscription<TuringEvent>? _subscription;
  String _modelProvider = 'ollama';
  int? _lastSequence;

  @override
  void initState() {
    super.initState();
    _loadInitialMessages();
    _subscription = widget.wsClient
        .connect(sessionId: widget.sessionId, lastSequence: _lastSequence)
        .listen(_applyEvent);
  }

  Future<void> _loadInitialMessages() async {
    final messages = await widget.apiClient.listMessages(
      sessionId: widget.sessionId,
    );
    if (!mounted || messages.isEmpty) return;
    setState(() {
      _messages
        ..clear()
        ..addAll(messages.map(_ChatEntry.fromMessage));
    });
    _scrollToBottom();
  }

  void _applyEvent(TuringEvent event) {
    _lastSequence = event.sequence;
    switch (event.type) {
      case 'message.delta':
        _applyMessageDelta(event);
        break;
      case 'approval.requested':
        _addApproval(event);
        break;
      case 'approval.approved':
      case 'approval.denied':
      case 'approval.expired':
      case 'approval.consumed':
        _clearApproval(event);
        break;
    }
  }

  void _applyMessageDelta(TuringEvent event) {
    final messageId =
        event.payload['messageId'] as String? ?? 'active_assistant';
    final delta = event.payload['delta'] as String? ?? '';
    var entry = _assistantEntries[messageId];
    if (entry == null) {
      entry = _ChatEntry.assistant(messageId: messageId, content: '');
      _assistantEntries[messageId] = entry;
      setState(() => _messages.add(entry!));
    }
    entry.content.value = '${entry.content.value}$delta';
    _scrollToBottom();
  }

  void _addApproval(TuringEvent event) {
    final approvalId = event.payload['approvalId'] as String?;
    final toolName = event.payload['toolName'] as String?;
    if (approvalId == null || toolName == null) return;
    setState(() {
      _approvals.removeWhere((approval) => approval.approvalId == approvalId);
      _approvals.add(
        _PendingApproval(
          approvalId: approvalId,
          toolName: toolName,
          argsSummary: event.payload['argsSummary'] as String? ?? '',
        ),
      );
    });
  }

  void _clearApproval(TuringEvent event) {
    final approvalId = event.payload['approvalId'] as String?;
    if (approvalId == null) return;
    setState(
      () => _approvals.removeWhere(
        (approval) => approval.approvalId == approvalId,
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(
      () => _messages.add(
        _ChatEntry.user(
          messageId: 'local_${DateTime.now().microsecondsSinceEpoch}',
          content: text,
        ),
      ),
    );
    _controller.clear();
    _scrollToBottom();
    await widget.apiClient.sendMessage(
      sessionId: widget.sessionId,
      content: text,
      modelProvider: _modelProvider,
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Project Turing')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) =>
                  _ChatMessageTile(entry: _messages[index]),
            ),
          ),
          for (final approval in _approvals)
            ApprovalCard(
              toolName: approval.toolName,
              argsSummary: approval.argsSummary,
              onApprove: () => _approve(approval),
              onDeny: () => _deny(approval),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
            child: Row(
              children: [
                Text(
                  'Model provider',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(width: 12),
                ModelProviderSelector(
                  value: _modelProvider,
                  onChanged: (value) => setState(() => _modelProvider = value),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: const InputDecoration(
                        hintText: 'Ask Turing...',
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Send',
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _approve(_PendingApproval approval) async {
    await widget.apiClient.approveApproval(approval.approvalId);
    if (!mounted) return;
    setState(
      () => _approvals.removeWhere(
        (item) => item.approvalId == approval.approvalId,
      ),
    );
  }

  Future<void> _deny(_PendingApproval approval) async {
    await widget.apiClient.denyApproval(approval.approvalId);
    if (!mounted) return;
    setState(
      () => _approvals.removeWhere(
        (item) => item.approvalId == approval.approvalId,
      ),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    widget.wsClient.close();
    for (final message in _messages) {
      message.content.dispose();
    }
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class _ChatMessageTile extends StatelessWidget {
  const _ChatMessageTile({required this.entry});

  final _ChatEntry entry;

  @override
  Widget build(BuildContext context) {
    final alignment = entry.isUser
        ? Alignment.centerRight
        : Alignment.centerLeft;
    final colorScheme = Theme.of(context).colorScheme;
    final background = entry.isUser
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHighest;
    final foreground = entry.isUser
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurface;
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ValueListenableBuilder<String>(
            valueListenable: entry.content,
            builder: (context, content, _) {
              return Text(content, style: TextStyle(color: foreground));
            },
          ),
        ),
      ),
    );
  }
}

class _ChatEntry {
  _ChatEntry({
    required this.messageId,
    required this.isUser,
    required String content,
  }) : content = ValueNotifier(content);

  factory _ChatEntry.user({
    required String messageId,
    required String content,
  }) {
    return _ChatEntry(messageId: messageId, isUser: true, content: content);
  }

  factory _ChatEntry.assistant({
    required String messageId,
    required String content,
  }) {
    return _ChatEntry(messageId: messageId, isUser: false, content: content);
  }

  factory _ChatEntry.fromMessage(Message message) {
    return _ChatEntry(
      messageId: message.messageId,
      isUser: message.role == 'user',
      content: message.content,
    );
  }

  final String messageId;
  final bool isUser;
  final ValueNotifier<String> content;
}

class _PendingApproval {
  const _PendingApproval({
    required this.approvalId,
    required this.toolName,
    required this.argsSummary,
  });

  final String approvalId;
  final String toolName;
  final String argsSummary;
}
