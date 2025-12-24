import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sparkd/core/services/service_locator.dart';
import 'package:sparkd/core/services/storage_service.dart';
import 'package:sparkd/core/presentation/widgets/custom_button.dart';
import 'package:sparkd/core/presentation/widgets/custom_dropdown.dart';
import 'package:sparkd/core/presentation/widgets/custom_text_field.dart';
import 'package:sparkd/features/gigs/presentation/widgets/deliverables_checklist.dart';
import 'package:sparkd/features/gigs/presentation/widgets/delivery_type_selector.dart';
import 'package:sparkd/features/gigs/presentation/widgets/image_upload.dart';
import 'package:sparkd/features/gigs/presentation/widgets/mandatory_requirements.dart';
import 'package:sparkd/features/gigs/presentation/widgets/multi_image_upload.dart';
import 'package:sparkd/features/spark/presentation/widgets/selectable_list.dart';
import 'package:sparkd/features/gigs/presentation/widgets/tag_input.dart';
import 'package:sparkd/features/gigs/presentation/widgets/video_upload.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'package:sparkd/core/utils/delivery_types.dart';
import 'package:sparkd/core/utils/form_statuses.dart';
import 'package:sparkd/core/utils/logger.dart';
import 'package:sparkd/core/utils/snackbar_helper.dart';
import 'package:sparkd/features/gigs/presentation/bloc/create_gig/create_gig_bloc.dart';
import 'package:sparkd/features/spark/data/datasources/static_skill_data_source.dart';
import 'package:sparkd/features/spark/domain/entities/skill_entity.dart';
import 'package:sparkd/features/gigs/domain/entities/requirement_entity.dart';

class CreateNewGigScreen extends StatefulWidget {
  const CreateNewGigScreen({super.key});

  @override
  State<CreateNewGigScreen> createState() => _CreateNewGigScreenState();
}

class _CreateNewGigScreenState extends State<CreateNewGigScreen> {
  final StaticSkillDataSource _staticDataSource = StaticSkillDataSource();
  String? _selectedCategoryId;
  List<Map<String, dynamic>> _categories = [];
  List<String> _gigTags = [];
  int? _deliveryTime;
  int? _revisions;
  List<String> _selectedDeliverables = [];

  // Upload state variables - store files until submit
  File? _thumbnailImageFile;
  List<File> _portfolioFiles = [];
  String? _demonstrationVideo;
  bool _isUploadingMedia = false;

  // New component state variables
  List<RequirementEntity> _mandatoryRequirements = [];
  DeliveryTypes? _selectedDeliveryType;

  // Text form field variables
  String _gigTitle = '';
  String _gigDescription = '';
  double _gigPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() {
    final categoriesData = _staticDataSource.getCategoriesWithTools();
    setState(() {
      _categories = categoriesData;
    });
  }

