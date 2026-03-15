import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkd/core/services/service_locator.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'package:sparkd/features/orders/presentation/bloc/spark_orders_bloc.dart';
import 'package:sparkd/features/orders/presentation/bloc/spark_orders_event.dart';
import 'package:sparkd/features/orders/presentation/bloc/spark_orders_state.dart';
import 'package:sparkd/features/orders/presentation/screens/spark_order_requests_screen.dart';
import 'package:sparkd/features/orders/presentation/screens/spark_notifications_screen.dart';

class SparkHomeScreen extends StatelessWidget {
  const SparkHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textStyles;
    final currentUser = FirebaseAuth.instance.currentUser;

    return BlocProvider(
      create: (context) =>
          sl<SparkOrdersBloc>()
            ..add(LoadSparkOrdersEvent(sparkId: currentUser!.uid)),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: kToolbarHeight + 10,
            elevation: 0,
            scrolledUnderElevation: 0.0,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 6,
                    children: [
                      CircleAvatar(radius: 20, backgroundColor: Colors.red),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hi,",
                            style: textStyles.subtext.copyWith(
                              height: 1,
                              fontWeight: FontWeight.w900,
                              fontSize: 16.0,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                          Text(
                            "Spark",
                            style: textStyles.heading4.copyWith(
                              fontSize: 24.0,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  BlocBuilder<SparkOrdersBloc, SparkOrdersState>(
                    builder: (context, state) {
                      final badgeCount = state is SparkOrdersLoaded
                          ? state.pendingOrders.length
                          : 0;

                      return Badge(
                        isLabelVisible: badgeCount > 0,
                        label: Text(badgeCount.toString()),
                        backgroundColor: colorScheme.error,
                        textColor: colorScheme.onError,
                        child: IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const SparkNotificationsScreen(),
                              ),
                            );
                          },
                          icon: Icon(Icons.notifications, size: 32),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          body: BlocBuilder<SparkOrdersBloc, SparkOrdersState>(
            builder: (context, state) {
              return Column(
                children: [
                  // Banner for pending orders
                  if (state is SparkOrdersLoaded &&
                      state.pendingOrders.isNotEmpty)
                    _OrderNotificationBanner(
                      pendingCount: state.pendingOrders.length,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const SparkOrderRequestsScreen(),
                          ),
                        );
                      },
                    ),
                  Expanded(child: Center()),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _OrderNotificationBanner extends StatelessWidget {
  final int pendingCount;
  final VoidCallback onTap;

  const _OrderNotificationBanner({
    required this.pendingCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textStyles;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary,
                colorScheme.primary.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_active,
                  color: colorScheme.onPrimary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$pendingCount New Order${pendingCount > 1 ? 's' : ''} Pending',
                      style: textStyles.heading4.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Review and respond to client requests',
                      style: textStyles.paragraph.copyWith(
                        fontSize: 14.0,
                        color: colorScheme.onPrimary.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: colorScheme.onPrimary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
