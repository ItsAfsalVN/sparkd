import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkd/core/services/service_locator.dart' as sl;
import 'package:sparkd/features/gigs/presentation/bloc/create_gig/create_gig_bloc.dart';
import 'package:sparkd/features/spark/presentation/screens/create_new_gig_screen.dart';

class CreateNewGigProvider extends StatelessWidget {
  const CreateNewGigProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateGigBloc>(
      create: (context) => sl.sl<CreateGigBloc>(),
      child: const CreateNewGigScreen(),
    );
  }
}
