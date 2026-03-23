import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkd/core/presentation/widgets/custom_button.dart';
import 'package:sparkd/core/presentation/widgets/ui_card.dart';
import 'package:sparkd/core/services/service_locator.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'package:sparkd/core/utils/snackbar_helper.dart';
import 'package:sparkd/core/utils/user_helper.dart';
import 'package:sparkd/features/gigs/domain/entities/requirement_entity.dart';
import 'package:sparkd/features/orders/domain/entities/order_entity.dart';
import 'package:sparkd/features/orders/presentation/bloc/spark_orders_bloc.dart';
import 'package:sparkd/features/orders/presentation/bloc/spark_orders_event.dart';
import 'package:sparkd/features/orders/presentation/bloc/spark_orders_state.dart';
import 'package:timeago/timeago.dart' as timeago;

class SparkOrderRequestsScreen extends StatelessWidget {
  const SparkOrderRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return BlocProvider(
      create: (context) =>
          sl<SparkOrdersBloc>()
            ..add(LoadSparkOrdersEvent(sparkId: currentUser!.uid)),
      child: const _SparkOrderRequestsContent(),
    );
  }
}

class _SparkOrderRequestsContent extends StatelessWidget {
  const _SparkOrderRequestsContent();

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textStyles;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text('Order Requests', style: textStyles.heading3),
      ),
      body: BlocConsumer<SparkOrdersBloc, SparkOrdersState>(
        listener: (context, state) {
          if (state is OrderUpdateSuccess) {
            showSnackbar(context, state.message, SnackBarType.success);
            final currentUser = FirebaseAuth.instance.currentUser;
            context.read<SparkOrdersBloc>().add(
              LoadSparkOrdersEvent(sparkId: currentUser!.uid),
            );
          } else if (state is OrderUpdateError) {
            showSnackbar(context, state.message, SnackBarType.error);
          }
        },
        builder: (context, state) {
          if (state is SparkOrdersLoading) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          }

          if (state is SparkOrdersError) {
            return Center(
              child: Column(
                spacing: 16,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                  Text('Error: ${state.message}', style: textStyles.paragraph),
                ],
              ),
            );
          }

          if (state is SparkOrdersLoaded) {
            if (state.pendingOrders.isEmpty) {
              return Center(
                child: Column(
                  spacing: 16,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 80,
                      color: colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                    Text(
                      'No pending requests',
                      style: textStyles.heading4.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.pendingOrders.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final order = state.pendingOrders[index];
                return _OrderRequestCard(order: order);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _OrderRequestCard extends StatelessWidget {
  final OrderEntity order;

  const _OrderRequestCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textStyles;
    final colorScheme = Theme.of(context).colorScheme;

    return UiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
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
                  child: Icon(
                    Icons.image_not_supported,
                    color: colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                );
              },
            ),
          ),

          Text(
            order.gigTitle,
            style: textStyles.heading3,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹',
                    style: textStyles.heading4.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.8),
                      height: 1,
                    ),
                  ),
                  Text(
                    order.gigPrice.toStringAsFixed(0),
                    style: textStyles.heading2.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.8),
                      height: 1,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Ordered',
                    style: textStyles.subtext.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.3),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    timeago.format(order.createdAt),
                    style: textStyles.heading4.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),

          Column(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Client',
                style: textStyles.subtext.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.3),
                  fontWeight: FontWeight.w900,
                ),
              ),
              FutureBuilder<String?>(
                future: UserHelper.getUserName(order.smeID),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.primary,
                        ),
                      ),
                    );
                  }

                  return Text(
                    snapshot.data ?? 'Unknown',
                    style: textStyles.heading4.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  );
                },
              ),
            ],
          ),


          Text(
            'Requirements',
            style: textStyles.subtext.copyWith(
              fontWeight: FontWeight.w900,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ),
          ...order.requirements.map((requirement) {
            final response =
                order.requirementResponses[requirement.description];
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        requirement.type == RequirementType.text
                            ? Icons.text_fields
                            : Icons.attach_file,
                        size: 16,
                        color: colorScheme.primary,
                      ),

                      Expanded(
                        child: Text(
                          requirement.description,
                          style: textStyles.subtext.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (response != null)
                    Text(
                      response['type'] == 'text'
                          ? response['value']
                          : 'File uploaded',
                      style: textStyles.paragraph.copyWith(
                        fontSize: 14.0,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                ],
              ),
            );
          }),

          Row(
            spacing: 12,
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showRejectDialog(context);
                  },
                  icon: const Icon(Icons.close),
                  label: const Text('Reject'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.error,
                    side: BorderSide(color: colorScheme.error),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: CustomButton(
                  onPressed: () {
                    context.read<SparkOrdersBloc>().add(
                      AcceptOrderEvent(orderId: order.id!),
                    );
                  },
                  title: 'Accept',
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reject Order'),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(
              hintText: 'Enter rejection reason (optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<SparkOrdersBloc>().add(
                  RejectOrderEvent(
                    orderId: order.id!,
                    reason: reasonController.text.isEmpty
                        ? 'Not available at this time'
                        : reasonController.text,
                  ),
                );
                Navigator.pop(dialogContext);
              },
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );
  }
}
