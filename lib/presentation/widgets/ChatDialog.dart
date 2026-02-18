// chat_dialog.dart
import 'package:carpooling_app/constants/themeAndColors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatDialog extends StatefulWidget {
  final String tripId;
  final String requestId;
  final String otherUserId;
  final String otherUserName;
  final String userType; 
  
  const ChatDialog({
    Key? key,
    required this.tripId,
    required this.requestId,
    required this.otherUserId,
    required this.otherUserName,
    required this.userType,
  }) : super(key: key);

  @override
  State<ChatDialog> createState() => _ChatDialogState();
}

class _ChatDialogState extends State<ChatDialog> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  
  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final message = _messageController.text.trim();
    _messageController.clear();

    try {
      // get current user info
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUserId)
          .get();
      
      final userData = userDoc.data() as Map<String, dynamic>;
      
      await FirebaseFirestore.instance
          .collection('trips')
          .doc(widget.tripId)
          .collection('joinRequests')
          .doc(widget.requestId)
          .collection('messages')
          .add({
        'senderId': currentUserId,
        'senderName': userData['fullName'] ?? 'Unknown',
        'senderType': widget.userType,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send message: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildChatHeader(isDarkMode),
            Expanded(child: _buildMessagesList(isDarkMode)),
            _buildMessageInput(isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildChatHeader(bool isDarkMode) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkBackground : AppColors.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.otherUserName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  widget.userType == 'driver' ? 'Passenger' : 'Driver',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close,
              color: Colors.white,
              size: 24.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(bool isDarkMode) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('trips')
          .doc(widget.tripId)
          .collection('joinRequests')
          .doc(widget.requestId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading messages',
              style: TextStyle(
                color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final messages = snapshot.data?.docs ?? [];
        
        if (messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 48.sp,
                  color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textLight,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Start your conversation',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        return ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.all(16.w),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final messageDoc = messages[index];
            final messageData = messageDoc.data() as Map<String, dynamic>;
            
            return _buildMessageBubble(messageData, isDarkMode);
          },
        );
      },
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> messageData, bool isDarkMode) {
    final isMyMessage = messageData['senderId'] == currentUserId;
    final timestamp = messageData['timestamp'] as Timestamp?;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMyMessage) ...[
            CircleAvatar(
              radius: 16.r,
              backgroundColor: AppColors.primary.withOpacity(0.2),
              child: Icon(
                Icons.person,
                size: 16.sp,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 8.w),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: isMyMessage 
                    ? AppColors.primary 
                    : (isDarkMode ? AppColors.darkBackground : AppColors.surfaceLight),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                  bottomLeft: isMyMessage ? Radius.circular(16.r) : Radius.circular(4.r),
                  bottomRight: isMyMessage ? Radius.circular(4.r) : Radius.circular(16.r),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    messageData['message'] ?? '',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isMyMessage 
                          ? Colors.white 
                          : (isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary),
                    ),
                  ),
                  if (timestamp != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      _formatMessageTime(timestamp.toDate()),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isMyMessage 
                            ? Colors.white.withOpacity(0.8)
                            : (isDarkMode ? AppColors.darkTextSecondary : AppColors.textLight),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isMyMessage) ...[
            SizedBox(width: 8.w),
            CircleAvatar(
              radius: 16.r,
              backgroundColor: AppColors.primary.withOpacity(0.2),
              child: Icon(
                Icons.person,
                size: 16.sp,
                color: AppColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput(bool isDarkMode) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkBackground : AppColors.surfaceLight,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16.r),
          bottomRight: Radius.circular(16.r),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(
                  color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.r),
                  borderSide: BorderSide(
                    color: isDarkMode ? AppColors.darkBorder : AppColors.border,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.r),
                  borderSide: BorderSide(
                    color: isDarkMode ? AppColors.darkBorder : AppColors.border,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.r),
                  borderSide: BorderSide(color: AppColors.primary, width: 2.w),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                filled: true,
                fillColor: isDarkMode ? AppColors.darkSurface : Colors.white,
              ),
              style: TextStyle(
                color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          SizedBox(width: 8.w),
          CircleAvatar(
            radius: 24.r,
            backgroundColor: AppColors.primary,
            child: IconButton(
              onPressed: _sendMessage,
              icon: Icon(
                Icons.send,
                color: Colors.white,
                size: 20.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return "${difference.inDays}d ago";
    } else if (difference.inHours > 0) {
      return "${difference.inHours}h ago";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes}m ago";
    }
    return "Just now";
  }
}