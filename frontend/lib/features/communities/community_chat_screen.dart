import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

/// Forum Diskusi — real GET & POST pesan dari /api/communities/:id/messages
/// JSON keys dari Go backend:
///   msg["message"], msg["sender_name"], msg["user_id"]
///   msg["user"] (lowercase) → {"id", "name", "level", "avatar"}
class CommunityChatScreen extends StatefulWidget {
  final int communityId;
  const CommunityChatScreen({super.key, required this.communityId});

  @override
  State<CommunityChatScreen> createState() => _CommunityChatScreenState();
}

class _CommunityChatScreenState extends State<CommunityChatScreen> {
  List<dynamic> _messages = [];
  bool _loading = true;
  bool _sending = false;
  bool _hasError = false;
  String _errorMsg = '';
  int? _myId;
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      _myId = await AuthService.getUserId();
    } catch (_) {}
    await _loadMessages();
  }

  Future<void> _loadMessages() async {
    setState(() { _loading = true; _hasError = false; });
    try {
      final msgs = await ApiService.getCommunityMessages(widget.communityId);
      if (mounted) {
        setState(() {
          _messages = msgs;
          _loading = false;
        });
        _scrollToBottom();
      }
    } on ApiException catch (e) {
      if (mounted) setState(() {
        _loading = false;
        _hasError = true;
        _errorMsg = e.message;
      });
    } catch (e) {
      if (mounted) setState(() {
        _loading = false;
        _hasError = true;
        _errorMsg = 'Gagal memuat pesan. Cek koneksi.';
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _sending) return;
    _msgCtrl.clear();
    setState(() => _sending = true);
    try {
      await ApiService.sendCommunityMessage(widget.communityId, text);
      await _loadMessages();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengirim pesan')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Safe helper: extract user fields from msg ──────────────────────
  // Go serialises the User relation as lowercase key: msg["user"]
  // Falls back to msg["sender_name"] / msg["user_id"] for resilience.
  static Map<String, dynamic> _safeUser(dynamic msg) {
    if (msg is! Map) return {};
    // Primary: preloaded User object (key = "user", lowercase per Go json tag)
    final u = msg['user'];
    if (u is Map<String, dynamic>) return u;
    // Fallback: use flat fields baked into ChatMessage
    return {
      'id':    msg['user_id'],
      'name':  msg['sender_name'] ?? 'Pengguna',
      'level': 'Pemula',
    };
  }

  static int? _safeInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static String _initial(String? name) {
    final n = name?.trim() ?? '';
    return n.isNotEmpty ? n[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Forum Diskusi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadMessages,
          ),
        ],
      ),
      body: Column(
        children: [
          // Info banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: AppColors.primaryGreenSoft,
            child: const Text(
              '💬 Berdiskusi bersama memperkuat komitmen kita pada lingkungan!',
              style: TextStyle(fontSize: 12, color: AppColors.primaryGreen, fontFamily: 'Poppins'),
              textAlign: TextAlign.center,
            ),
          ),

          // ── Message area (must be Expanded to constrain ListView) ──
          Expanded(
            child: Builder(builder: (ctx) {
              if (_loading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryGreen),
                );
              }
              if (_hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.wifi_off_rounded, color: AppColors.textMuted, size: 48),
                        const SizedBox(height: 12),
                        Text(_errorMsg, style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins'), textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadMessages,
                          style: ElevatedButton.styleFrom(minimumSize: const Size(140, 44)),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              if (_messages.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('💬', style: TextStyle(fontSize: 48)),
                      SizedBox(height: 12),
                      Text('Belum ada pesan.', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, fontFamily: 'Poppins', color: AppColors.textPrimary)),
                      SizedBox(height: 4),
                      Text('Jadilah yang pertama berdiskusi!', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontFamily: 'Poppins')),
                    ],
                  ),
                );
              }
              return ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                itemCount: _messages.length,
                itemBuilder: (_, i) {
                  final raw = _messages[i];
                  if (raw is! Map) return const SizedBox.shrink();
                  final msg = raw as Map<String, dynamic>;
                  final user = _safeUser(msg);
                  final isMe = _safeInt(user['id']) == _myId;
                  return _ChatBubble(
                    message: msg['message']?.toString() ?? '',
                    userName: user['name']?.toString() ?? 'Pengguna',
                    userLevel: user['level']?.toString() ?? 'Pemula',
                    isMe: isMe,
                  );
                },
              );
            }),
          ),

          // ── Input bar ──
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Tulis pesan...',
                      hintStyle: const TextStyle(color: AppColors.textMuted, fontFamily: 'Poppins', fontSize: 14),
                      filled: true,
                      fillColor: AppColors.backgroundLight,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _sendMessage,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _sending ? AppColors.textMuted : AppColors.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _sending ? Icons.hourglass_empty_rounded : Icons.send_rounded,
                      color: Colors.white,
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

// ── Chat Bubble — pure display widget, no nullable crashes ────────────────────

class _ChatBubble extends StatelessWidget {
  final String message;
  final String userName;
  final String userLevel;
  final bool isMe;

  const _ChatBubble({
    required this.message,
    required this.userName,
    required this.userLevel,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : '?';

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryGreenSoft,
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],

          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Sender info (only for others)
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                              fontFamily: 'Poppins',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.accentAmberSoft,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            userLevel,
                            style: const TextStyle(
                              fontSize: 9,
                              color: AppColors.accentAmber,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Bubble
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.68,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.primaryGreen : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isMe ? 18 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message,
                    style: TextStyle(
                      fontSize: 14,
                      color: isMe ? Colors.white : AppColors.textPrimary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }
}
