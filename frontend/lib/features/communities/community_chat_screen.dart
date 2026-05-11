import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
  bool _isJoined = false;
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
      if (_myId != null) {
        final prof = await ApiService.getProfil(_myId!);
        final joined = prof['joined_communities'] as List<dynamic>? ?? [];
        _isJoined = joined.any((c) => c['id'] == widget.communityId);
      }
    } catch (_) {}

    if (_isJoined) {
      await _loadMessages();
    } else if (mounted) {
      setState(() {
        _loading = false;
        _messages = [];
      });
    }
  }

  Future<void> _toggleJoin() async {
    setState(() => _sending = true);
    try {
      final res = await ApiService.toggleJoinCommunity(widget.communityId);
      if (mounted) {
        setState(() {
          _isJoined = res['is_joined'];
          if (!_isJoined) _messages = [];
        });
        if (_isJoined) await _loadMessages();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(res['pesan'],
                style: const TextStyle(
                    fontFamily: 'Poppins', color: Colors.white)),
            backgroundColor: const Color(0xFF1A4D2E),
            behavior: SnackBarBehavior.floating));
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.toString(),
                style: const TextStyle(
                    fontFamily: 'Poppins', color: Colors.white)),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _loadMessages() async {
    if (!_isJoined) {
      setState(() {
        _loading = false;
        _messages = [];
        _hasError = false;
      });
      return;
    }

    setState(() {
      _loading = true;
      _hasError = false;
    });
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
      if (e.statusCode == 403) {
        if (mounted)
          setState(() {
            _loading = false;
            _hasError = false;
            _isJoined = false;
            _messages = [];
          });
        return;
      }
      if (mounted)
        setState(() {
          _loading = false;
          _hasError = true;
          _errorMsg = e.message;
        });
    } catch (e) {
      if (mounted)
        setState(() {
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
        if (e.statusCode == 403) {
          setState(() {
            _isJoined = false;
            _messages = [];
          });
        }
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
      'id': msg['user_id'],
      'name': msg['sender_name'] ?? 'Pengguna',
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/komunitas'),
        ),
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
              style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primaryGreen,
                  fontFamily: 'Poppins'),
              textAlign: TextAlign.center,
            ),
          ),

          // ── Message area (must be Expanded to constrain ListView) ──
          Expanded(
            child: Builder(builder: (ctx) {
              if (_loading) {
                return const Center(
                  child:
                      CircularProgressIndicator(color: AppColors.primaryGreen),
                );
              }
              if (_hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.wifi_off_rounded,
                            color: AppColors.textMuted, size: 48),
                        const SizedBox(height: 12),
                        Text(_errorMsg,
                            style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontFamily: 'Poppins'),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadMessages,
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size(140, 44)),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              if (!_isJoined) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_outline_rounded,
                            color: AppColors.textMuted, size: 48),
                        SizedBox(height: 12),
                        Text(
                          'Forum hanya tersedia untuk anggota komunitas.',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Poppins',
                              color: AppColors.textPrimary),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Gabung komunitas terlebih dahulu untuk membaca dan mengirim pesan.',
                          style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontFamily: 'Poppins'),
                          textAlign: TextAlign.center,
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
                      Text('Belum ada pesan.',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                              color: AppColors.textPrimary)),
                      SizedBox(height: 4),
                      Text('Jadilah yang pertama berdiskusi!',
                          style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontFamily: 'Poppins')),
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
                    userAvatar: user['avatar']?.toString() ?? '',
                    userId: _safeInt(user['id']) ?? 0,
                    isMe: isMe,
                  );
                },
              );
            }),
          ),

          // ── Input bar / Join Button ──
          _isJoined
              ? Container(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
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
                            hintStyle: const TextStyle(
                                color: AppColors.textMuted,
                                fontFamily: 'Poppins',
                                fontSize: 14),
                            filled: true,
                            fillColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
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
                            color: _sending
                                ? AppColors.textMuted
                                : AppColors.primaryGreen,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _sending
                                ? Icons.hourglass_empty_rounded
                                : Icons.send_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 16,
                          offset: const Offset(0, -4)),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _toggleJoin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: _sending
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('Gabung Komunitas untuk Diskusi',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700,
                                fontSize: 15)),
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
  final String userAvatar;
  final int userId;
  final bool isMe;

  const _ChatBubble({
    required this.message,
    required this.userName,
    required this.userLevel,
    required this.userAvatar,
    required this.userId,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : '?';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            GestureDetector(
              onTap: () {
                if (userId > 0) context.push('/profil/$userId');
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F5F1),
                  shape: BoxShape.circle,
                  image: userAvatar.isNotEmpty
                      ? DecorationImage(
                          image: CachedNetworkImageProvider(userAvatar),
                          fit: BoxFit.cover)
                      : null,
                ),
                child: userAvatar.isEmpty
                    ? Center(
                        child: Text(
                          initial,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A4D2E),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Sender info (only for others)
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                              fontFamily: 'Poppins',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F3EB),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            userLevel,
                            style: const TextStyle(
                              fontSize: 9,
                              color: Color(0xFF1A4D2E),
                              fontWeight: FontWeight.w800,
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
                    maxWidth: MediaQuery.of(context).size.width * 0.72,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isMe
                        ? const Color(0xFF1A4D2E)
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isMe ? 20 : 6),
                      bottomRight: Radius.circular(isMe ? 6 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: isMe
                        ? null
                        : Border.all(
                            color: const Color(0xFFE8F3EB), width: 1.5),
                  ),
                  child: Text(
                    message,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: isMe
                          ? Colors.white
                          : (Theme.of(context).textTheme.bodyLarge?.color ??
                              const Color(0xFF1A4D2E)),
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
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
