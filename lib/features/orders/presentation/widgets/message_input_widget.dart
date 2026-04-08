import 'package:flutter/material.dart';
import 'package:sparkd/core/presentation/widgets/custom_message_box.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'package:sparkd/features/orders/domain/entities/order_status.dart';

class MessageInputAreaWidget extends StatelessWidget {
  final TextEditingController messageController;
  final VoidCallback onSendMessage;
  final VoidCallback onAttachPressed;
  final bool isLoadingName;
  final String? otherPartyName;
  final String dueInText;
  final String clientLabel;
  final bool isSme;
  final bool showPastDueWarning;
  final String pastDueWarningText;
  final bool showMarkAsCompletedButton;
  final VoidCallback onMarkAsCompletedPressed;
  final bool isChatDisabled;
  final OrderStatus orderStatus;
  final ColorScheme colorScheme;
  final AppTextThemeExtension textStyles;

  const MessageInputAreaWidget({
    super.key,
    required this.messageController,
    required this.onSendMessage,
    required this.onAttachPressed,
    required this.isLoadingName,
    required this.otherPartyName,
    required this.dueInText,
    required this.clientLabel,
    required this.isSme,
    required this.showPastDueWarning,
    required this.pastDueWarningText,
    required this.showMarkAsCompletedButton,
    required this.onMarkAsCompletedPressed,
    required this.isChatDisabled,
    required this.orderStatus,
    required this.colorScheme,
    required this.textStyles,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: colorScheme.surface),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        spacing: 8,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Client and spark details
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    clientLabel,
                    style: textStyles.subtext.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  if (isLoadingName)
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
                      otherPartyName ?? 'Unknown',
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
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  Text(
                    dueInText,
                    style: textStyles.heading5.copyWith(height: 1),
                  ),
                ],
              ),
            ],
          ),
          if (showMarkAsCompletedButton)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onMarkAsCompletedPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Mark as Completed',
                  style: textStyles.heading5.copyWith(
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          if (showPastDueWarning)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: colorScheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.error.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                spacing: 8,
                children: [
                  Icon(
                    Icons.warning_rounded,
                    color: colorScheme.error,
                    size: 20,
                  ),
                  Expanded(
                    child: Text(
                      pastDueWarningText,
                      style: textStyles.subtext.copyWith(
                        color: colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: CustomMessageBox(
                  disabled: isChatDisabled,
                  controller: messageController,
                  onAttachPressed: onAttachPressed,
                ),
              ),
              SizedBox(
                height: 50,
                width: 50,
                child: IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                  ),
                  icon: Icon(Icons.send_rounded, color: colorScheme.onPrimary),
                  onPressed: onSendMessage,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
