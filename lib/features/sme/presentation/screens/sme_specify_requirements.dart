import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sparkd/core/presentation/widgets/custom_button.dart';
import 'package:sparkd/core/presentation/widgets/custom_text_field.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'package:sparkd/core/utils/snackbar_helper.dart';
import 'package:sparkd/features/gigs/domain/entities/gig_entity.dart';
import 'package:sparkd/features/gigs/domain/entities/requirement_entity.dart';
import 'package:sparkd/features/orders/domain/entities/order_entity.dart';
import 'package:sparkd/features/orders/domain/entities/order_status.dart';
import 'package:sparkd/features/orders/presentation/bloc/order_bloc.dart';
import 'package:sparkd/features/orders/presentation/bloc/order_event.dart';
import 'package:sparkd/features/orders/presentation/bloc/order_state.dart';
import 'package:sparkd/core/services/storage_service.dart';
import 'package:sparkd/core/services/service_locator.dart';
import 'package:logger/logger.dart';

class SmeSpecifyRequirements extends StatefulWidget {
  final GigEntity gig;
  const SmeSpecifyRequirements({super.key, required this.gig});

  @override
  State<SmeSpecifyRequirements> createState() => _SmeSpecifyRequirementsState();
}

class _SmeSpecifyRequirementsState extends State<SmeSpecifyRequirements> {
  final logger = Logger();
  final _storageService = sl<StorageService>();

  // Store text responses and selected files
  final Map<String, String> _textResponses = {};
  final Map<String, File?> _selectedFiles = {};
  bool _isUploading = false;

  Future<void> _pickFile(RequirementEntity requirement) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png', 'zip'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);

        setState(() {
          _selectedFiles[requirement.description] = file;
        });

        logger.i('File selected: ${result.files.single.name}');

        if (mounted) {
          showSnackbar(
            context,
            'File selected: ${result.files.single.name}',
            SnackBarType.success,
          );
        }
      }
    } catch (e) {
      logger.e('Error selecting file: $e');

      if (mounted) {
        showSnackbar(context, 'Failed to select file: $e', SnackBarType.error);
      }
    }
  }

  void _removeFile(RequirementEntity requirement) {
    setState(() {
      _selectedFiles[requirement.description] = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textStyles;
    final colorScheme = Theme.of(context).colorScheme;

    return BlocProvider(
      create: (context) => sl<OrderBloc>(),
      child: BlocListener<OrderBloc, OrderState>(
        listener: (context, state) {
          if (state is OrderCreated) {
            showSnackbar(
              context,
              'Order request sent successfully! Waiting for Spark to accept.',
              SnackBarType.success,
            );
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          } else if (state is OrderError) {
            showSnackbar(
              context,
              'Failed to send order: ${state.message}',
              SnackBarType.error,
            );
          }
        },
        child: _buildScaffold(context, textStyles, colorScheme),
      ),
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    dynamic textStyles,
    ColorScheme colorScheme,
  ) {
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
                  ...widget.gig.requirements.map((requirement) {
                    final selectedFile =
                        _selectedFiles[requirement.description];

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
                                if (selectedFile != null)
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
                                          Icons.attach_file,
                                          color: colorScheme.primary,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            selectedFile.path.split('/').last,
                                            style: textStyles.subtext.copyWith(
                                              color: colorScheme.onPrimary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.close,
                                            size: 20,
                                            color: colorScheme.onPrimary,
                                          ),
                                          onPressed: () =>
                                              _removeFile(requirement),
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  InkWell(
                                    onTap: _isUploading
                                        ? null
                                        : () => _pickFile(requirement),
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
                                      child: _isUploading
                                          ? Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                CircularProgressIndicator(
                                                  color: colorScheme.primary,
                                                ),
                                              ],
                                            )
                                          : Column(
                                              spacing: 2,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.cloud_upload_outlined,
                                                  size: 32,
                                                  color: colorScheme.onSurface
                                                      .withValues(alpha: 0.2),
                                                ),
                                                Text(
                                                  'Tap to upload file',
                                                  style: textStyles.subtext
                                                      .copyWith(
                                                        color: colorScheme
                                                            .onSurface
                                                            .withValues(
                                                              alpha: 0.4,
                                                            ),
                                                        fontSize: 14.0,
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
                                    fontSize: 12.0,
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
                                setState(() {
                                  _textResponses[requirement.description] =
                                      value;
                                });
                              },
                            ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            BlocBuilder<OrderBloc, OrderState>(
              builder: (context, state) {
                final isLoading = state is OrderCreating || _isUploading;
                return CustomButton(
                  onPressed: _canProceed() && !isLoading
                      ? () => _handleSendOrderRequest(context)
                      : null,
                  title: _isUploading
                      ? "Uploading Files..."
                      : isLoading
                      ? "Sending Request..."
                      : "Send Order Request",
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  bool _canProceed() {
    for (final requirement in widget.gig.requirements) {
      if (requirement.type == RequirementType.file) {
        if (_selectedFiles[requirement.description] == null) {
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

  Future<void> _handleSendOrderRequest(BuildContext context) async {
    logger.i('Text responses: $_textResponses');
    logger.i('Selected files: $_selectedFiles');

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      showSnackbar(context, 'Please login first', SnackBarType.error);
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Upload all files first
      final Map<String, String> uploadedUrls = {};
      for (final entry in _selectedFiles.entries) {
        if (entry.value != null) {
          final file = entry.value!;
          final fileName = file.path.split('/').last;
          final storagePath =
              'orders/requirements/${DateTime.now().millisecondsSinceEpoch}_$fileName';

          logger.i('Uploading file: $fileName to $storagePath');
          final downloadUrl = await _storageService.uploadImage(
            file,
            storagePath,
          );
          uploadedUrls[entry.key] = downloadUrl;
          logger.i('File uploaded successfully: $downloadUrl');
        }
      }

      // Merge text responses and file URLs into single map
      final Map<String, dynamic> requirementResponses = {};
      _textResponses.forEach((key, value) {
        requirementResponses[key] = {'type': 'text', 'value': value};
      });
      uploadedUrls.forEach((key, url) {
        requirementResponses[key] = {'type': 'file', 'url': url};
      });

      final order = OrderEntity(
        gigID: widget.gig.id!,
        smeID: currentUser.uid,
        sparkID: widget.gig.creatorId!,
        gigTitle: widget.gig.title,
        gigPrice: widget.gig.price,
        gigThumbnail: widget.gig.thumbnailImage ?? '',
        requirements: widget.gig.requirements,
        requirementResponses: requirementResponses,
        status: OrderStatus.pendingSparkAcceptance,
        createdAt: DateTime.now(),
      );

      if (mounted) {
        context.read<OrderBloc>().add(CreateOrderRequestEvent(order: order));
      }
    } catch (e) {
      logger.e('Error uploading files: $e');
      if (mounted) {
        showSnackbar(context, 'Failed to upload files: $e', SnackBarType.error);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }
}
