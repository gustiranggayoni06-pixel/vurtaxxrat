import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'api_config.dart';

class ChatUserPage extends StatefulWidget {
  final String username;
  final String sessionKey;
  final String role;
  final String targetUser;

  const ChatUserPage({
    super.key,
    required this.username,
    required this.sessionKey,
    required this.role,
    required this.targetUser,
  });

  @override
  State<ChatUserPage> createState() => _ChatUserPageState();
}

class _ChatUserPageState extends State<ChatUserPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  Timer? _refreshTimer;

  // ─── VURTAX X RAT THEME (SESUAI DASHBOARD) ──────────────────────────────────────
  static const Color kBg          = Color(0xFFDCEEFB);  // biru muda lembut
  static const Color kSurface     = Color(0xFFFFFFFF);  // putih
  static const Color kCard        = Color(0xFFF0F7FF);  // biru sangat pucat
  static const Color kBorder      = Color(0xFF42A5F5);  // biru cerah
  static const Color kBlue        = Color(0xFF1565C0);  // biru tua accent
  static const Color kBlueLight   = Color(0xFF42A5F5);
  static const Color kText        = Color(0xFF000000);  // hitam 87%
  static const Color kTextSub     = Color(0x8A000000);  // hitam 54%
  static const Color kTextDim     = Color(0x61000000);  // hitam 38%
  static const Color kGreen       = Color(0xFF22C55E);
  static const Color kRed         = Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _loadMessages(silent: true);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<String> _getSessionKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('sessionKey') ?? widget.sessionKey;
  }

  Future<void> _loadMessages({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);
    try {
      final key = await _getSessionKey();
      final response = await http.get(
        Uri.parse('$baseUrl/api/chat/private?key=$key&username=${widget.username}&target=${widget.targetUser}'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['valid'] == true) {
          final newMessages = List<Map<String, dynamic>>.from(data['messages'] ?? []);
          for (var msg in newMessages) {
            msg['isMe'] = msg['from'] == widget.username;
          }
          setState(() {
            _messages = newMessages;
            _isLoading = false;
          });
          if (!silent) _scrollToBottom();
          return;
        }
      }
      if (!silent) setState(() => _isLoading = false);
    } catch (e) {
      print('❌ Load messages error: $e');
      if (!silent) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage({String? text, String? imageUrl}) async {
    if (_isSending) return;
    if ((text == null || text.trim().isEmpty) && imageUrl == null) return;

    setState(() => _isSending = true);

    try {
      final key = await _getSessionKey();
      final payload = {
        'key': key,
        'username': widget.username,
        'target': widget.targetUser,
        'message': text ?? '',
        'image': imageUrl ?? '',
        'type': imageUrl != null ? 'image' : 'text',
      };

      print('📤 Sending payload: ${jsonEncode(payload)}');

      final response = await http.post(
        Uri.parse('$baseUrl/api/chat/private'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 15));

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['valid'] == true) {
          final newMsg = {
            'id': data['message']?['id'] ?? 'msg_${DateTime.now().millisecondsSinceEpoch}',
            'from': widget.username,
            'to': widget.targetUser,
            'message': text ?? '',
            'image': imageUrl ?? '',
            'type': imageUrl != null ? 'image' : 'text',
            'timestamp': DateTime.now().toIso8601String(),
            'isMe': true,
            'read': true,
          };
          setState(() {
            _messages.add(newMsg);
            _messageController.clear();
          });
          _scrollToBottom();
          Future.delayed(const Duration(seconds: 1), () => _loadMessages(silent: true));
        }
      } else {
        print('❌ Send failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Send error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Gagal kirim pesan: $e', style: const TextStyle(color: Colors.white, fontFamily: 'Astral')),
          backgroundColor: kRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
    setState(() => _isSending = false);
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: kSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: kBorder,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Pilih Foto', style: TextStyle(color: kText, fontSize: 16, fontFamily: 'Astral')),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: kBlue),
              title: const Text('Ambil Foto', style: TextStyle(color: kText, fontFamily: 'Astral')),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: kBlue),
              title: const Text('Pilih dari Galeri', style: TextStyle(color: kText, fontFamily: 'Astral')),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source == null) return;

    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 70);
      if (picked == null) return;

      final imageUrl = picked.path;
      print('📸 Image picked: $imageUrl');
      await _sendMessage(imageUrl: imageUrl);
    } catch (e) {
      print('❌ Image pick error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Gagal memilih gambar: $e', style: const TextStyle(color: Colors.white, fontFamily: 'Astral')),
          backgroundColor: kRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
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

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kSurface,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [kBlue, kBlueLight]),
              ),
              child: const Center(child: Icon(Icons.person, color: Colors.white, size: 20)),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.targetUser,
                  style: const TextStyle(color: kText, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Astral'),
                ),
                Text(
                  'Online',
                  style: TextStyle(color: kGreen, fontSize: 11, fontFamily: 'Astral'),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: kText), onPressed: () => _loadMessages()),
          IconButton(icon: const Icon(Icons.more_vert, color: kText), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // ─── CHAT LIST (EXPANDED FULL) ──────────────────────────
          Expanded(
            flex: 1,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: kBlue))
                : _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: kTextDim.withOpacity(0.1)),
                              child: const Icon(Icons.chat_bubble_outline, color: kTextDim, size: 30),
                            ),
                            const SizedBox(height: 16),
                            Text('Tidak ada pesan', style: TextStyle(color: kTextSub, fontSize: 14, fontFamily: 'Astral')),
                            const SizedBox(height: 4),
                            Text('Kirim pesan pertama ke ${widget.targetUser}', style: TextStyle(color: kTextDim, fontSize: 12, fontFamily: 'Astral')),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final isMe = msg['isMe'] == true || msg['from'] == widget.username;
                          return _buildMessageBubble(msg, isMe);
                        },
                      ),
          ),

          // ─── INPUT BAR ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: kSurface,
              border: Border(
                top: BorderSide(color: kBorder.withOpacity(0.3)),
              ),
            ),
            child: Row(
              children: [
                // ─── BUTTON FOTO ──────────────────────────────────
                IconButton(
                  onPressed: _isSending ? null : _pickImage,
                  icon: const Icon(Icons.photo_camera_rounded, color: kBlue, size: 24),
                ),
                const SizedBox(width: 8),
                // ─── TEXT FIELD ──────────────────────────────────
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: kBg,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: kBorder.withOpacity(0.3)),
                    ),
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: kText, fontFamily: 'Astral'),
                      decoration: InputDecoration(
                        hintText: 'Tulis pesan...',
                        hintStyle: TextStyle(color: kTextDim, fontFamily: 'Astral'),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(text: _messageController.text),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // ─── BUTTON SEND ──────────────────────────────────
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: kBlue),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: _isSending ? null : () => _sendMessage(text: _messageController.text),
                    icon: _isSending
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg, bool isMe) {
    final type = msg['type'] ?? 'text';
    final message = msg['message'] ?? '';
    final image = msg['image'] ?? '';
    final timestamp = msg['timestamp'] != null
        ? DateTime.tryParse(msg['timestamp']) ?? DateTime.now()
        : DateTime.now();
    final isRead = msg['read'] == true;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: kBlue),
              child: const Center(child: Icon(Icons.person, color: Colors.white, size: 16)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? kBlue : kSurface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
                  bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
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
                  if (type == 'image' && image.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        image,
                        width: 180,
                        height: 180,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            width: 180,
                            height: 120,
                            color: kTextDim.withOpacity(0.1),
                            child: const Center(child: CircularProgressIndicator(color: kBlue)),
                          );
                        },
                        errorBuilder: (_, __, ___) {
                          return Container(
                            width: 180,
                            height: 120,
                            color: kTextDim.withOpacity(0.1),
                            child: const Icon(Icons.broken_image, color: kTextDim, size: 40),
                          );
                        },
                      ),
                    ),
                  if (type == 'text' && message.isNotEmpty)
                    Text(
                      message,
                      style: TextStyle(
                        color: isMe ? Colors.white : kText,
                        fontSize: 14,
                        fontFamily: 'Astral',
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(timestamp),
                          style: TextStyle(color: isMe ? Colors.white70 : kTextDim, fontSize: 10, fontFamily: 'Astral'),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 4),
                          Icon(
                            isRead ? Icons.done_all : Icons.done,
                            color: isRead ? Colors.white70 : Colors.white70,
                            size: 14,
                          ),
                        ],
                      ],
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
}