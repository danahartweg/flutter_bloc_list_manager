import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_bloc_list_manager/flutter_bloc_list_manager.dart';

void main() {
  group('SearchQueryBloc', () {
    blocTest(
      'sets an initial state',
      build: () => Future.value(SearchQueryBloc()),
      skip: 0,
      expect: [''],
    );

    blocTest(
      'sets and clears queries',
      build: () => Future.value(SearchQueryBloc()),
      act: (bloc) {
        bloc
          ..add(SetSearchQuery('search1'))
          ..add(SetSearchQuery(''))
          ..add(SetSearchQuery('search2'))
          ..add(ClearSearchQuery());

        return;
      },
      expect: ['search1', '', 'search2', ''],
    );

    blocTest(
      'stores query state lowercase',
      build: () => Future.value(SearchQueryBloc()),
      act: (bloc) => bloc.add(SetSearchQuery('ABC')),
      expect: ['abc'],
    );
  });
}
