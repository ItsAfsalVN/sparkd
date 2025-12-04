import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sparkd/core/presentation/widgets/custom_button.dart';
import 'package:sparkd/core/presentation/widgets/custom_text_field.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'package:sparkd/core/utils/snackbar_helper.dart';
import 'package:sparkd/features/gigs/domain/entities/requirement_entity.dart';
import 'package:sparkd/core/services/storage_service.dart';
import 'package:sparkd/core/services/service_locator.dart';
import 'package:logger/logger.dart';

class SmeSpecifyRequirements extends StatefulWidget {
  final List<RequirementEntity> requirements;
  const SmeSpecifyRequirements({super.key, required this.requirements});

  @override
  State<SmeSpecifyRequirements> createState() => _SmeSpecifyRequirementsState();
}

class _SmeSpecifyRequirementsState extends State<SmeSpecifyRequirements> {
  final logger = Logger();
  final _storageService = sl<StorageService>();

  // Store text responses and file URLs
  final Map<String, String> _textResponses = {};
  final Map<String, String?> _fileUrls = {};
  final Map<String, bool> _uploadingFiles = {};

  Future<void> _pickAndUploadFile(RequirementEntity requirement) async {
    try {
      setState(() {
        _uploadingFiles[requirement.description] = true;
      });

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png', 'zip'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;

        // Upload to Firebase Storage
        final storagePath =
            'orders/requirements/${DateTime.now().millisecondsSinceEpoch}_$fileName';
        final downloadUrl = await _storageService.uploadImage(
          file,
          storagePath,
        );

        setState(() {
          _fileUrls[requirement.description] = downloadUrl;
          _uploadingFiles[requirement.description] = false;
        });

        logger.i('File uploaded successfully: $downloadUrl');

        if (mounted) {
          showSnackbar(
            context,
            'File uploaded successfully',
            SnackBarType.success,
          );
        }
      } else {
        setState(() {
          _uploadingFiles[requirement.description] = false;
        });
      }
    } catch (e) {
      logger.e('Error uploading file: $e');
      setState(() {
        _uploadingFiles[requirement.description] = false;
      });

      if (mounted) {
        showSnackbar(context, 'Failed to upload file: $e', SnackBarType.error);
      }
    }
  }

  void _removeFile(RequirementEntity requirement) {
    setState(() {
      _fileUrls[requirement.description] = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textStyles;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 2,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back, size: 24),
        ),
        title: Text("Specify Requirements", style: textStyles.heading3),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ListView(
                children: [
                  ...widget.requirements.map((requirement) {
                    final isUploading =
                        _uploadingFiles[requirement.description] ?? false;
                    final fileUrl = _fileUrls[requirement.description];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                requirement.type == RequirementType.file
                                    ? Icons.attach_file
                                    : Icons.text_fields,
                                size: 20,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  requirement.description,
                                  style: textStyles.subtext,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (requirement.type == RequirementType.file)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (fileUrl != null)
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: colorScheme.primary.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: colorScheme.primary,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'File uploaded successfully',
                                            style: textStyles.subtext.copyWith(
                                              color: colorScheme
                                                  .onPrimaryContainer,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.close,
                                            size: 20,
                                            color: colorScheme.error,
                                          ),
                                          onPressed: () =>
                                              _removeFile(requirement),
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  InkWell(
                                    onTap: isUploading
                                        ? null
                                        : () => _pickAndUploadFile(requirement),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      height: 120,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: colorScheme.surface,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: colorScheme.outline.withValues(
                                            alpha: .3,
                                          ),
                                        ),
                                      ),
                                      child: isUploading
                                          ? Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                CircularProgressIndicator(
                                                  color: colorScheme.primary,
                                                ),
                                                const SizedBox(height: 12),
                                                Text(
                                                  'Uploading...',
                                                  style: textStyles.paragraph
                                                      .copyWith(
                                                        color:
                                                            colorScheme.primary,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                ),
                                              ],
                                            )
                                          : Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.cloud_upload_outlined,
                                                  size: 48,
                                                  color: colorScheme.onSurface
                                                      .withValues(alpha: 0.4),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Tap to upload file',
                                                  style: textStyles.subtext
                                                      .copyWith(
                                                        color: colorScheme
                                                            .onSurface
                                                            .withValues(
                                                              alpha: 0.6,
                                                            ),
                                                      ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                const SizedBox(height: 4),
                                Text(
                                  'Accepted formats: PDF, DOC, DOCX, JPG, PNG, ZIP',
                                  style: textStyles.subtext.copyWith(
                                    fontSize: 12,
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.6,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else
                            CustomTextField(
                              showLabel: false,
                              hintText: 'Enter ${requirement.description}',
                              labelText: requirement.description,
                              maxLines: 3,
                              onChanged: (value) {
                                _textResponses[requirement.description] = value;
                              },
                            ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            CustomButton(
              onPressed: _canProceed() ? _handleBuyGig : null,
              title: "Buy Gig",
            ),
          ],
        ),
      ),
    );
  }

  bool _canProceed() {
    for (final requirement in widget.requirements) {
      if (requirement.type == RequirementType.file) {
        if (_fileUrls[requirement.description] == null) {
          return false;
        }
      } else {
        if (_textResponses[requirement.description]?.trim().isEmpty ?? true) {
          return false;
        }
      }
    }
    return true;
  }

  void _handleBuyGig() {
    logger.i('Text responses: $_textResponses');
    logger.i('File URLs: $_fileUrls');

    showSnackbar(context, 'Proceeding with order...', SnackBarType.info);
  }
}
