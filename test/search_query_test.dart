import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_bloc_list_manager/flutter_bloc_list_manager.dart';

void main() {
  group('SearchQueryCubit', () {
    test('sets an initial state', () {
      final bloc = SearchQueryCubit();
      expect(bloc.state, '');
    });

    blocTest<SearchQueryCubit, String>(
      'sets and clears queries',
      build: () => SearchQueryCubit(),
      act: (cubit) => cubit
        ..setQuery('search1')
        ..setQuery('')
        ..setQuery('search2')
        ..clearQuery(),
      expect: ['search1', '', 'search2', ''],
    );

    blocTest<SearchQueryCubit, String>(
      'stores query state lowercase',
      build: () => SearchQueryCubit(),
      act: (cubit) => cubit.setQuery('ABC'),
      expect: ['abc'],
    );
  });
}
