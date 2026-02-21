import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:niraah/core/state/status.dart';
import 'package:niraah/features/home/domain/entities/post.dart';
import 'package:niraah/features/home/presentation/bloc/home_bloc.dart';
import 'package:niraah/features/home/presentation/bloc/home_event.dart';
import 'package:niraah/features/home/presentation/bloc/home_state.dart';
import 'package:niraah/features/home/presentation/pages/home_page.dart';

class MockHomeBloc extends MockBloc<HomeEvent, HomeState> implements HomeBloc {}

void main() {
  late HomeBloc bloc;

  setUp(() {
    bloc = MockHomeBloc();
  });

  testWidgets('renders post list on success', (WidgetTester tester) async {
    whenListen(
      bloc,
      Stream<HomeState>.fromIterable(
        <HomeState>[
          HomeState(
            status: Status.success,
            posts: const <Post>[
              Post(id: 1, title: 'First', body: 'Body 1'),
              Post(id: 2, title: 'Second', body: 'Body 2'),
            ],
          ),
        ],
      ),
      initialState: const HomeState(status: Status.loading),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: HomePage(bloc: bloc),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('First'), findsOneWidget);
    expect(find.text('Second'), findsOneWidget);
  });
}
