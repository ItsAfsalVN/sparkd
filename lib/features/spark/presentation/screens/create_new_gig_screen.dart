import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sparkd/core/presentation/widgets/custom_button.dart';
import 'package:sparkd/core/presentation/widgets/custom_dropdown.dart';
import 'package:sparkd/core/presentation/widgets/custom_text_field.dart';
import 'package:sparkd/core/presentation/widgets/deliverables_checklist.dart';
import 'package:sparkd/core/presentation/widgets/delivery_type_selector.dart';
import 'package:sparkd/core/presentation/widgets/image_upload.dart';
import 'package:sparkd/core/presentation/widgets/mandatory_requirements.dart';
import 'package:sparkd/core/presentation/widgets/multi_image_upload.dart';
import 'package:sparkd/core/presentation/widgets/selectable_list.dart';
import 'package:sparkd/core/presentation/widgets/tag_input.dart';
import 'package:sparkd/core/presentation/widgets/video_upload.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'package:sparkd/core/utils/delivery_types.dart';
import 'package:sparkd/core/utils/logger.dart';
import 'package:sparkd/features/spark/data/datasources/static_skill_data_source.dart';

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

  // Upload state variables
  String? _thumbnailImage;
  List<String> _portfolioSamples = [];
  String? _demonstrationVideo;

  // New component state variables
  List<String> _mandatoryRequirements = [];
  DeliveryTypes? _selectedDeliveryType;

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
    return Scaffold(
      appBar: AppBar(
        title: Text("Create New Gig", style: textStyles.heading3),
        elevation: 0,
        scrolledUnderElevation: 0.0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 20,
              children: [
                CustomTextField(
                  hintText: "Enter the gig title",
                  labelText: "Gig Title",
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
                    logger.e('Current gig tags: $_gigTags');
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
                ),

                CustomTextField(
                  hintText: "Enter the Price",
                  labelText: "Price",
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(12),
                    child: SvgPicture.asset(
                      "assets/icons/spark/rupee.svg",
                      colorFilter: ColorFilter.mode(
                        Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: .5),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.number,
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
                  hintText: "Upload main gig image",
                  imageUrl: _thumbnailImage,
                  isRequired: true,
                  onChanged: (url) {
                    setState(() {
                      _thumbnailImage = url;
                    });
                    logger.d('Thumbnail image: $_thumbnailImage');
                  },
                ),

                // Portfolio Samples Upload
                MultiImageUpload(
                  label: "Portfolio Samples",
                  hintText: "Show your previous work",
                  imageUrls: _portfolioSamples,
                  maxImages: 5,
                  onChanged: (urls) {
                    setState(() {
                      _portfolioSamples = urls;
                    });
                    logger.d('Portfolio samples: $_portfolioSamples');
                  },
                ),

                // Service Demonstration Video
                VideoUpload(
                  label: "Service Demonstration Video",
                  hintText: "Upload or link to a demo video",
                  videoUrl: _demonstrationVideo,
                  allowUrlInput: true,
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
                  hintText: "Company logo, Brand colors, Product photos, etc.",
                  onChanged: (requirements) {
                    setState(() {
                      _mandatoryRequirements = requirements;
                    });
                    logger.d('Mandatory requirements: $_mandatoryRequirements');
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
                    logger.d('Selected delivery type: $_selectedDeliveryType');
                  },
                ),

                CustomButton(onPressed: () {}, title: "Create Gig"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
