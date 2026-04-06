import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:file_picker/file_picker.dart';
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
import 'package:sparkd/core/utils/file_helper.dart';

class WorkshopScreen extends StatefulWidget {
  final OrderEntity order;
  final bool isSme;

  const WorkshopScreen({super.key, required this.order, required this.isSme});

  @override
  State<WorkshopScreen> createState() => _WorkshopScreenState();
}

class _WorkshopScreenState extends State<WorkshopScreen>
    with TickerProviderStateMixin {
  late TextEditingController _messageController;
  late ScrollController _scrollController;
  late TabController _tabController;
  bool _isLoadingName = true;
  String? _otherPartyName;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();
    _tabController = TabController(length: 2, vsync: this);
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
    _tabController.dispose();
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

  void _onAttachPressed() async {
    try {
      final file = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
      if (file != null && file.files.isNotEmpty) {
        context.read<WorkshopBloc>().add(
          WorkshopUploadMessageWithAttachment(
            userId: FirebaseAuth.instance.currentUser!.uid,
            senderId: FirebaseAuth.instance.currentUser!.uid,
            senderName:
                FirebaseAuth.instance.currentUser!.displayName ?? 'User',
            senderRole: widget.isSme ? 'sme' : 'spark',
            orderId: widget.order.id!,
            messageText: _messageController.text.trim(),
            file: file.files.first,
          ),
        );
        _messageController.clear();
      }
    } catch (e) {
      showSnackbar(context, 'Error picking file: $e', SnackBarType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textStyles;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        titleSpacing: 0,
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

                    return Column(
                      children: [
                        TabBar(
                          controller: _tabController,
                          dividerHeight: 0,
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelPadding: EdgeInsets.symmetric(vertical: 12),
                          unselectedLabelColor: colorScheme.onSurface
                              .withValues(alpha: 0.5),
                          tabs: [
                            Text(
                              "Messages",
                              style: textStyles.heading4.copyWith(
                                fontWeight: FontWeight.normal,
                              ),
                            ),

                            Text(
                              "Files",
                              style: textStyles.heading4.copyWith(
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              ListView.builder(
                                controller: _scrollController,
                                reverse: true,
                                padding: EdgeInsets.all(10),
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
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                            0.75,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isCurrentUser
                                            ? colorScheme.primary
                                            : colorScheme.surfaceContainer,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          topRight: Radius.circular(12),
                                          bottomLeft: Radius.circular(
                                            isCurrentUser ? 12 : 0,
                                          ),
                                          bottomRight: Radius.circular(
                                            isCurrentUser ? 0 : 12,
                                          ),
                                        ),
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
                                        spacing: 1,
                                        children: [
                                          if (message.attachmentUrls != null &&
                                              message
                                                  .attachmentUrls!
                                                  .isNotEmpty)
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              spacing: 2,
                                              children: message.attachmentUrls!.map((
                                                url,
                                              ) {
                                                if (FileHelper.isImage(
                                                  FileHelper.getFileName(url),
                                                )) {
                                                  return BlocBuilder<
                                                    WorkshopBloc,
                                                    WorkshopState
                                                  >(
                                                    builder: (context, state) {
                                                      final isDownloaded =
                                                          state
                                                              is WorkshopFileDownloadSuccess &&
                                                          state.downloadedFiles
                                                              .containsKey(url);
                                                      final localPath =
                                                          isDownloaded
                                                          ? state
                                                                .downloadedFiles[url]
                                                          : null;

                                                      return Stack(
                                                        children: [
                                                          Container(
                                                            width:
                                                                double.infinity,
                                                            height: 150,
                                                            decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                              image: DecorationImage(
                                                                fit: BoxFit
                                                                    .cover,
                                                                image:
                                                                    isDownloaded &&
                                                                        localPath !=
                                                                            null
                                                                    ? FileImage(
                                                                        File(
                                                                          localPath,
                                                                        ),
                                                                      )
                                                                    : NetworkImage(
                                                                            url,
                                                                          )
                                                                          as ImageProvider,
                                                              ),
                                                            ),
                                                          ),
                                                          if (!isDownloaded)
                                                            ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                              child: ImageFiltered(
                                                                imageFilter:
                                                                    ui.ImageFilter.blur(
                                                                      sigmaX: 8,
                                                                      sigmaY: 8,
                                                                    ),
                                                                child: Container(
                                                                  width: double
                                                                      .infinity,
                                                                  height: 150,
                                                                  color: Colors
                                                                      .black
                                                                      .withValues(
                                                                        alpha:
                                                                            0.3,
                                                                      ),
                                                                ),
                                                              ),
                                                            ),
                                                          Positioned(
                                                            bottom: 8,
                                                            right: 8,
                                                            child: isDownloaded
                                                                ? Container(
                                                                    decoration: BoxDecoration(
                                                                      color: Colors
                                                                          .green,
                                                                      shape: BoxShape
                                                                          .circle,
                                                                    ),
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                          8,
                                                                        ),
                                                                    child: Icon(
                                                                      Icons
                                                                          .check,
                                                                      color: Colors
                                                                          .white,
                                                                      size: 18,
                                                                    ),
                                                                  )
                                                                : BlocBuilder<
                                                                    WorkshopBloc,
                                                                    WorkshopState
                                                                  >(
                                                                    builder:
                                                                        (
                                                                          context,
                                                                          downloadState,
                                                                        ) {
                                                                          final isDownloading =
                                                                              downloadState
                                                                                  is WorkshopFileDownloadInProgress;

                                                                          return Container(
                                                                            decoration: BoxDecoration(
                                                                              color: Colors.blue,
                                                                              shape: BoxShape.circle,
                                                                            ),
                                                                            child:
                                                                                isDownloading
                                                                                ? SizedBox(
                                                                                    width: 40,
                                                                                    height: 40,
                                                                                    child: CircularProgressIndicator(
                                                                                      strokeWidth: 2,
                                                                                      valueColor:
                                                                                          AlwaysStoppedAnimation<
                                                                                            Color
                                                                                          >(
                                                                                            Colors.white,
                                                                                          ),
                                                                                      value: downloadState.progress,
                                                                                    ),
                                                                                  )
                                                                                : IconButton(
                                                                                    onPressed: () {
                                                                                      context
                                                                                          .read<
                                                                                            WorkshopBloc
                                                                                          >()
                                                                                          .add(
                                                                                            WorkshopDownloadFile(
                                                                                              fileUrl: url,
                                                                                              fileName: FileHelper.getFileName(
                                                                                                url,
                                                                                              ),
                                                                                            ),
                                                                                          );
                                                                                    },
                                                                                    icon: Icon(
                                                                                      Icons.download_rounded,
                                                                                      color: Colors.white,
                                                                                    ),
                                                                                  ),
                                                                          );
                                                                        },
                                                                  ),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                } else {
                                                  // Show file icon for non-image files
                                                  return GestureDetector(
                                                    onTap: () {
                                                      context
                                                          .read<WorkshopBloc>()
                                                          .add(
                                                            WorkshopDownloadFile(
                                                              fileUrl: url,
                                                              fileName:
                                                                  FileHelper.getFileName(
                                                                    url,
                                                                  ),
                                                            ),
                                                          );
                                                    },
                                                    child: Container(
                                                      padding: EdgeInsets.all(
                                                        12,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: colorScheme
                                                            .surfaceContainer,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        spacing: 8,
                                                        children: [
                                                          Icon(
                                                            FileHelper.getFileIcon(
                                                              url,
                                                            ),
                                                          ),
                                                          Flexible(
                                                            child: Text(
                                                              url
                                                                  .split('/')
                                                                  .last,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }
                                              }).toList(),
                                            ),
                                          Text(
                                            message.message,
                                            style: textStyles.paragraph
                                                .copyWith(
                                                  height: 1,
                                                  color: isCurrentUser
                                                      ? colorScheme.onPrimary
                                                      : colorScheme.onSurface,
                                                ),
                                          ),
                                          Text(
                                            _formatTime(message.sentAt),
                                            style: textStyles.subtext.copyWith(
                                              fontSize: 10,
                                              color: isCurrentUser
                                                  ? colorScheme.onPrimary
                                                        .withValues(alpha: 0.3)
                                                  : colorScheme.onSurface
                                                        .withValues(alpha: 0.4),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              SizedBox.expand(
                                child: Center(
                                  child: Text("File sharing coming soon!"),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                spacing: 4,
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
                        child: CustomMessageBox(
                          controller: _messageController,
                          onAttachPressed: _onAttachPressed,
                        ),
                      ),
                      SizedBox(
                        height: 50,
                        width: 50,
                        child: IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                          ),
                          icon: Icon(
                            Icons.send_rounded,
                            color: colorScheme.onPrimary,
                          ),
                          onPressed: _sendMessage,
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
