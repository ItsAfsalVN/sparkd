import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sparkd/core/presentation/widgets/custom_message_box.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'package:sparkd/core/utils/snackbar_helper.dart';
import 'package:sparkd/core/utils/user_helper.dart';
import 'package:sparkd/features/orders/domain/entities/order_entity.dart';
import 'package:sparkd/features/orders/domain/entities/workshop_message_entity.dart';
import 'package:sparkd/features/orders/presentation/bloc/workshop_bloc.dart';
import 'package:sparkd/features/orders/presentation/bloc/workshop_event.dart';
import 'package:sparkd/features/orders/presentation/bloc/workshop_state.dart';

class WorkshopScreen extends StatefulWidget {
  final OrderEntity order;
  final bool isSme;

  const WorkshopScreen({super.key, required this.order, required this.isSme});

  @override
  State<WorkshopScreen> createState() => _WorkshopScreenState();
}

class _WorkshopScreenState extends State<WorkshopScreen> {
  late TextEditingController _messageController;
  late ScrollController _scrollController;
  bool _isLoadingName = true;
  String? _otherPartyName;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();
    context.read<WorkshopBloc>().add(
      WorkshopLoadMessages(orderId: widget.order.id!),
    );
    _loadOtherPartyName();
  }

  Future<void> _loadOtherPartyName() async {
    try {
      final name = widget.isSme
          ? await UserHelper.getUserName(widget.order.sparkID)
          : await UserHelper.getSmeBusinessName(widget.order.smeID);

      if (mounted) {
        setState(() {
          _otherPartyName = name ?? 'Unknown';
          _isLoadingName = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _otherPartyName = 'Unknown';
          _isLoadingName = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) {
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final message = WorkshopMessageEntity(
      id: '${DateTime.now().microsecondsSinceEpoch}_${currentUser.uid.hashCode}',
      orderId: widget.order.id!,
      senderId: currentUser.uid,
      senderName: currentUser.displayName ?? 'User',
      senderRole: widget.isSme ? 'sme' : 'spark',
      message: _messageController.text.trim(),
      sentAt: DateTime.now(),
    );

    context.read<WorkshopBloc>().add(WorkshopSendMessage(message: message));
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textStyles;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.order.gigTitle, style: textStyles.heading4),
            Text(
              'Workshop',
              style: textStyles.subtext.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: BlocListener<WorkshopBloc, WorkshopState>(
        listener: (context, state) {
          if (state is WorkshopMessageSentError) {
            showSnackbar(context, state.message, SnackBarType.error);
          }
        },
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<WorkshopBloc, WorkshopState>(
                builder: (context, state) {
                  if (state is WorkshopLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                      ),
                    );
                  }

                  if (state is WorkshopError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 12,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: colorScheme.error,
                          ),
                          Text(
                            'Error loading messages',
                            style: textStyles.paragraph,
                          ),
                          Text(
                            state.message,
                            style: textStyles.subtext.copyWith(
                              color: colorScheme.error,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is WorkshopLoaded) {
                    final messages = state.messages;

                    if (messages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 2,
                          children: [
                            Icon(
                              Icons.chat_outlined,
                              size: 32,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.3,
                              ),
                            ),
                            Text(
                              'No messages yet',
                              style: textStyles.paragraph.copyWith(
                                fontSize: 12,
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isCurrentUser =
                            message.senderId ==
                            FirebaseAuth.instance.currentUser?.uid;

                        return Align(
                          alignment: isCurrentUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.75,
                            ),
                            decoration: BoxDecoration(
                              color: isCurrentUser
                                  ? colorScheme.primary
                                  : colorScheme.surfaceContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Column(
                              crossAxisAlignment: isCurrentUser
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  message.senderName,
                                  style: textStyles.subtext.copyWith(
                                    color: isCurrentUser
                                        ? colorScheme.onPrimary.withValues(
                                            alpha: 0.7,
                                          )
                                        : colorScheme.onSurface.withValues(
                                            alpha: 0.6,
                                          ),
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  message.message,
                                  style: textStyles.paragraph.copyWith(
                                    color: isCurrentUser
                                        ? colorScheme.onPrimary
                                        : colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatTime(message.sentAt),
                                  style: textStyles.subtext.copyWith(
                                    fontSize: 10,
                                    color: isCurrentUser
                                        ? colorScheme.onPrimary.withValues(
                                            alpha: 0.5,
                                          )
                                        : colorScheme.onSurface.withValues(
                                            alpha: 0.4,
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
            // Message input box
            Container(
              decoration: BoxDecoration(color: colorScheme.surface),
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Client and spark details
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.isSme ? "Brought by" : "Client",
                            style: textStyles.subtext.copyWith(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                          if (_isLoadingName)
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  colorScheme.primary,
                                ),
                              ),
                            )
                          else
                            Text(
                              _otherPartyName ?? 'Unknown',
                              style: textStyles.heading5.copyWith(height: 1),
                            ),
                        ],
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "Due in",
                            style: textStyles.subtext.copyWith(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                          Text(
                            widget.order.deadline != null
                                ? '${widget.order.deadline!.difference(DateTime.now()).inDays} days'
                                : 'N/A',
                            style: textStyles.heading5.copyWith(height: 1),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    spacing: 8,
                    children: [
                      Expanded(
                        child: CustomMessageBox(controller: _messageController),
                      ),
                      SizedBox(
                        height: 50,
                        width: 50,
                        child: CircleAvatar(
                          backgroundColor: colorScheme.primary,
                          child: IconButton(
                            icon: Icon(
                              Icons.send_rounded,
                              color: colorScheme.onPrimary,
                            ),
                            onPressed: _sendMessage,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
