import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sparkd/core/presentation/widgets/ui_card.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'package:sparkd/features/orders/domain/entities/order_entity.dart';
import 'package:sparkd/features/orders/domain/entities/order_status.dart';
import 'package:timeago/timeago.dart' as timeago;

class OrderCard extends StatelessWidget {
  final OrderEntity order;
  final VoidCallback? onTap;

  const OrderCard({super.key, required this.order, this.onTap});

  String _statusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pendingSparkAcceptance:
        return 'Pending Acceptance';
      case OrderStatus.pendingPayment:
        return 'Pending Payment';
      case OrderStatus.inProgress:
        return 'In Progress';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color _statusColor(ColorScheme colorScheme, OrderStatus status) {
    switch (status) {
      case OrderStatus.pendingSparkAcceptance:
      case OrderStatus.pendingPayment:
        return colorScheme.tertiary;
      case OrderStatus.inProgress:
        return colorScheme.primary;
      case OrderStatus.completed:
        return colorScheme.primary;
      case OrderStatus.cancelled:
        return colorScheme.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textStyles;
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = _statusColor(colorScheme, order.status);

    return GestureDetector(
      onTap: onTap,
      child: UiCard(
        child: Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                order.gigThumbnail,
                width: double.infinity,
                height: 160,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 160,
                    color: colorScheme.surfaceContainerHighest,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    order.gigTitle,
                    style: textStyles.heading4,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Center(
                      child: Text(
                        _statusLabel(order.status),
                        style: textStyles.subtext.copyWith(
                          fontSize: 10,
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SvgPicture.asset(
                      "assets/icons/rupee.svg",
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        colorScheme.onSurface.withValues(alpha: .8),
                        BlendMode.srcIn,
                      ),
                    ),
                    Text(
                      order.gigPrice.toStringAsFixed(0),
                      style: textStyles.heading2.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: .8),
                        height: 1,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Created:",
                      style: textStyles.subtext.copyWith(
                        height: 1,
                        fontWeight: FontWeight.w900,
                        color: colorScheme.onSurface.withValues(alpha: .3),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: colorScheme.onSurface.withValues(alpha: .3),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timeago.format(order.createdAt),
                          style: textStyles.subtext.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: .3),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