  void _onCategorySelected(String categoryId) {
    setState(() {
      // If the same category is tapped again, deselect it
      if (_selectedCategoryId == categoryId) {
        _selectedCategoryId = null;
      } else {
        _selectedCategoryId = categoryId;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textStyles;
    return BlocListener<CreateGigBloc, CreateGigState>(
      listener: (context, state) {
        if (state.status == FormStatus.success) {
          showSnackbar(
            context,
            "Gig created successfully!",
            SnackBarType.success,
          );
          Navigator.of(context).pop(true); // Return true to indicate success
        } else if (state.status == FormStatus.failure) {
          showSnackbar(
            context,
            "Failed to create gig. Please try again.",
            SnackBarType.error,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Create New Gig", style: textStyles.heading3),
          elevation: 0,
          scrolledUnderElevation: 0.0,
          surfaceTintColor: Colors.transparent,
        ),
        body: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 20,
                children: [
                  CustomTextField(
                    hintText: "Enter the gig title",
                    labelText: "Gig Title",
                    onChanged: (value) {
                      setState(() {
                        _gigTitle = value;
                      });
                    },
                  ),

                  // Category Selection
                  SelectableList(
                    label: "Select Category",
                    children: _categories.map((category) {
                      final categoryId = category['categoryId'] as String;
                      final categoryName = category['categoryName'] as String;
                      final isSelected = _selectedCategoryId == categoryId;

                      return SelectableChip(
                        label: categoryName,
                        value: categoryId,
                        isSelected: isSelected,
                        onTap: () => _onCategorySelected(categoryId),
                      );
                    }).toList(),
                  ),

                  // Tags Input
                  TagInput(
                    label: "Tags",
                    hintText: "Add tags to describe your gig...",
                    maxTags: 8,
                    maxTagLength: 15,
                    onTagsChanged: (tags) {
                      setState(() {
                        _gigTags = tags;
                      });
                      logger.i('Current gig tags: $_gigTags');
                    },
                    tagValidator: (tag) {
                      if (tag.contains(RegExp(r'[^\w\s]'))) {
                        return "Tags can only contain letters, numbers, and spaces";
                      }
                      if (tag.length < 2) {
                        return "Tags must be at least 2 characters long";
                      }
                      return null;
                    },
                  ),

                  CustomTextField(
                    hintText: "Enter the description",
                    labelText: "Description",
                    maxLines: 5,
                    onChanged: (value) {
                      setState(() {
                        _gigDescription = value;
                      });
                    },
                  ),

                  CustomTextField(
                    hintText: "Enter the Price",
                    labelText: "Price",
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SvgPicture.asset(
                        "assets/icons/rupee.svg",
                        colorFilter: ColorFilter.mode(
                          Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: .5),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),

                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _gigPrice = double.tryParse(value) ?? 0.0;
                      });
                    },
                  ),

                  // Delivery Time Dropdown
                  DeliveryTimeDropdown(
                    selectedDays: _deliveryTime,
                    onChanged: (days) {
                      setState(() {
                        _deliveryTime = days;
                      });
                      logger.d('Selected delivery time: $_deliveryTime days');
                    },
                  ),

                  // Revisions Dropdown
                  RevisionsDropdown(
                    selectedRevisions: _revisions,
                    onChanged: (revisions) {
                      setState(() {
                        _revisions = revisions;
                      });
                      logger.d('Selected revisions: $_revisions');
                    },
                  ),

                  // Deliverables Checklist
                  DeliverablesChecklist(
                    label: "What You'll Deliver",
                    selectedDeliverables: _selectedDeliverables,
                    maxSelections: 6,
                    onChanged: (deliverables) {
                      setState(() {
                        _selectedDeliverables = deliverables;
                      });
                      logger.d('Selected deliverables: $_selectedDeliverables');
                    },
                  ),

                  // Primary Thumbnail Upload
                  ImageUpload(
                    label: "Primary Thumbnail",
                    hintText: "Select main gig image",
                    imageFile: _thumbnailImageFile,
                    isRequired: true,
                    uploadImmediately: false,
                    onFileChanged: (file) {
                      setState(() {
                        _thumbnailImageFile = file;
                      });
                      logger.d('Thumbnail selected: ${file?.path}');
                    },
                  ),

                  // Portfolio Samples Upload
                  MultiImageUpload(
                    label: "Portfolio Samples",
                    hintText: "Select previous work samples",
                    imageFiles: _portfolioFiles,
                    maxImages: 5,
                    uploadImmediately: false,
                    onFilesChanged: (files) {
                      setState(() {
                        _portfolioFiles = files;
                      });
                      logger.d('Portfolio files selected: ${files.length}');
                    },
                  ),

                  // Service Demonstration Video
                  VideoUpload(
                    label: "Service Demonstration Video",
                    hintText: "Upload a demo video",
                    videoUrl: _demonstrationVideo,
                    allowUrlInput: false,
                    onChanged: (url) {
                      setState(() {
                        _demonstrationVideo = url;
                      });
                      logger.d('Demonstration video: $_demonstrationVideo');
                    },
                  ),

                  // Mandatory Requirements List
                  MandatoryRequirements(
                    label: "Client Requirements",
                    requirements: _mandatoryRequirements,
                    maxRequirements: 8,
                    hintText:
                        "Company logo, Brand colors, Product photos, etc.",
                    onChanged: (requirements) {
                      setState(() {
                        _mandatoryRequirements = requirements;
                      });
                      logger.d(
                        'Mandatory requirements: $_mandatoryRequirements',
                      );
                    },
                  ),

                  // Delivery Type Selector
                  DeliveryTypeSelector(
                    label: "Delivery Type",
                    selectedType: _selectedDeliveryType,
                    onChanged: (type) {
                      setState(() {
                        _selectedDeliveryType = type;
                      });
                      logger.d(
                        'Selected delivery type: $_selectedDeliveryType',
                      );
                    },
                  ),

                  // Submit Button with BLoC integration
                  BlocBuilder<CreateGigBloc, CreateGigState>(
                    builder: (context, state) {
                      final isLoading =
                          state.status == FormStatus.loading ||
                          _isUploadingMedia;
                      return CustomButton(
                        onPressed: isLoading ? null : () => _submitGig(context),
                        title: _isUploadingMedia
                            ? "Uploading Media..."
                            : state.status == FormStatus.loading
                            ? "Creating..."
                            : "Create Gig",
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ), // End of Scaffold child of BlocListener
    ); // End of BlocListener
  }

  Future<void> _submitGig(BuildContext context) async {
    logger.i('Screen: Submitting gig with current state');

    setState(() {
      _isUploadingMedia = true;
    });

    try {
      final storageService = sl<StorageService>();
      String? thumbnailUrl;
      List<String> portfolioUrls = [];

      // Upload thumbnail if selected
      if (_thumbnailImageFile != null) {
        logger.i('Uploading thumbnail image...');
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_thumb.jpg';
        thumbnailUrl = await storageService.uploadImage(
          _thumbnailImageFile!,
          'gigs/images/$fileName',
        );
        logger.i('Thumbnail uploaded: $thumbnailUrl');
      }

      // Upload portfolio images if selected
      if (_portfolioFiles.isNotEmpty) {
        logger.i('Uploading ${_portfolioFiles.length} portfolio images...');
        for (int i = 0; i < _portfolioFiles.length; i++) {
          final fileName =
              '${DateTime.now().millisecondsSinceEpoch}_portfolio_$i.jpg';
          final url = await storageService.uploadImage(
            _portfolioFiles[i],
            'gigs/portfolio/$fileName',
          );
          portfolioUrls.add(url);
        }
        logger.i('Portfolio images uploaded: ${portfolioUrls.length}');
      }

      setState(() {
        _isUploadingMedia = false;
      });

      // Create gig entity from current form state
      context.read<CreateGigBloc>().add(GigTitleChanged(_gigTitle));
      context.read<CreateGigBloc>().add(GigDescriptionChanged(_gigDescription));
      context.read<CreateGigBloc>().add(GigPriceChanged(_gigPrice));

      if (_selectedCategoryId != null) {
        final selectedCategory = _categories.firstWhere(
          (cat) => cat['categoryId'] == _selectedCategoryId,
        );
        context.read<CreateGigBloc>().add(
          GigCategoryChanged(
            SkillEntity(
              categoryID: selectedCategory['categoryId'] as String,
              categoryName: selectedCategory['categoryName'] as String,
              tools: [],
            ),
          ),
        );
      }

      context.read<CreateGigBloc>().add(GigTagsChanged(_gigTags));
      if (_deliveryTime != null) {
        context.read<CreateGigBloc>().add(
          GigDeliveryTimeChanged(_deliveryTime!),
        );
      }
      if (_revisions != null) {
        context.read<CreateGigBloc>().add(GigRevisionsChanged(_revisions!));
      }
      context.read<CreateGigBloc>().add(
        GigDeliverablesChanged(_selectedDeliverables),
      );
      if (thumbnailUrl != null) {
        context.read<CreateGigBloc>().add(GigThumbnailChanged(thumbnailUrl));
      }
      context.read<CreateGigBloc>().add(GigGalleryImagesChanged(portfolioUrls));
      if (_demonstrationVideo != null) {
        context.read<CreateGigBloc>().add(
          GigDemoVideoChanged(_demonstrationVideo),
        );
      }
      context.read<CreateGigBloc>().add(
        GigRequirementsChanged(_mandatoryRequirements),
      );
      if (_selectedDeliveryType != null) {
        context.read<CreateGigBloc>().add(
          GigDeliveryTypeChanged(_selectedDeliveryType!),
        );
      }

      // Submit the gig
      context.read<CreateGigBloc>().add(const CreateGigSubmitted());
    } catch (e) {
      logger.e('Error uploading media: $e');
      setState(() {
        _isUploadingMedia = false;
      });
      if (mounted) {
        showSnackbar(context, 'Failed to upload media: $e', SnackBarType.error);
      }
    }
  }
}
