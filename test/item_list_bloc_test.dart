import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_bloc_list_manager/flutter_bloc_list_manager.dart';
import 'package:flutter_bloc_list_manager/src/utils.dart';

import './mocks.dart';

class MockFilterConditionsBloc
    extends MockBloc<FilterConditionsEvent, FilterConditionsState>
    implements FilterConditionsBloc {}

class MockSearchQueryBloc extends MockBloc<SearchQueryEvent, String>
    implements SearchQueryBloc {}

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
    conditional: false,
  );
  const _mockItem3 = MockItemClass(
    id: 'idValue3',
    name: 'nameValue3',
    extra: 'extraValue3',
    conditional: true,
  );

  group('ItemListBloc', () {
    MockFilterConditionsBloc _filterConditionsBloc;
    MockSearchQueryBloc _searchQueryBloc;
    MockSourceBloc _sourceBloc;

    setUp(() {
      _filterConditionsBloc = MockFilterConditionsBloc();
      _searchQueryBloc = MockSearchQueryBloc();
      _sourceBloc = MockSourceBloc();
    });

    blocTest(
      'sets an initial state',
      build: () async {
        return ItemListBloc<MockItemClass, MockSourceBlocClassItems>(
          filterConditionsBloc: _filterConditionsBloc,
          searchQueryBloc: _searchQueryBloc,
          sourceBloc: _sourceBloc,
        );
      },
      skip: 0,
      expect: [NoSourceItems()],
    );

    blocTest(
      'requires initialized filter conditions',
      build: () async {
        whenListen(
          _sourceBloc,
          Stream.value(MockSourceBlocClassItems([_mockItem1])),
        );

        return ItemListBloc<MockItemClass, MockSourceBlocClassItems>(
          filterConditionsBloc: _filterConditionsBloc,
          searchQueryBloc: _searchQueryBloc,
          sourceBloc: _sourceBloc,
        );
      },
      expect: [],
    );

    blocTest(
      'requires a source bloc state with items',
      build: () async {
        whenListen(
          _filterConditionsBloc,
          Stream.value(
            ConditionsInitialized(
              activeConditions: <String>{},
              availableConditions: {},
            ),
          ),
        );
        whenListen(_searchQueryBloc, Stream.value(''));

        return ItemListBloc<MockItemClass, MockSourceBlocClassItems>(
          filterConditionsBloc: _filterConditionsBloc,
          searchQueryBloc: _searchQueryBloc,
          sourceBloc: _sourceBloc,
        );
      },
      expect: [],
    );

    blocTest(
      'returns all source items with no active filter conditions',
      build: () async {
        whenListen(
          _filterConditionsBloc,
          Stream.value(
            ConditionsInitialized(
              activeConditions: <String>{},
              availableConditions: {},
            ),
          ),
        );
        whenListen(_searchQueryBloc, Stream.value(''));
        whenListen(
          _sourceBloc,
          Stream.value(MockSourceBlocClassItems([_mockItem1])),
        );

        return ItemListBloc<MockItemClass, MockSourceBlocClassItems>(
          filterConditionsBloc: _filterConditionsBloc,
          searchQueryBloc: _searchQueryBloc,
          sourceBloc: _sourceBloc,
        );
      },
      expect: [
        ItemResults([_mockItem1])
      ],
    );

    blocTest(
      'sets filter empty state with no source items matching active conditions',
      build: () async {
        whenListen(
          _filterConditionsBloc,
          Stream.value(
            ConditionsInitialized(
              activeConditions: <String>{
                generateConditionKey('id', '123'),
              },
              availableConditions: {},
            ),
          ),
        );
        whenListen(_searchQueryBloc, Stream.value(''));
        whenListen(
          _sourceBloc,
          Stream.value(
            MockSourceBlocClassItems([_mockItem1, _mockItem2, _mockItem3]),
          ),
        );

        return ItemListBloc<MockItemClass, MockSourceBlocClassItems>(
          filterConditionsBloc: _filterConditionsBloc,
          searchQueryBloc: _searchQueryBloc,
          sourceBloc: _sourceBloc,
        );
      },
      expect: [ItemEmptyState()],
    );

    blocTest(
      'returns source items matching a single active condition key',
      build: () async {
        whenListen(
          _filterConditionsBloc,
          Stream.value(
            ConditionsInitialized(
              activeConditions: <String>{
                generateConditionKey('id', _mockItem1.id),
                generateConditionKey('id', _mockItem3.id),
              },
              availableConditions: {},
            ),
          ),
        );
        whenListen(_searchQueryBloc, Stream.value(''));
        whenListen(
          _sourceBloc,
          Stream.value(
            MockSourceBlocClassItems([_mockItem1, _mockItem2, _mockItem3]),
          ),
        );

        return ItemListBloc<MockItemClass, MockSourceBlocClassItems>(
          filterConditionsBloc: _filterConditionsBloc,
          searchQueryBloc: _searchQueryBloc,
          sourceBloc: _sourceBloc,
        );
      },
      expect: [
        ItemResults([_mockItem1, _mockItem3])
      ],
    );

    blocTest(
      'returns source items matching a single active boolean condition key',
      build: () async {
        whenListen(
          _filterConditionsBloc,
          Stream.value(
            ConditionsInitialized(
              activeConditions: <String>{
                generateConditionKey('conditional', 'True'),
              },
              availableConditions: {},
            ),
          ),
        );
        whenListen(_searchQueryBloc, Stream.value(''));
        whenListen(
          _sourceBloc,
          Stream.value(
            MockSourceBlocClassItems([_mockItem1, _mockItem2, _mockItem3]),
          ),
        );

        return ItemListBloc<MockItemClass, MockSourceBlocClassItems>(
          filterConditionsBloc: _filterConditionsBloc,
          searchQueryBloc: _searchQueryBloc,
          sourceBloc: _sourceBloc,
        );
      },
      expect: [
        ItemResults([_mockItem1, _mockItem3])
      ],
    );

    blocTest(
      'returns source items matching multiple active condition keys',
      build: () async {
        whenListen(
          _filterConditionsBloc,
          Stream.value(
            ConditionsInitialized(
              activeConditions: <String>{
                generateConditionKey('id', _mockItem1.id),
                generateConditionKey('conditional', 'True'),
              },
              availableConditions: {},
            ),
          ),
        );
        whenListen(_searchQueryBloc, Stream.value(''));
        whenListen(
          _sourceBloc,
          Stream.value(
            MockSourceBlocClassItems([_mockItem1, _mockItem2, _mockItem3]),
          ),
        );

        return ItemListBloc<MockItemClass, MockSourceBlocClassItems>(
          filterConditionsBloc: _filterConditionsBloc,
          searchQueryBloc: _searchQueryBloc,
          sourceBloc: _sourceBloc,
        );
      },
      expect: [
        ItemResults([_mockItem1, _mockItem3])
      ],
    );

    blocTest(
      'returns source items matching only a query',
      build: () async {
        whenListen(
          _filterConditionsBloc,
          Stream.value(
            ConditionsInitialized(
              activeConditions: <String>{},
              availableConditions: {},
            ),
          ),
        );
        whenListen(_searchQueryBloc, Stream.value('value2'));
        whenListen(
          _sourceBloc,
          Stream.value(
            MockSourceBlocClassItems([_mockItem1, _mockItem2, _mockItem3]),
          ),
        );

        return ItemListBloc<MockItemClass, MockSourceBlocClassItems>(
          filterConditionsBloc: _filterConditionsBloc,
          searchQueryBloc: _searchQueryBloc,
          sourceBloc: _sourceBloc,
          searchProperties: ['extra'],
        );
      },
      expect: [
        ItemResults([_mockItem2])
      ],
    );

    blocTest(
      'returns source items matching a query after filtering',
      build: () async {
        whenListen(
          _filterConditionsBloc,
          Stream.value(
            ConditionsInitialized(
              activeConditions: <String>{
                generateConditionKey('id', _mockItem1.id),
                generateConditionKey('id', _mockItem2.id),
                generateConditionKey('id', _mockItem3.id),
              },
              availableConditions: {},
            ),
          ),
        );
        whenListen(_searchQueryBloc, Stream.value('value2'));
        whenListen(
          _sourceBloc,
          Stream.value(
            MockSourceBlocClassItems([_mockItem1, _mockItem2, _mockItem3]),
          ),
        );

        return ItemListBloc<MockItemClass, MockSourceBlocClassItems>(
          filterConditionsBloc: _filterConditionsBloc,
          searchQueryBloc: _searchQueryBloc,
          sourceBloc: _sourceBloc,
          searchProperties: ['extra'],
        );
      },
      expect: [
        ItemResults([_mockItem2])
      ],
    );

    blocTest(
      'sets filter empty state with no source items matching query',
      build: () async {
        whenListen(
          _filterConditionsBloc,
          Stream.value(
            ConditionsInitialized(
              activeConditions: <String>{
                generateConditionKey('id', _mockItem1.id),
                generateConditionKey('id', _mockItem2.id),
                generateConditionKey('id', _mockItem3.id),
              },
              availableConditions: {},
            ),
          ),
        );
        whenListen(_searchQueryBloc, Stream.value('123'));
        whenListen(
          _sourceBloc,
          Stream.value(
            MockSourceBlocClassItems([_mockItem1, _mockItem2, _mockItem3]),
          ),
        );

        return ItemListBloc<MockItemClass, MockSourceBlocClassItems>(
          filterConditionsBloc: _filterConditionsBloc,
          searchQueryBloc: _searchQueryBloc,
          sourceBloc: _sourceBloc,
          searchProperties: ['extra'],
        );
      },
      expect: [ItemEmptyState()],
    );
  });
}
