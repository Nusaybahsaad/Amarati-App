import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();

  final List<Map<String, dynamic>> _messages = [
    {
      "sender": "المشرف",
      "message": "السلام عليكم، تم جدولة صيانة المصعد يوم الأحد",
      "time": "10:30 ص",
      "isMe": false,
      "type": "announcement",
    },
    {
      "sender": "أحمد - 301",
      "message": "بارك الله فيكم",
      "time": "10:35 ص",
      "isMe": false,
      "type": "text",
    },
    {
      "sender": "أنت",
      "message": "هل الصيانة ستشمل المصعد الثاني؟",
      "time": "10:40 ص",
      "isMe": true,
      "type": "text",
    },
    {
      "sender": "المشرف",
      "message": "نعم، سيتم صيانة المصعدين",
      "time": "10:45 ص",
      "isMe": false,
      "type": "text",
    },
    {
      "sender": "سعد - 102",
      "message": "ممتاز 👍",
      "time": "10:50 ص",
      "isMe": false,
      "type": "text",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('محادثة عمارة النور', style: TextStyle(fontSize: 16)),
            Text(
              '12 عضو',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.info_outline)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg["isMe"] as bool;
                final isAnnouncement = msg["type"] == "announcement";

                if (isAnnouncement) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                style: const TextStyle(fontSize: 14),
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
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isMe ? AppColors.primary : Colors.white,
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
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isMe)
                          Text(
                            msg["sender"],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: isMe ? Colors.white70 : AppColors.primary,
                            ),
                          ),
                        Text(
                          msg["message"],
                          style: TextStyle(
                            color: isMe ? Colors.white : AppColors.textPrimary,
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
                    onPressed: () {
                      if (_messageController.text.isNotEmpty) {
                        setState(() {
                          _messages.add({
                            "sender": "أنت",
                            "message": _messageController.text,
                            "time": "الآن",
                            "isMe": true,
                            "type": "text",
                          });
                          _messageController.clear();
                        });
                      }
                    },
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
