import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:bloc_filter_search_list/bloc_filter_search_list.dart';

import './mocks.dart';

class MockFilterConditionsBloc
    extends MockBloc<FilterConditionsEvent, FilterConditionsState>
    implements FilterConditionsBloc {}

void main() {
  const _mockItem1 = MockItemClass(
    id: 'idValue1',
    name: 'nameValue1',
    extra: 'extraValue1',
    conditional: true,
  );
  const _mockItem2 = MockItemClass(
    id: 'idValue2',
    name: 'nameValue2',
    extra: 'extraValue2',
    conditional: true,
  );
  const _mockItem3 = MockItemClass(
    id: 'idValue3',
    name: 'nameValue3',
    extra: 'extraValue3',
    conditional: true,
  );

  group('ItemListBloc', () {
    MockFilterConditionsBloc _filterConditionsBloc;
    MockSourceBloc _sourceBloc;

    setUp(() {
      _filterConditionsBloc = MockFilterConditionsBloc();
      _sourceBloc = MockSourceBloc();

      // ensure bloc listeners can be attached
      whenListen(_filterConditionsBloc, Stream.value(null));
      whenListen(_sourceBloc, Stream.value(null));
    });

    blocTest(
      'sets an initial state',
      build: () async {
        return ItemListBloc<MockItemClass, MockSourceBlocClassItems,
            MockSourceBlocState>(
          filterConditionsBloc: _filterConditionsBloc,
          sourceBloc: _sourceBloc,
        );
      },
      skip: 0,
      expect: [EmptySource()],
    );

    blocTest(
      'requires initialized filter conditions',
      build: () async {
        when(_sourceBloc.state)
            .thenReturn(MockSourceBlocClassItems([_mockItem1]));

        return ItemListBloc<MockItemClass, MockSourceBlocClassItems,
            MockSourceBlocState>(
          filterConditionsBloc: _filterConditionsBloc,
          sourceBloc: _sourceBloc,
        );
      },
      expect: [],
    );

    blocTest(
      'requires a source bloc state with items',
      build: () async {
        when(_filterConditionsBloc.state).thenReturn(ConditionsInitialized(
          activeConditions: {},
          availableConditions: {},
        ));

        return ItemListBloc<MockItemClass, MockSourceBlocClassItems,
            MockSourceBlocState>(
          filterConditionsBloc: _filterConditionsBloc,
          sourceBloc: _sourceBloc,
        );
      },
      expect: [],
    );

    blocTest(
      'returns all source items with no active filter conditions',
      build: () async {
        when(_filterConditionsBloc.state).thenReturn(ConditionsInitialized(
          activeConditions: {},
          availableConditions: {},
        ));

        when(_sourceBloc.state).thenReturn(
          MockSourceBlocClassItems([_mockItem1]),
        );

        return ItemListBloc<MockItemClass, MockSourceBlocClassItems,
            MockSourceBlocState>(
          filterConditionsBloc: _filterConditionsBloc,
          sourceBloc: _sourceBloc,
        );
      },
      expect: [
        ItemListResults([_mockItem1])
      ],
    );

    blocTest(
      'sets filter empty state with no source items matching active conditions',
      build: () async {
        when(_filterConditionsBloc.state).thenReturn(ConditionsInitialized(
          activeConditions: {
            'id': ['123'],
          },
          availableConditions: {},
        ));

        when(_sourceBloc.state).thenReturn(
          MockSourceBlocClassItems([_mockItem1, _mockItem2, _mockItem3]),
        );

        return ItemListBloc<MockItemClass, MockSourceBlocClassItems,
            MockSourceBlocState>(
          filterConditionsBloc: _filterConditionsBloc,
          sourceBloc: _sourceBloc,
        );
      },
      expect: [
        NoFilteredResults()
      ],
    );

    blocTest(
      'returns source items matching a single active condition key',
      build: () async {
        when(_filterConditionsBloc.state).thenReturn(ConditionsInitialized(
          activeConditions: {
            'id': [_mockItem1.id, _mockItem3.id],
          },
          availableConditions: {},
        ));

        when(_sourceBloc.state).thenReturn(
          MockSourceBlocClassItems([_mockItem1, _mockItem2, _mockItem3]),
        );

        return ItemListBloc<MockItemClass, MockSourceBlocClassItems,
            MockSourceBlocState>(
          filterConditionsBloc: _filterConditionsBloc,
          sourceBloc: _sourceBloc,
        );
      },
      expect: [
        ItemListResults([_mockItem1, _mockItem3])
      ],
    );

    blocTest(
      'returns source items matching multiple active condition keys',
      build: () async {
        when(_filterConditionsBloc.state).thenReturn(ConditionsInitialized(
          activeConditions: {
            'id': [_mockItem1.id],
            'extra': [_mockItem3.extra],
          },
          availableConditions: {},
        ));

        when(_sourceBloc.state).thenReturn(
          MockSourceBlocClassItems([_mockItem1, _mockItem2, _mockItem3]),
        );

        return ItemListBloc<MockItemClass, MockSourceBlocClassItems,
            MockSourceBlocState>(
          filterConditionsBloc: _filterConditionsBloc,
          sourceBloc: _sourceBloc,
        );
      },
      expect: [
        ItemListResults([_mockItem1, _mockItem3])
      ],
    );
  });
}
