import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/config/api_config.dart';
import '../../core/utils/app_logger.dart';
import '../../services/http_client.dart';

class EcoChatPage extends StatefulWidget {
  const EcoChatPage({super.key});

  @override
  State<EcoChatPage> createState() => _EcoChatPageState();
}

class _EcoChatPageState extends State<EcoChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  /// Persisted across turns so the backend maintains conversation context.
  String? _sessionId;

  @override
  void initState() {
    super.initState();
    _messages.add(
      ChatMessage(
        text: 'Hi! I am EcoBot, your personal sustainability assistant. I can help you with:\n\n'
            '• Calculate eco scores for your daily activities\n'
            '• Provide personalized sustainability recommendations\n'
            '• Answer questions about carbon footprint and environmental impact\n'
            '• Suggest eco-friendly alternatives for your lifestyle\n'
            '• Guide you on sustainable practices\n\n'
            'Ask me anything related to sustainability and environmental impact!',
        isUser: false,
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    final userMessage = _messageController.text;
    AppLogger.info('📤 Sending message: $userMessage');
    _messageController.clear();

    setState(() {
      _messages.add(ChatMessage(text: userMessage, isUser: true));
      _isLoading = true;
    });

    // Scroll to bottom
    Future.delayed(Duration.zero, () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    try {
      final body = <String, dynamic>{
        'message': userMessage,
        'max_tokens': 512,
        'temperature': 0.7,
      };
      if (_sessionId != null) body['session_id'] = _sessionId;

      AppLogger.info('🌐 POST ${ApiConfig.chatbotUrl}/chat/ (session: $_sessionId)');

      final response = await ApiClient.post(
        Uri.parse('${ApiConfig.chatbotUrl}/chat/'),
        body: jsonEncode(body),
        timeout: const Duration(seconds: 120),
      );

      AppLogger.info('📡 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final reply = data['reply'] as String? ?? '';
        _sessionId = data['session_id'] as String?;

        AppLogger.info('💬 Reply (${reply.length} chars), session: $_sessionId');

        setState(() {
          _messages.add(ChatMessage(text: reply, isUser: false));
          _isLoading = false;
        });
      } else if (response.statusCode == 503) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final error = data['error'] as String? ?? 'EcoBot model is not available yet.';
        AppLogger.error('❌ 503: $error');
        setState(() {
          _messages.add(ChatMessage(
            text: '⏳ $error\n\nThe model may still be loading — please wait a moment and try again.',
            isUser: false,
          ));
          _isLoading = false;
        });
      } else {
        AppLogger.error('❌ HTTP ${response.statusCode}: ${response.body}');
        setState(() {
          _messages.add(ChatMessage(
            text: 'Something went wrong (${response.statusCode}). Please try again.',
            isUser: false,
          ));
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error('❌ Exception: $e');
      setState(() {
        _messages.add(ChatMessage(
          text: 'Could not reach EcoBot: $e',
          isUser: false,
        ));
        _isLoading = false;
      });
    }

    Future.delayed(Duration.zero, () {
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
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoBot Assistant'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isLoading && index == _messages.length) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text('EcoBot is typing...'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ask about your eco score...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      suffixIcon: _messageController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () => setState(() {}),
                              icon: const Icon(Icons.clear),
                            )
                          : null,
                    ),
                    maxLines: null,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _isLoading ? null : _sendMessage,
                  mini: true,
                  backgroundColor:
                      _isLoading ? Colors.grey : Theme.of(context).colorScheme.primary,
                  child: _isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation(Colors.white.withValues(alpha: 0.8)),
                          ),
                        )
                      : const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Align(
        alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          decoration: BoxDecoration(
            color: message.isUser
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SelectableText(
            message.text,
            style: TextStyle(
              color: message.isUser ? Colors.white : Colors.black,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}
