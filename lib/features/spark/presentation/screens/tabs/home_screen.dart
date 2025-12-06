import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkd/core/services/service_locator.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'package:sparkd/features/orders/presentation/bloc/spark_orders_bloc.dart';
import 'package:sparkd/features/orders/presentation/bloc/spark_orders_event.dart';
import 'package:sparkd/features/orders/presentation/bloc/spark_orders_state.dart';
import 'package:sparkd/features/orders/presentation/screens/spark_order_requests_screen.dart';

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
                                    const SparkOrderRequestsScreen(),
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
          body: Center(),
        ),
      ),
    );
  }
}
