// public_chat_page.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'api_config.dart';

class PublicChatPage extends StatefulWidget {
  final String sessionKey;
  final String username;
  final String role;

  const PublicChatPage({
    super.key,
    required this.sessionKey,
    required this.username,
    required this.role,
  });

  @override
  State<PublicChatPage> createState() => _PublicChatPageState();
}

class _PublicChatPageState extends State<PublicChatPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // UDAH GUA BENERIN DI SINI TUAAN!
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  String? _lastMessageId;
  Timer? _pollingTimer;

  // Reply state
  Map<String, dynamic>? _replyTo;

  // ─── VURTAX X RAT THEME ──────────────────────────────────────────────────────
  final Color bgDark = const Color(0xFFDCEEFB);  // biru muda lembut
  final Color primaryBlue = const Color(0xFF1565C0);  // biru tua accent
  final Color accentBlue = const Color(0xFF42A5F5);  // biru cerah
  final Color lightBlue = const Color(0xFFB3D4F5);
  final Color glowBlue = const Color(0xFF64B5F6);
  final Color cardGlass = Colors.white.withOpacity(0.80);
  final Color borderGlass = const Color(0xFF42A5F5);

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();

    _loadMessages();

    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _pollNewMessages();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pollingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
  setState(() => _isLoading = true);

  try {
    final response = await http.get(
      Uri.parse('$baseUrl/api/chat/messages?session_key=${widget.sessionKey}'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // ✅ LANGSUNG CEK APAKAH DATA ITU LIST, BUKAN data['valid']
      if (data is List) {
        setState(() {
          _messages = data.map((e) => e as Map<String, dynamic>).toList();
          if (_messages.isNotEmpty) {
            _lastMessageId = _messages.last['id'];
          }
        });
        _scrollToBottom();
      }
    }
  } catch (e) {
    print('Error loading messages: $e');
  } finally {
    setState(() => _isLoading = false);
  }
}

  Future<void> _pollNewMessages() async {
    if (_isLoading || _messages.isEmpty) return;

    try {
  final response = await http.get(
    Uri.parse(
      '$baseUrl/api/chat/messages?session_key=${widget.sessionKey}', // <--- GANTI JADI INI
    ),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data != null && data is List) { // <--- RESPON DARI NODE.JS ITU LIST LANGSUNG
      final newMessages = data.map((e) => e as Map<String, dynamic>).toList();
      if (newMessages.length > _messages.length) {
        setState(() {
          _messages = newMessages; // Timpa aja semua biar simpel
          _lastMessageId = _messages.last['id'];
        });
        _scrollToBottom();
      }
    }
  }
} catch (e) {
  // Silent error untuk polling
}
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);

    try {
  final body = {
    'session_key': widget.sessionKey, // <--- PAKE session_key
    'username': widget.username,      // <--- TAMBAHIN INI
    'role': widget.role,              // <--- TAMBAHIN INI
    'message': text,
    if (_replyTo != null) 'replyTo': _replyTo!['id'],
  };

  final response = await http.post(
    Uri.parse('$baseUrl/api/chat/send'), // <--- GANTI JADI /api/chat/send
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(body),
  );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['valid'] == true) {
          setState(() {
            _replyTo = null;
            _messageController.clear();
          });

          final newMsg = data['message'] as Map<String, dynamic>;
          setState(() {
            _messages.add(newMsg);
            _lastMessageId = newMsg['id'];
          });
          _scrollToBottom();
        }
      }
    } catch (e) {
      print('Error sending message: $e');
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _scrollToBottom() {
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

  String _formatTime(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      return DateFormat('HH:mm').format(date);
    } catch (e) {
      return '';
    }
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'owner':
        return const Color(0xFFFFC34D);
      case 'vip':
        return primaryBlue;
      case 'reseller':
        return Colors.tealAccent;
      case 'premium':
        return Colors.orangeAccent;
      default:
        return accentBlue;
    }
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isOwn) {
    final isOwner = message['role'] == 'owner';
    final hasReply = message['replyTo'] != null;
    Map<String, dynamic>? repliedMessage;

    if (hasReply) {
      repliedMessage = _messages.firstWhere(
        (m) => m['id'] == message['replyTo'],
        orElse: () => {},
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      margin: EdgeInsets.only(
        left: isOwn ? 60 : 8,
        right: isOwn ? 8 : 60,
        top: 4,
        bottom: 4,
      ),
      child: Column(
        crossAxisAlignment: isOwn ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (hasReply && repliedMessage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: primaryBlue.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: primaryBlue.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.reply,
                    color: accentBlue,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '↳ ${repliedMessage['username']}',
                          style: TextStyle(
                            color: accentBlue,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Astral',
                          ),
                        ),
                        Text(
                          repliedMessage['message'] ?? '',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 11,
                            fontFamily: 'Astral',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          GestureDetector(
            onLongPress: () {
              if (!isOwn) {
                setState(() {
                  _replyTo = message;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Replying to @${message['username']}', style: const TextStyle(fontFamily: 'Astral')),
                    duration: const Duration(seconds: 2),
                    backgroundColor: primaryBlue,
                    action: SnackBarAction(
                      label: 'Cancel',
                      textColor: Colors.white,
                      onPressed: () {
                        setState(() => _replyTo = null);
                      },
                    ),
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isOwn
                    ? primaryBlue.withOpacity(0.15)
                    : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isOwn ? const Radius.circular(16) : const Radius.circular(4),
                  bottomRight: isOwn ? const Radius.circular(4) : const Radius.circular(16),
                ),
                border: Border.all(
                  color: isOwn
                      ? primaryBlue.withOpacity(0.3)
                      : borderGlass,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        message['username'] ?? 'Unknown',
                        style: TextStyle(
                          color: isOwner ? const Color(0xFFFFC34D) : primaryBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Astral',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getRoleColor(message['role'] ?? 'member').withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          (message['role'] ?? 'member').toUpperCase(),
                          style: TextStyle(
                            color: _getRoleColor(message['role'] ?? 'member'),
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Astral',
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatTime(message['timestamp'] ?? ''),
                        style: TextStyle(
                          color: Colors.black38,
                          fontSize: 9,
                          fontFamily: 'Astral',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message['message'] ?? '',
                    style: TextStyle(
                      color: isOwn ? Colors.black87 : Colors.black87,
                      fontSize: 14,
                      fontFamily: 'Astral',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyBar() {
    if (_replyTo == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: primaryBlue.withOpacity(0.08),
        border: Border(
          top: BorderSide(color: primaryBlue.withOpacity(0.2)),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.reply,
            color: accentBlue,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Replying to @${_replyTo!['username']}',
                  style: TextStyle(
                    color: accentBlue,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Astral',
                  ),
                ),
                Text(
                  _replyTo!['message'] ?? '',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    fontFamily: 'Astral',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _replyTo = null),
            icon: Icon(
              Icons.close,
              color: Colors.black54,
              size: 18,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        title: const Text(
          'Global Chat',
          style: TextStyle(
            color: Color(0xFF000000),
            fontFamily: 'Astral',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1565C0)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  _messages.length.toString(),
                  style: const TextStyle(
                    color: Color(0x8A000000),
                    fontSize: 12,
                    fontFamily: 'Astral',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildReplyBar(),
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: primaryBlue,
                    ),
                  )
                : _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              color: Colors.black26,
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No messages yet',
                              style: TextStyle(
                                color: Colors.black38,
                                fontSize: 16,
                                fontFamily: 'Astral',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Be the first to send a message!',
                              style: TextStyle(
                                color: Colors.black26,
                                fontSize: 12,
                                fontFamily: 'Astral',
                              ),
                            ),
                          ],
                        ),
                      )
                    : FadeTransition(
                        opacity: _fadeAnimation,
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            final isOwn = message['username'] == widget.username;
                            return _buildMessageBubble(message, isOwn);
                          },
                        ),
                      ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: borderGlass),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: bgDark,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: borderGlass),
                    ),
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Color(0xFF000000), fontFamily: 'Astral'),
                      decoration: InputDecoration(
                        hintText: _replyTo != null
                            ? 'Reply to @${_replyTo!['username']}...'
                            : 'Type a message...',
                        hintStyle: TextStyle(
                          color: Colors.black38,
                          fontSize: 14,
                          fontFamily: 'Astral',
                        ),
                        border: InputBorder.none,
                        suffixIcon: _messageController.text.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _messageController.clear();
                                  setState(() {});
                                },
                                icon: Icon(
                                  Icons.clear,
                                  color: Colors.black38,
                                  size: 18,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              )
                            : null,
                      ),
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => _sendMessage(),
                      maxLength: 500,
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _isSending ? null : _sendMessage,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: (_messageController.text.isNotEmpty || _isSending)
                          ? LinearGradient(
                              colors: [primaryBlue, accentBlue],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : LinearGradient(
                              colors: [Colors.grey.shade400, Colors.grey.shade300],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      boxShadow: (_messageController.text.isNotEmpty && !_isSending)
                          ? [
                              BoxShadow(
                                color: primaryBlue.withOpacity(0.3),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ]
                          : [],
                    ),
                    child: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            _replyTo != null ? Icons.reply : Icons.send,
                            color: (_messageController.text.isNotEmpty)
                                ? Colors.white
                                : Colors.white38,
                            size: 20,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}