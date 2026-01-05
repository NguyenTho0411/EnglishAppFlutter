import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/reading_bloc.dart';
import '../../domain/usecases/get_reading_passages.dart';
import '../../data/repositories/reading_repository_impl.dart';

class ReadingPage extends StatelessWidget {
  const ReadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReadingBloc(GetReadingPassages(ReadingRepositoryImpl()))
        ..add(LoadReadingPassages()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Reading Practice')),
        body: BlocBuilder<ReadingBloc, ReadingState>(
          builder: (context, state) {
            if (state is ReadingLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ReadingLoaded) {
              return ListView.builder(
                itemCount: state.passages.length,
                itemBuilder: (context, index) {
                  final passage = state.passages[index];
                  return ListTile(
                    title: Text(passage.title),
                    subtitle: Text('Questions: ${passage.questions.length}'),
                    onTap: () {
                      context.read<ReadingBloc>().add(SelectPassage(passage));
                      // Navigate to passage detail page
                    },
                  );
                },
              );
            } else if (state is ReadingError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const Center(child: Text('Select a passage to start reading.'));
          },
        ),
      ),
    );
  }
}