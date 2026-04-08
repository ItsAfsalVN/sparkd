import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkd/core/utils/logger.dart';
import 'package:sparkd/features/orders/presentation/bloc/workshop_bloc.dart';
import 'package:sparkd/features/orders/presentation/bloc/workshop_state.dart';

class ImageAttachmentWidget extends StatelessWidget {
  final String url;
  final bool isCurrentUser;
  final Map<String, String> downloadedFiles;
  final ColorScheme colorScheme;

  const ImageAttachmentWidget({
    super.key,
    required this.url,
    required this.isCurrentUser,
    required this.downloadedFiles,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final isDownloaded = downloadedFiles.containsKey(url);
    final localPath = isDownloaded ? downloadedFiles[url] : null;

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
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        Positioned(
          bottom: 3,
          right: 3,
          child: isDownloaded
              ? Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.check,
                    color: isCurrentUser
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                    size: 24,
                  ),
                )
              : BlocBuilder<WorkshopBloc, WorkshopState>(
                  builder: (context, innerState) {
                    if (innerState is WorkshopFileDownloadInProgress &&
                        innerState.fileUrl == url) {
                      return const SizedBox.shrink();
                    }
                    return const SizedBox.shrink();
                  },
                ),
        ),
      ],
    );
  }
}
