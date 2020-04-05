import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bloc_filter_search_list/bloc_filter_search_list.dart';

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
  });
}
