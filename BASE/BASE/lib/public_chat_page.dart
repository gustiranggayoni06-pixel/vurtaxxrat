// public_chat_page.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

  List _messages = [];
  List _parseMessagesList(dynamic decoded) {
  bool _isLoading = true;
  bool _isSending = false;
  Timer? _pollingTimer;

  // Reply state
  Map<String, dynamic>? _replyTo;

  // ─── VURTAX X RAT THEME ──────────────────────────────────────────────────────
  final Color bgDark = const Color(0xFFDCEEFB);
  final Color primaryBlue = const Color(0xFF1565C0);
  final Color accentBlue = const Color(0xFF42A5F5);
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

    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
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

  // ─── PARSING & NORMALISASI DATA PESAN ───────────────────────────────────────
  Map<String, dynamic> _normalizeMessage(dynamic raw) {
    final map = raw is Map<String, dynamic>
        ? raw
        : (raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{});

    final id = (map['id'] ?? map['_id'] ?? '').toString();
    final username = (map['username'] ??
            map['sender'] ??
            map['user'] ??
            map['author'] ??
            'Unknown')
        .toString()
        .trim();
    final role = (map['role'] ?? 'member').toString().trim();
    final messageText = (map['message'] ??
            map['text'] ??
            map['content'] ??
            map['body'] ??
            '')
        .toString();
    final timestamp = (map['timestamp'] ??
            map['createdAt'] ??
            map['created_at'] ??
            map['time'] ??
            '')
        .toString();
    final replyTo = map['replyTo'] ?? map['reply_to'];

    return {
      'id': id,
      'username': username.isEmpty ? 'Unknown' : username,
      'role': role.isEmpty ? 'member' : role,
      'message': messageText,
      'timestamp': timestamp,
      'replyTo': replyTo?.toString(),
    };
  }

  List> _parseMessagesList(dynamic decoded) {
    final rawList = decoded is List
        ? decoded
        : (decoded is Map && decoded['messages'] is List
            ? decoded['messages'] as List
            : (decoded is Map && decoded['data'] is List
                ? decoded['data'] as List
                : const []));

    return rawList.map(_normalizeMessage).toList();
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);

    try {
      final uri = Uri.parse(
        '$baseUrl/api/chat/messages?session_key=${Uri.encodeComponent(widget.sessionKey)}',
      );
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final parsed = _parseMessagesList(decoded);

        if (!mounted) return;
        setState(() {
          _messages = parsed;
        });
        _scrollToBottom();
      }
    } catch (_) {
      // Tangani error jaringan secara aman tanpa crash
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pollNewMessages() async {
    if (_isLoading || !mounted) return;

    try {
      final uri = Uri.parse(
        '$baseUrl/api/chat/messages?session_key=${Uri.encodeComponent(widget.sessionKey)}',
      );
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final latestMessages = _parseMessagesList(decoded);

        final hasChanged = latestMessages.length != _messages.length ||
            (latestMessages.isNotEmpty &&
                _messages.isNotEmpty &&
                latestMessages.last['id'] != _messages.last['id']);

        if (hasChanged && mounted) {
          setState(() {
            _messages = latestMessages;
          });
          _scrollToBottom();
        }
      }
    } catch (_) {
      // Silent error untuk polling
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);

    try {
      final body = <String, dynamic>{
        'session_key': widget.sessionKey,
        'username': widget.username,
        'role': widget.role,
        'message': text,
        if (_replyTo != null && (_replyTo!['id']?.toString().isNotEmpty ?? false))
          'replyTo': _replyTo!['id'],
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/chat/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final isValid = decoded is Map && (decoded['valid'] == true || decoded['success'] == true);

        if (isValid && mounted) {
          final rawMsg = decoded['message'] ?? decoded['data'];
          final newMsg = rawMsg != null
              ? _normalizeMessage(rawMsg)
              : _normalizeMessage({
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  'username': widget.username,
                  'role': widget.role,
                  'message': text,
                  'timestamp': DateTime.now().toIso8601String(),
                  'replyTo': _replyTo?['id'],
                });

          setState(() {
            _replyTo = null;
            _messageController.clear();
            _messages = [..._messages, newMsg];
          });
          _scrollToBottom();
        }
      }
    } catch (_) {
      // Silent error saat mengirim
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
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

  String _formatTime(String rawTime) {
    if (rawTime.isEmpty) return '';
    try {
      final parsed = DateTime.tryParse(rawTime);
      if (parsed != null) {
        return DateFormat('HH:mm').format(parsed.toLocal());
      }
      final millis = int.tryParse(rawTime);
      if (millis != null) {
        return DateFormat('HH:mm').format(
          DateTime.fromMillisecondsSinceEpoch(millis),
        );
      }
      return rawTime.length >= 5 ? rawTime.substring(0, 5) : rawTime;
    } catch (_) {
      return '';
    }
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'owner':
        return const Color(0xFFD98A00);
      case 'vip':
        return primaryBlue;
      case 'reseller':
        return const Color(0xFF00897B);
      case 'premium':
        return const Color(0xFFEF6C00);
      default:
        return accentBlue;
    }
  }

  Map<String, dynamic>? _findRepliedMessage(String? replyId) {
    if (replyId == null || replyId.isEmpty) return null;
    for (final msg in _messages) {
      if (msg['id']?.toString() == replyId) {
        return msg;
      }
    }
    return null;
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isOwn) {
    final senderName = (message['username'] ?? 'Unknown').toString();
    final roleText = (message['role'] ?? 'member').toString();
    final bodyText = (message['message'] ?? '').toString();
    final timeText = _formatTime((message['timestamp'] ?? '').toString());
    final isOwner = roleText.toLowerCase() == 'owner';
    final roleColor = _getRoleColor(roleText);
    final repliedMessage = _findRepliedMessage(message['replyTo']?.toString());

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      margin: EdgeInsets.only(
        left: isOwn ? 56 : 6,
        right: isOwn ? 6 : 56,
        top: 5,
        bottom: 5,
      ),
      child: Column(
        crossAxisAlignment:
            isOwn ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (repliedMessage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.75),
                borderRadius: BorderRadius.circular(10),
                border: Border(
                  left: BorderSide(color: primaryBlue, width: 3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '↳ ${repliedMessage['username'] ?? 'Unknown'}',
                    style: TextStyle(
                      color: primaryBlue,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Astral',
                    ),
                  ),
                  Text(
                    (repliedMessage['message'] ?? '').toString(),
                    style: const TextStyle(
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
          GestureDetector(
            onLongPress: () {
              if (!isOwn) {
                setState(() => _replyTo = message);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Replying to @$senderName',
                      style: const TextStyle(fontFamily: 'Astral'),
                    ),
                    duration: const Duration(seconds: 2),
                    backgroundColor: primaryBlue,
                    action: SnackBarAction(
                      label: 'Cancel',
                      textColor: Colors.white,
                      onPressed: () => setState(() => _replyTo = null),
                    ),
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isOwn ? const Color(0xFFE3F2FD) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isOwn ? 16 : 4),
                  bottomRight: Radius.circular(isOwn ? 4 : 16),
                ),
                border: Border.all(
                  color: isOwn
                      ? primaryBlue.withOpacity(0.35)
                      : borderGlass.withOpacity(0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          senderName,
                          style: TextStyle(
                            color: isOwner ? const Color(0xFFB26A00) : primaryBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Astral',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: roleColor.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          roleText.toUpperCase(),
                          style: TextStyle(
                            color: roleColor,
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Astral',
                          ),
                        ),
                      ),
                      if (timeText.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        Text(
                          timeText,
                          style: const TextStyle(
                            color: Colors.black45,
                            fontSize: 9,
                            fontFamily: 'Astral',
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    bodyText,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      height: 1.35,
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

    final replyUser = (_replyTo!['username'] ?? 'Unknown').toString();
    final replyBody = (_replyTo!['message'] ?? '').toString();

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
          Icon(Icons.reply, color: accentBlue, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Replying to @$replyUser',
                  style: TextStyle(
                    color: accentBlue,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Astral',
                  ),
                ),
                Text(
                  replyBody,
                  style: const TextStyle(
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
            icon: const Icon(Icons.close, color: Colors.black54, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canSend = _messageController.text.trim().isNotEmpty && !_isSending;

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
                    child: CircularProgressIndicator(color: primaryBlue),
                  )
                : _messages.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              color: Colors.black26,
                              size: 64,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No messages yet',
                              style: TextStyle(
                                color: Colors.black38,
                                fontSize: 16,
                                fontFamily: 'Astral',
                              ),
                            ),
                            SizedBox(height: 8),
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
                            horizontal: 10,
                            vertical: 14,
                          ),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            final sender = (message['username'] ?? '')
                                .toString()
                                .toLowerCase();
                            final isOwn = sender == widget.username.toLowerCase();
                            return _buildMessageBubble(message, isOwn);
                          },
                        ),
                      ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: borderGlass)),
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
                      style: const TextStyle(
                        color: Color(0xFF000000),
                        fontFamily: 'Astral',
                      ),
                      decoration: InputDecoration(
                        hintText: _replyTo != null
                            ? 'Reply to @${_replyTo!['username'] ?? 'Unknown'}...'
                            : 'Type a message...',
                        hintStyle: const TextStyle(
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
                                icon: const Icon(
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
                  onTap: canSend ? _sendMessage : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: canSend
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
                      boxShadow: canSend
                          ? [
                              BoxShadow(
                                color: primaryBlue.withOpacity(0.3),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ]
                          : const [],
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
                            color: canSend ? Colors.white : Colors.white70,
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
