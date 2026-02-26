import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/user_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _chatService = ChatService();
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final msgs = await _chatService.getMessages();
      if (!mounted) return;
      final myUserId = context.read<UserProvider>().user?.userId;
      setState(() {
        _messages = msgs.map((m) {
          final isMe = m['sender_id'] == myUserId;
          final dtStr = m['created_at'];
          String timeStr = '';
          if (dtStr != null && dtStr.toString().isNotEmpty) {
            try {
              final dt = DateTime.parse(dtStr.toString()).toLocal();
              final hour = dt.hour > 12
                  ? dt.hour - 12
                  : (dt.hour == 0 ? 12 : dt.hour);
              final amPm = dt.hour >= 12 ? 'م' : 'ص';
              timeStr =
                  '${hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} $amPm';
            } catch (_) {}
          }
          return {
            "sender": m['sender_name'] ?? 'مجهول',
            "message": m['message'] ?? '',
            "time": timeStr,
            "isMe": isMe,
            "type": m['message_type'] ?? 'text',
          };
        }).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('خطأ في تحميل الرسائل')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final userName = context.read<UserProvider>().userName;
    final now = DateTime.now();
    final hour = now.hour > 12
        ? now.hour - 12
        : (now.hour == 0 ? 12 : now.hour);
    final amPm = now.hour >= 12 ? 'م' : 'ص';
    final timeStr =
        '${hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} $amPm';

    setState(() {
      _messages.add({
        "sender": userName.isNotEmpty ? userName : 'أنت',
        "message": text,
        "time": timeStr,
        "isMe": true,
        "type": "text",
      });
      _messageController.clear();
    });

    try {
      await _chatService.sendMessage(text);
      _loadMessages();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('فشل الإرسال')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text('محادثة العمارة', style: TextStyle(fontSize: 16))],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.info_outline)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadMessages,
                    child: _messages.isEmpty
                        ? SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.7,
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.chat_bubble_outline,
                                      size: 64,
                                      color: AppColors.textSecondary,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'لا توجد رسائل بعد',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'ابدأ المحادثة مع سكان العمارة',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final msg = _messages[index];
                              final isMe = msg["isMe"] as bool;
                              final isAnnouncement =
                                  msg["type"] == "announcement";

                              if (isAnnouncement) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.primary.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.campaign,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              msg["sender"],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                            Text(
                                              msg["message"],
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        msg["time"],
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return Align(
                                alignment: isMe
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width *
                                        0.75,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isMe
                                        ? AppColors.primary
                                        : Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(16),
                                      topRight: const Radius.circular(16),
                                      bottomLeft: isMe
                                          ? const Radius.circular(16)
                                          : Radius.zero,
                                      bottomRight: isMe
                                          ? Radius.zero
                                          : const Radius.circular(16),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (!isMe)
                                        Text(
                                          msg["sender"],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      Text(
                                        msg["message"],
                                        style: TextStyle(
                                          color: isMe
                                              ? Colors.white
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        msg["time"],
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isMe
                                              ? Colors.white70
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ),
          // Input Bar
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.white,
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.attach_file,
                    color: AppColors.textSecondary,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'اكتب رسالة...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
