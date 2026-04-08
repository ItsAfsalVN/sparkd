import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'package:sparkd/core/utils/file_helper.dart';
import 'package:sparkd/features/orders/domain/entities/workshop_message_entity.dart';
import 'package:sparkd/features/orders/presentation/bloc/workshop_bloc.dart';
import 'package:sparkd/features/orders/presentation/bloc/workshop_event.dart';
import 'package:sparkd/features/orders/presentation/bloc/workshop_state.dart';

typedef BuildImageAttachmentCallback =
    Widget Function(String url, bool isCurrentUser);
typedef FormatTimeCallback = String Function(DateTime dateTime);

class MessageBubbleWidget extends StatelessWidget {
  final WorkshopMessageEntity message;
  final bool isCurrentUser;
  final ColorScheme colorScheme;
  final AppTextThemeExtension textStyles;
  final Map<String, String> downloadedFiles;
  final BuildImageAttachmentCallback buildImageAttachment;
  final FormatTimeCallback formatTime;

  const MessageBubbleWidget({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.colorScheme,
    required this.textStyles,
    required this.downloadedFiles,
    required this.buildImageAttachment,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isCurrentUser
              ? colorScheme.primary.withValues(alpha: .6)
              : colorScheme.surfaceContainer,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isCurrentUser ? 12 : 0),
            bottomRight: Radius.circular(isCurrentUser ? 0 : 12),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  if (FileHelper.isImage(FileHelper.getFileName(url))) {
                    return buildImageAttachment(url, isCurrentUser);
                  } else {
                    return FileAttachmentBubbleWidget(
                      fileUrl: url,
                      isCurrentUser: isCurrentUser,
                      colorScheme: colorScheme,
                      textStyles: textStyles,
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
              formatTime(message.sentAt),
              style: textStyles.subtext.copyWith(
                fontSize: 10,
                color: isCurrentUser
                    ? colorScheme.onPrimary.withValues(alpha: 0.3)
                    : colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FileAttachmentBubbleWidget extends StatelessWidget {
  final String fileUrl;
  final bool isCurrentUser;
  final ColorScheme colorScheme;
  final AppTextThemeExtension textStyles;

  const FileAttachmentBubbleWidget({
    super.key,
    required this.fileUrl,
    required this.isCurrentUser,
    required this.colorScheme,
    required this.textStyles,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.only(
            left: 8,
            right: 12,
            top: 8,
            bottom: 40,
          ),
          decoration: BoxDecoration(
            color: colorScheme.onSurface.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Icon(
                FileHelper.getFileIcon(fileUrl),
                color: isCurrentUser
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface,
              ),
              Flexible(
                child: Text(
                  style: textStyles.paragraph.copyWith(
                    color: isCurrentUser
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                    fontSize: 14,
                  ),
                  fileUrl.split('/').last,
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
              if (downloadState is WorkshopFileDownloadSuccess) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.check,
                    size: 24,
                    color: isCurrentUser
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                  ),
                );
              }
              return IconButton(
                onPressed: () {
                  context.read<WorkshopBloc>().add(
                    WorkshopDownloadFile(
                      fileUrl: fileUrl,
                      fileName: FileHelper.getFileName(fileUrl),
                    ),
                  );
                },
                icon: Icon(
                  size: 24,
                  Icons.download_rounded,
                  color: isCurrentUser
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class FileListTabWidget extends StatelessWidget {
  final List<WorkshopMessageEntity> messages;
  final ScrollController scrollController;
  final ColorScheme colorScheme;
  final AppTextThemeExtension textStyles;
  final BuildImageAttachmentCallback buildImageAttachment;
  final FormatTimeCallback formatTime;

  const FileListTabWidget({
    super.key,
    required this.messages,
    required this.scrollController,
    required this.colorScheme,
    required this.textStyles,
    required this.buildImageAttachment,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    final messagesWithAttachments = messages
        .where(
          (message) =>
              message.attachmentUrls != null &&
              message.attachmentUrls!.isNotEmpty,
        )
        .toList();

    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.all(10),
      controller: scrollController,
      itemCount: messagesWithAttachments.length,
      itemBuilder: (context, index) {
        final message = messagesWithAttachments[index];
        final isCurrentUser =
            message.senderId == FirebaseAuth.instance.currentUser?.uid;

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
                  ? colorScheme.primary.withValues(alpha: .6)
                  : colorScheme.surface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft: Radius.circular(isCurrentUser ? 12 : 0),
                bottomRight: Radius.circular(isCurrentUser ? 0 : 12),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: isCurrentUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 1,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 2,
                  children: message.attachmentUrls!.map((url) {
                    if (FileHelper.isImage(FileHelper.getFileName(url))) {
                      return buildImageAttachment(url, isCurrentUser);
                    } else {
                      return Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(
                              left: 8,
                              right: 12,
                              top: 8,
                              bottom: 40,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 8,
                              children: [
                                Icon(
                                  FileHelper.getFileIcon(url),
                                  color: isCurrentUser
                                      ? colorScheme.onPrimary
                                      : colorScheme.onSurface,
                                ),
                                Flexible(
                                  child: Text(
                                    style: textStyles.paragraph.copyWith(
                                      color: isCurrentUser
                                          ? colorScheme.onPrimary
                                          : colorScheme.onSurface,
                                      fontSize: 14,
                                    ),
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
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.check,
                                      size: 24,
                                      color: isCurrentUser
                                          ? colorScheme.onPrimary
                                          : colorScheme.onSurface,
                                    ),
                                  );
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
                                    color: isCurrentUser
                                        ? colorScheme.onPrimary
                                        : colorScheme.onSurface,
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
                Text(
                  formatTime(message.sentAt),
                  style: textStyles.subtext.copyWith(
                    fontSize: 10,
                    color: isCurrentUser
                        ? colorScheme.onPrimary.withValues(alpha: 0.3)
                        : colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
