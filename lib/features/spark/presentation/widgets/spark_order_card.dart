import 'package:flutter/material.dart';
import 'package:sparkd/core/presentation/widgets/ui_card.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'package:sparkd/features/orders/domain/entities/order_entity.dart';
import 'package:sparkd/features/orders/domain/entities/order_status.dart';
import 'package:timeago/timeago.dart' as timeago;

class SparkOrderCard extends StatelessWidget {
  final OrderEntity order;

  const SparkOrderCard({super.key, required this.order});

  String _statusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pendingSparkAcceptance:
        return 'Pending Acceptance';
      case OrderStatus.pendingPayment:
        return 'Pending Payment';
      case OrderStatus.inProgress:
        return 'In Progress';
      case OrderStatus.delivered:
        return 'Delivered';
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
      case OrderStatus.delivered:
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

    return UiCard(
      child: Column(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              order.gigThumbnail,
              width: double.infinity,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 150,
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
          Text(
            order.gigTitle,
            style: textStyles.heading4,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _statusLabel(order.status),
                  style: textStyles.subtext.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                timeago.format(order.createdAt),
                style: textStyles.subtext.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          Row(
            spacing: 6,
            children: [
              Icon(
                Icons.payments_outlined,
                size: 18,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              Text(
                'INR ${order.gigPrice.toStringAsFixed(0)}',
                style: textStyles.heading4.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
