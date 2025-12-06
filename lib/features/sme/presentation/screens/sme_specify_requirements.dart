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
                                        Expanded(
                                          child: Text(
                                            'File uploaded successfully',
                                            style: textStyles.subtext.copyWith(
                                              color: colorScheme.onPrimary,
                                              fontWeight: FontWeight.w600,
                                            ),
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
                                                        fontSize: 14,
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
            BlocBuilder<OrderBloc, OrderState>(
              builder: (context, state) {
                final isLoading = state is OrderCreating;
                return CustomButton(
                  onPressed: _canProceed() && !isLoading
                      ? () => _handleSendOrderRequest(context)
                      : null,
                  title: isLoading
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

  void _handleSendOrderRequest(BuildContext context) {
    logger.i('Text responses: $_textResponses');
    logger.i('File URLs: $_fileUrls');

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      showSnackbar(context, 'Please login first', SnackBarType.error);
      return;
    }

    // Merge text responses and file URLs into single map
    final Map<String, dynamic> requirementResponses = {};
    _textResponses.forEach((key, value) {
      requirementResponses[key] = {'type': 'text', 'value': value};
    });
    _fileUrls.forEach((key, value) {
      if (value != null) {
        requirementResponses[key] = {'type': 'file', 'url': value};
      }
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

    context.read<OrderBloc>().add(CreateOrderRequestEvent(order: order));
  }
}
