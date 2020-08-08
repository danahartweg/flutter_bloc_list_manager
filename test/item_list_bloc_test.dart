import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_bloc_list_manager/flutter_bloc_list_manager.dart';
import 'package:flutter_bloc_list_manager/src/utils.dart';

import './mocks.dart';

class MockFilterConditionsBloc extends MockBloc<FilterConditionsState>
    implements FilterConditionsBloc {}

class MockSearchQueryCubit extends MockBloc<String>
    implements SearchQueryCubit {}

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
    MockSearchQueryCubit _searchQueryCubit;
    MockSourceBloc _sourceBloc;

    setUp(() {
      _filterConditionsBloc = MockFilterConditionsBloc();
      _searchQueryCubit = MockSearchQueryCubit();
      _sourceBloc = MockSourceBloc();
    });

    test('sets an initial state', () {
      final bloc = ItemListBloc<MockItemClass, MockSourceBlocClassItems>(
        filterConditionsBloc: _filterConditionsBloc,
        searchQueryCubit: _searchQueryCubit,
        sourceBloc: _sourceBloc,
      );

      expect(bloc.state, NoSourceItems());
    });

    blocTest<ItemListBloc, ItemListState>(
      'requires initialized filter conditions',
      build: () {
        whenListen<MockSourceBlocState>(
          _sourceBloc,
          Stream.value(MockSourceBlocClassItems([_mockItem1])),
        );

        return ItemListBloc<MockItemClass, MockSourceBlocClassItems>(
          filterConditionsBloc: _filterConditionsBloc,
          searchQueryCubit: _searchQueryCubit,
          sourceBloc: _sourceBloc,
        );
      },
      skip: 1,
      expect: [],
    );

    blocTest<ItemListBloc, ItemListState>(
      'requires a source bloc state with items',
      build: () {
        whenListen<FilterConditionsState>(
          _filterConditionsBloc,
          Stream.value(
            ConditionsInitialized(
              activeConditions: <String>{},
              availableConditions: {},
            ),
          ),
        );
        whenListen<String>(_searchQueryCubit, Stream.value(''));

        return ItemListBloc<MockItemClass, MockSourceBlocClassItems>(
          filterConditionsBloc: _filterConditionsBloc,
          searchQueryCubit: _searchQueryCubit,
          sourceBloc: _sourceBloc,
        );
      },
      skip: 1,
      expect: [],
    );

    blocTest<ItemListBloc, ItemListState>(
      'returns all source items with no active filter conditions',
      build: () {
        whenListen<FilterConditionsState>(
          _filterConditionsBloc,
          Stream.value(
            ConditionsInitialized(
              activeConditions: <String>{},
              availableConditions: {},
            ),
          ),
        );
        whenListen<String>(_searchQueryCubit, Stream.value(''));
        whenListen<MockSourceBlocState>(
          _sourceBloc,
          Stream.value(MockSourceBlocClassItems([_mockItem1])),
        );

        return ItemListBloc<MockItemClass, MockSourceBlocClassItems>(
          filterConditionsBloc: _filterConditionsBloc,
          searchQueryCubit: _searchQueryCubit,
          sourceBloc: _sourceBloc,
        );
      },
      expect: [
        ItemResults([_mockItem1])
      ],
    );

    blocTest<ItemListBloc, ItemListState>(
      'sets filter empty state with no source items matching active conditions',
      build: () {
        whenListen<FilterConditionsState>(
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
        whenListen<String>(_searchQueryCubit, Stream.value(''));
        whenListen<MockSourceBlocState>(
          _sourceBloc,
          Stream.value(
            MockSourceBlocClassItems([_mockItem1, _mockItem2, _mockItem3]),
          ),
        );

        return ItemListBloc<MockItemClass, MockSourceBlocClassItems>(
          filterConditionsBloc: _filterConditionsBloc,
          searchQueryCubit: _searchQueryCubit,
          sourceBloc: _sourceBloc,
        );
      },
      expect: [ItemEmptyState()],
    );

    blocTest<ItemListBloc, ItemListState>(
      'returns source items matching a single active condition key',
      build: () {
        whenListen<FilterConditionsState>(
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
        whenListen<String>(_searchQueryCubit, Stream.value(''));
        whenListen<MockSourceBlocState>(
          _sourceBloc,
          Stream.value(
            MockSourceBlocClassItems([_mockItem1, _mockItem2, _mockItem3]),
          ),
        );

        return ItemListBloc<MockItemClass, MockSourceBlocClassItems>(
          filterConditionsBloc: _filterConditionsBloc,
          searchQueryCubit: _searchQueryCubit,
          sourceBloc: _sourceBloc,
        );
      },
      expect: [
        ItemResults([_mockItem1, _mockItem3])
      ],
    );

    blocTest<ItemListBloc, ItemListState>(
      'returns source items matching a single active boolean condition key',
      build: () {
        whenListen<FilterConditionsState>(
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
        whenListen<String>(_searchQueryCubit, Stream.value(''));
        whenListen<MockSourceBlocState>(
          _sourceBloc,
          Stream.value(
            MockSourceBlocClassItems([_mockItem1, _mockItem2, _mockItem3]),
          ),
        );

        return ItemListBloc<MockItemClass, MockSourceBlocClassItems>(
          filterConditionsBloc: _filterConditionsBloc,
          searchQueryCubit: _searchQueryCubit,
          sourceBloc: _sourceBloc,
        );
      },
      expect: [
        ItemResults([_mockItem1, _mockItem3])
      ],
    );

    blocTest<ItemListBloc, ItemListState>(
      'returns source items matching multiple active condition keys',
      build: () {
        whenListen<FilterConditionsState>(
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
        whenListen<String>(_searchQueryCubit, Stream.value(''));
        whenListen<MockSourceBlocState>(
          _sourceBloc,
          Stream.value(
            MockSourceBlocClassItems([_mockItem1, _mockItem2, _mockItem3]),
          ),
        );

        return ItemListBloc<MockItemClass, MockSourceBlocClassItems>(
          filterConditionsBloc: _filterConditionsBloc,
          searchQueryCubit: _searchQueryCubit,
          sourceBloc: _sourceBloc,
        );
      },
      expect: [
        ItemResults([_mockItem1, _mockItem3])
      ],
    );

    blocTest<ItemListBloc, ItemListState>(
      'returns source items matching only a query',
      build: () {
        whenListen<FilterConditionsState>(
          _filterConditionsBloc,
          Stream.value(
            ConditionsInitialized(
              activeConditions: <String>{},
              availableConditions: {},
            ),
          ),
        );
        whenListen<String>(_searchQueryCubit, Stream.value('value2'));
        whenListen<MockSourceBlocState>(
          _sourceBloc,
          Stream.value(
            MockSourceBlocClassItems([_mockItem1, _mockItem2, _mockItem3]),
          ),
        );

        return ItemListBloc<MockItemClass, MockSourceBlocClassItems>(
          filterConditionsBloc: _filterConditionsBloc,
          searchQueryCubit: _searchQueryCubit,
          sourceBloc: _sourceBloc,
          searchProperties: ['extra'],
        );
      },
      expect: [
        ItemResults([_mockItem2])
      ],
    );

    blocTest<ItemListBloc, ItemListState>(
      'returns source items matching a query after filtering',
      build: () {
        whenListen<FilterConditionsState>(
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
        whenListen<String>(_searchQueryCubit, Stream.value('value2'));
        whenListen<MockSourceBlocState>(
          _sourceBloc,
          Stream.value(
            MockSourceBlocClassItems([_mockItem1, _mockItem2, _mockItem3]),
          ),
        );

        return ItemListBloc<MockItemClass, MockSourceBlocClassItems>(
          filterConditionsBloc: _filterConditionsBloc,
          searchQueryCubit: _searchQueryCubit,
          sourceBloc: _sourceBloc,
          searchProperties: ['extra'],
        );
      },
      expect: [
        ItemResults([_mockItem2])
      ],
    );

    blocTest<ItemListBloc, ItemListState>(
      'sets filter empty state with no source items matching query',
      build: () {
        whenListen<FilterConditionsState>(
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
        whenListen<String>(_searchQueryCubit, Stream.value('123'));
        whenListen<MockSourceBlocState>(
          _sourceBloc,
          Stream.value(
            MockSourceBlocClassItems([_mockItem1, _mockItem2, _mockItem3]),
          ),
        );

        return ItemListBloc<MockItemClass, MockSourceBlocClassItems>(
          filterConditionsBloc: _filterConditionsBloc,
          searchQueryCubit: _searchQueryCubit,
          sourceBloc: _sourceBloc,
          searchProperties: ['extra'],
        );
      },
      expect: [ItemEmptyState()],
    );
  });
}
