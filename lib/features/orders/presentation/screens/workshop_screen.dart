import 'dart:io';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import 'package:sparkd/core/utils/logger.dart';

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

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();
    _tabController = TabController(length: 2, vsync: this);

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

  Widget _buildMessagesContent(
    List<WorkshopMessageEntity> messages,
    ColorScheme colorScheme,
    AppTextThemeExtension textStyles,
  ) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          dividerHeight: 0,
          indicatorSize: TabBarIndicatorSize.tab,
          labelPadding: EdgeInsets.symmetric(vertical: 12),
          unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.5),
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
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      decoration: BoxDecoration(
                        color: isCurrentUser
                            ? colorScheme.primary
                            : colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                          bottomLeft: Radius.circular(isCurrentUser ? 12 : 0),
                          bottomRight: Radius.circular(isCurrentUser ? 0 : 12),
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
                              message.attachmentUrls!.isNotEmpty)
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 2,
                              children: message.attachmentUrls!.map((url) {
                                if (FileHelper.isImage(
                                  FileHelper.getFileName(url),
                                )) {
                                  return _buildImageAttachment(url);
                                } else {
                                  // Show file icon for non-image files
                                  return Stack(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(
                                          left: 8,
                                          right: 12,
                                          top: 8,
                                          bottom: 40,
                                        ),
                                        decoration: BoxDecoration(
                                          color: colorScheme.surface.withValues(
                                            alpha: 0.8,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          spacing: 8,
                                          children: [
                                            Icon(FileHelper.getFileIcon(url)),
                                            Flexible(
                                              child: Text(
                                                url.split('/').last,
                                                overflow: TextOverflow.visible,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 3,
                                        right: 3,
                                        child: BlocBuilder<WorkshopBloc, WorkshopState>(
                                          builder: (context, downloadState) {
                                            if (downloadState
                                                is WorkshopFileDownloadSuccess) {
                                              return Padding(
                                                padding: const EdgeInsets.all(
                                                  8.0,
                                                ),
                                                child: Icon(
                                                  Icons.check,
                                                  size: 24,
                                                  color: colorScheme.onSurface,
                                                ),
                                              );
                                            }
                                            return IconButton(
                                              onPressed: () {
                                                context.read<WorkshopBloc>().add(
                                                  WorkshopDownloadFile(
                                                    fileUrl: url,
                                                    fileName:
                                                        FileHelper.getFileName(
                                                          url,
                                                        ),
                                                  ),
                                                );
                                              },
                                              icon: Icon(
                                                size: 24,
                                                Icons.download_rounded,
                                                color: colorScheme.onSurface,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                }
                              }).toList(),
                            ),
                          if (message.message.isNotEmpty)
                            Text(
                              message.message,
                              style: textStyles.paragraph.copyWith(
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
                                  ? colorScheme.onPrimary.withValues(alpha: 0.3)
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
              ),
              SizedBox.expand(
                child: Center(child: Text("File sharing coming soon!")),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageAttachment(String url) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDownloaded = _downloadedFiles.containsKey(url);
    final localPath = isDownloaded ? _downloadedFiles[url] : null;

    return Stack(
      key: ValueKey('image_${url}_$isDownloaded'),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            height: 150,
            color: colorScheme.surfaceContainer,
            child: isDownloaded && localPath != null
                ? Image.file(
                    File(localPath),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      logger.e('Image.file error for $localPath: $error');
                      return Container(
                        color: colorScheme.surfaceContainer,
                        child: Icon(
                          Icons.error_outline,
                          color: colorScheme.onSurface,
                        ),
                      );
                    },
                  )
                : Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      logger.e('Image.network error for $url: $error');
                      return Container(
                        color: colorScheme.surfaceContainer,
                        child: Icon(
                          Icons.image_not_supported,
                          color: colorScheme.onSurface,
                        ),
                      );
                    },
                  ),
          ),
        ),
        // Show semi-transparent overlay only when not downloaded
        if (!isDownloaded)
          Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: colorScheme.surface.withValues(alpha: 0.7),
            ),
            child: Center(
              child: BlocBuilder<WorkshopBloc, WorkshopState>(
                builder: (context, innerState) {
                  // Show progress if downloading THIS specific URL
                  if (innerState is WorkshopFileDownloadInProgress &&
                      innerState.fileUrl == url) {
                    return SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.onSurface,
                        ),
                      ),
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
            ),
          ),
        Positioned(
          bottom: 3,
          right: 3,
          child: isDownloaded
              ? Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.check,
                    color: colorScheme.onSurface,
                    size: 24,
                  ),
                )
              : BlocBuilder<WorkshopBloc, WorkshopState>(
                  builder: (context, innerState) {
                    // Hide button only if downloading THIS specific URL
                    if (innerState is WorkshopFileDownloadInProgress &&
                        innerState.fileUrl == url) {
                      return SizedBox.shrink();
                    }
                    return IconButton(
                      onPressed: () {
                        context.read<WorkshopBloc>().add(
                          WorkshopDownloadFile(
                            fileUrl: url,
                            fileName: FileHelper.getFileName(url),
                          ),
                        );
                      },
                      icon: Icon(
                        size: 24,
                        Icons.download_rounded,
                        color: colorScheme.onSurface,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
