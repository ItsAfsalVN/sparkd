import 'dart:io';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'package:sparkd/core/utils/snackbar_helper.dart';
import 'package:sparkd/core/utils/user_helper.dart';
import 'package:sparkd/features/orders/domain/entities/order_entity.dart';
import 'package:sparkd/features/orders/domain/entities/workshop_message_entity.dart';
import 'package:sparkd/features/orders/domain/entities/order_status.dart';
import 'package:sparkd/features/orders/presentation/bloc/workshop_bloc.dart';
import 'package:sparkd/features/orders/presentation/bloc/workshop_event.dart';
import 'package:sparkd/features/orders/presentation/bloc/workshop_state.dart';
import 'package:sparkd/core/utils/logger.dart';
import 'package:sparkd/features/orders/presentation/widgets/requirement_widgets.dart';
import 'package:sparkd/features/orders/presentation/widgets/message_bubble_widget.dart';
import 'package:sparkd/features/orders/presentation/widgets/image_attachment_widget.dart';
import 'package:sparkd/features/orders/presentation/widgets/dialog_widgets.dart';
import 'package:sparkd/features/orders/presentation/widgets/message_input_widget.dart';

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
  Map<String, String> _downloadedFiles = {}; // Track downloaded files locally
  List<WorkshopMessageEntity> _lastLoadedMessages =
      []; // Track last loaded messages
  bool _isOrderCompleted = false; // Track if order has been marked as completed

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();
    _tabController = TabController(length: 3, vsync: this);

    // Restore downloaded files from both Bloc cache and SharedPreferences
    _restoreDownloadedFiles();

    context.read<WorkshopBloc>().add(
      WorkshopLoadMessages(orderId: widget.order.id!),
    );
    _loadOtherPartyName();
  }

  /// Restore downloaded files cache from SharedPreferences and Bloc
  Future<void> _restoreDownloadedFiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getCacheKey();
      final cachedFiles = prefs.getString(cacheKey);

      if (cachedFiles != null && cachedFiles.isNotEmpty) {
        final filesMap = _parseJsonStringToMap(cachedFiles);
        setState(() {
          _downloadedFiles = filesMap;
        });
      } else {
        final bloc = context.read<WorkshopBloc>();
        final blocCache = bloc.getDownloadedFilesCache();
        setState(() {
          _downloadedFiles = blocCache;
        });
      }
    } catch (e) {
      logger.e('Error restoring downloaded files: $e');
      final bloc = context.read<WorkshopBloc>();
      setState(() {
        _downloadedFiles = bloc.getDownloadedFilesCache();
      });
    }
  }

  /// Save downloaded files to SharedPreferences for persistence
  Future<void> _saveDownloadedFilesToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getCacheKey();
      final jsonString = jsonEncode(_downloadedFiles);
      await prefs.setString(cacheKey, jsonString);
    } catch (e) {
      logger.e('Error saving downloaded files to SharedPreferences: $e');
    }
  }

  /// Generate a unique cache key for this order
  String _getCacheKey() => 'workshop_downloads_${widget.order.id}';

  /// Parse JSON string back to Map<String, String>
  Map<String, String> _parseJsonStringToMap(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is Map) {
        return Map<String, String>.from(decoded);
      }
    } catch (e) {
      logger.e('Error parsing JSON string to map: $e');
    }
    return {};
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
          if (state is WorkshopFileDownloadSuccess) {
            setState(() {
              // Don't clear! Just merge new downloads with existing ones
              _downloadedFiles.addAll(state.downloadedFiles);
            });

            // Save to SharedPreferences for persistence across navigations (fire and forget)
            _saveDownloadedFilesToPrefs();

            // Clear image cache to force reload of images
            imageCache.clear();
            imageCache.clearLiveImages();

            final message = Platform.isAndroid
                ? '✓ Downloaded!\nLocation: Downloads/Sparkd folder'
                : '✓ Downloaded!\nCheck app Documents folder in Files app.';
            showSnackbar(context, message, SnackBarType.success);
          }
          if (state is WorkshopFileDownloadError) {
            showSnackbar(
              context,
              'Download failed: ${state.message}',
              SnackBarType.error,
            );
          }
          if (state is WorkshopFileDownloadInProgress) {
            setState(() {});
          }
          if (state is WorkshopLoaded) {
            final blocCache = context
                .read<WorkshopBloc>()
                .getDownloadedFilesCache();
            setState(() {
              if (blocCache.isNotEmpty) {
                _downloadedFiles.addAll(blocCache);
              }
            });
            _saveDownloadedFilesToPrefs();
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

                  // Handle WorkshopLoaded state
                  if (state is WorkshopLoaded) {
                    _lastLoadedMessages = state.messages;
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

                    return _buildMessagesContent(
                      messages,
                      colorScheme,
                      textStyles,
                    );
                  }

                  // Handle download states and other states
                  // Show last loaded messages if available
                  if (_lastLoadedMessages.isNotEmpty) {
                    return _buildMessagesContent(
                      _lastLoadedMessages,
                      colorScheme,
                      textStyles,
                    );
                  }

                  // Fallback for unknown states
                  return Center(
                    child: CircularProgressIndicator(
                      color: colorScheme.primary,
                    ),
                  );
                },
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

  /// Check if the deadline has passed
  bool _isPastDue() {
    if (widget.order.deadline == null) return false;
    return DateTime.now().isAfter(widget.order.deadline!);
  }

  /// Get the number of days remaining (negative if past due)
  int _getDaysRemaining() {
    if (widget.order.deadline == null) return 0;
    return widget.order.deadline!.difference(DateTime.now()).inDays;
  }

  /// Get past due status text
  String _getPastDueStatusText() {
    if (!_isPastDue()) return '';
    final daysOverdue = _getDaysRemaining().abs();
    return '$daysOverdue ${daysOverdue == 1 ? 'day' : 'days'} overdue';
  }

  /// Check if chat should be disabled
  bool _isChatDisabled() {
    return widget.order.status == OrderStatus.completed || _isOrderCompleted;
  }

  /// Build Requirements Tab - Display SME responses to requirements
  Widget _buildRequirementsTab(
    ColorScheme colorScheme,
    AppTextThemeExtension textStyles,
  ) {
    return RequirementsTabWidget(
      requirements: widget.order.requirements,
      requirementResponses: widget.order.requirementResponses,
      colorScheme: colorScheme,
      textStyles: textStyles,
    );
  }

  /// Show confirmation dialog to mark order as delivered
  void _showMarkAsCompletedDialog() {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textStyles;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return MarkAsCompletedDialog(
          colorScheme: colorScheme,
          textStyles: textStyles,
          onConfirm: _markOrderAsCompleted,
        );
      },
    );
  }

  void _markOrderAsCompleted() {
    context.read<WorkshopBloc>().add(
      WorkshopMarkOrderAsCompleted(orderId: widget.order.id!),
    );
    setState(() {
      _isOrderCompleted = true;
    });
    showSnackbar(context, 'Order marked as completed', SnackBarType.success);
  }

  Widget _buildMessagesContent(
    List<WorkshopMessageEntity> messages,
    ColorScheme colorScheme,
    AppTextThemeExtension textStyles,
  ) {
    return ListenableBuilder(
      listenable: _tabController,
      builder: (context, child) {
        return Column(
          children: [
            TabBar(
              controller: _tabController,
              dividerHeight: 0,
              indicatorSize: TabBarIndicatorSize.tab,
              labelPadding: const EdgeInsets.symmetric(vertical: 12),
              unselectedLabelColor: colorScheme.onSurface.withValues(
                alpha: 0.5,
              ),
              tabs: [
                Text(
                  "Requirements",
                  style: textStyles.heading4.copyWith(
                    fontWeight: FontWeight.normal,
                  ),
                ),
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
                  _buildRequirementsTab(colorScheme, textStyles),
                  ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.all(10),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isCurrentUser =
                          message.senderId ==
                          FirebaseAuth.instance.currentUser?.uid;

                      return MessageBubbleWidget(
                        message: message,
                        isCurrentUser: isCurrentUser,
                        colorScheme: colorScheme,
                        textStyles: textStyles,
                        downloadedFiles: _downloadedFiles,
                        buildImageAttachment: _buildImageAttachment,
                        formatTime: _formatTime,
                      );
                    },
                  ),
                  FileListTabWidget(
                    messages: messages,
                    scrollController: _scrollController,
                    colorScheme: colorScheme,
                    textStyles: textStyles,
                    buildImageAttachment: _buildImageAttachment,
                    formatTime: _formatTime,
                  ),
                ],
              ),
            ),
            if (_tabController.index == 1)
              _buildMessageInputArea(colorScheme, textStyles),
          ],
        );
      },
    );
  }

  Widget _buildMessageInputArea(
    ColorScheme colorScheme,
    AppTextThemeExtension textStyles,
  ) {
    return MessageInputAreaWidget(
      messageController: _messageController,
      onSendMessage: _sendMessage,
      onAttachPressed: _onAttachPressed,
      isLoadingName: _isLoadingName,
      otherPartyName: _otherPartyName,
      dueInText: _buildDueInText(),
      clientLabel: widget.isSme ? "Brought by" : "Client",
      isSme: widget.isSme,
      showPastDueWarning:
          widget.order.status == OrderStatus.inProgress &&
          _isPastDue() &&
          !widget.isSme,
      pastDueWarningText: '${_getPastDueStatusText()} - Please deliver ASAP',
      showMarkAsCompletedButton:
          widget.isSme && widget.order.status == OrderStatus.inProgress,
      onMarkAsCompletedPressed: _showMarkAsCompletedDialog,
      isChatDisabled: _isChatDisabled(),
      orderStatus: widget.order.status,
      colorScheme: colorScheme,
      textStyles: textStyles,
    );
  }

  String _buildDueInText() {
    if (widget.order.deadline == null) return 'N/A';
    if (widget.order.status == OrderStatus.inProgress) {
      return _isPastDue()
          ? _getPastDueStatusText()
          : '${_getDaysRemaining()} days';
    }
    return widget.order.status.toString().split('.').last.toUpperCase();
  }

  Widget _buildImageAttachment(String url, bool isCurrentUser) {
    final colorScheme = Theme.of(context).colorScheme;

    return ImageAttachmentWidget(
      url: url,
      isCurrentUser: isCurrentUser,
      downloadedFiles: _downloadedFiles,
      colorScheme: colorScheme,
    );
  }
}
