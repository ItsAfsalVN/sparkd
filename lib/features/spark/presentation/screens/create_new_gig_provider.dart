import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkd/core/services/service_locator.dart' as sl;
import 'package:sparkd/features/spark/presentation/bloc/gig/gig_bloc.dart';
import 'package:sparkd/features/spark/presentation/screens/create_new_gig_screen.dart';

class CreateNewGigProvider extends StatelessWidget {
  const CreateNewGigProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GigBloc>(
      create: (context) => sl.sl<GigBloc>(),
      child: const CreateNewGigScreen(),
    );
  }
}
