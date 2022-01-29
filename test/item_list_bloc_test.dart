import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc_list_manager/flutter_bloc_list_manager.dart';
import 'package:flutter_bloc_list_manager/src/utils.dart';
import 'package:flutter_test/flutter_test.dart';

import './mocks.dart';

void main() {
  const _mockItem1 = MockItemClass(
    id: 'idValue1',
    name: 'nameValue1',
    extra: 'extraValue1',
    common: 'first',
    conditional: true,
  );
  const _mockItem2 = MockItemClass(
    id: 'idValue2',
    name: 'nameValue2',
    extra: 'extraValue2',
    common: 'first',
    conditional: false,
  );
  const _mockItem3 = MockItemClass(
    id: 'idValue3',
    name: 'nameValue3',
    extra: 'extraValue3',
    common: 'value2',
    conditional: true,
  );

  group('ItemListBloc', () {
    late MockFilterConditionsBloc _filterConditionsBloc;
    late MockSearchQueryCubit _searchQueryCubit;
    late MockSourceBloc _sourceBloc;

    setUp(() {
      _filterConditionsBloc = MockFilterConditionsBloc();
      _searchQueryCubit = MockSearchQueryCubit();
      _sourceBloc = MockSourceBloc();
    });

    tearDown(() {
      _filterConditionsBloc.close();
      _searchQueryCubit.close();
      _sourceBloc.close();
    });

    test('sets an initial state', () {
      final bloc = ItemListBloc<MockItemClass, MockSourceBlocClassItems>(
        filterConditionsBloc: _filterConditionsBloc,
        searchQueryCubit: _searchQueryCubit,
        sourceBloc: _sourceBloc,
      );

      expect(bloc.state, const NoSourceItems());
    });

    blocTest<ItemListBloc, ItemListState>(
      'requires initialized filter conditions',
      build: () {
        whenListen<FilterConditionsState>(
          _filterConditionsBloc,
          Stream.value(
            const ConditionsUninitialized(),
          ),
        );

        whenListen<MockSourceBlocState>(
          _sourceBloc,
          Stream.value(const MockSourceBlocClassItems([_mockItem1])),
        );

        return ItemListBloc<MockItemClass, MockSourceBlocClassItems>(
          filterConditionsBloc: _filterConditionsBloc,
          searchQueryCubit: _searchQueryCubit,
          sourceBloc: _sourceBloc,
        );
      },
      skip: 1,
      expect: () => [],
    );

    blocTest<ItemListBloc, ItemListState>(
      'returns all source items with no active filter conditions',
      build: () {
        whenListen<FilterConditionsState>(
          _filterConditionsBloc,
          Stream.value(
            const ConditionsInitialized(
              activeAndConditions: {},
              activeOrConditions: {},
              availableConditions: {},
            ),
          ),
        );
        whenListen<String>(_searchQueryCubit, Stream.value(''));
        whenListen<MockSourceBlocState>(
          _sourceBloc,
          Stream.value(const MockSourceBlocClassItems([_mockItem1])),
        );

        return ItemListBloc<MockItemClass, MockSourceBlocClassItems>(
          filterConditionsBloc: _filterConditionsBloc,
          searchQueryCubit: _searchQueryCubit,
          sourceBloc: _sourceBloc,
        );
      },
      expect: () => [
        const ItemResults([_mockItem1]),
      ],
    );

    blocTest<ItemListBloc, ItemListState>(
      'sets filter empty state with no source items matching "or" conditions',
      build: () {
        whenListen<FilterConditionsState>(
          _filterConditionsBloc,
          Stream.value(
            ConditionsInitialized(
              activeAndConditions: const {},
              activeOrConditions: {
                generateConditionKey('id', '123'),
              },
              availableConditions: const {},
            ),
          ),
        );
        whenListen<String>(_searchQueryCubit, Stream.value(''));
        whenListen<MockSourceBlocState>(
          _sourceBloc,
          Stream.value(
            const MockSourceBlocClassItems(
                [_mockItem1, _mockItem2, _mockItem3]),
          ),
        );

        return ItemListBloc<MockItemClass, MockSourceBlocClassItems>(
          filterConditionsBloc: _filterConditionsBloc,
          searchQueryCubit: _searchQueryCubit,
          sourceBloc: _sourceBloc,
        );
      },
      expect: () => [
        const ItemEmptyState(),
      ],
    );

    blocTest<ItemListBloc, ItemListState>(
      'returns source items matching a single active "or" condition',
      build: () {
        whenListen<FilterConditionsState>(
          _filterConditionsBloc,
          Stream.value(
            ConditionsInitialized(
              activeAndConditions: const {},
              activeOrConditions: {
                generateConditionKey('id', _mockItem1.id),
                generateConditionKey('id', _mockItem3.id),
              },
              availableConditions: const {},
            ),
          ),
        );
        whenListen<String>(_searchQueryCubit, Stream.value(''));
        whenListen<MockSourceBlocState>(
          _sourceBloc,
          Stream.value(
            const MockSourceBlocClassItems(
                [_mockItem1, _mockItem2, _mockItem3]),
          ),
        );

        return ItemListBloc<MockItemClass, MockSourceBlocClassItems>(
          filterConditionsBloc: _filterConditionsBloc,
          searchQueryCubit: _searchQueryCubit,
          sourceBloc: _sourceBloc,
        );
      },
      expect: () => [
        const ItemResults([_mockItem1, _mockItem3]),
      ],
    );

    blocTest<ItemListBloc, ItemListState>(
      // ignore: lines_longer_than_80_chars
      'sets filter empty state with no source items matching both "and" conditions',
      build: () {
        whenListen<FilterConditionsState>(
          _filterConditionsBloc,
          Stream.value(
            ConditionsInitialized(
              activeAndConditions: {
                generateConditionKey('id', _mockItem1.id),
                generateConditionKey('name', 'bogus name'),
              },
              activeOrConditions: const {},
              availableConditions: const {},
            ),
          ),
        );
        whenListen<String>(_searchQueryCubit, Stream.value(''));
        whenListen<MockSourceBlocState>(
          _sourceBloc,
          Stream.value(
            const MockSourceBlocClassItems(
                [_mockItem1, _mockItem2, _mockItem3]),
          ),
        );

        return ItemListBloc<MockItemClass, MockSourceBlocClassItems>(
          filterConditionsBloc: _filterConditionsBloc,
          searchQueryCubit: _searchQueryCubit,
          sourceBloc: _sourceBloc,
        );
      },
      expect: () => [
        const ItemEmptyState(),
      ],
    );

    blocTest<ItemListBloc, ItemListState>(
      'returns source items matching both active "and" conditions',
      build: () {
        whenListen<FilterConditionsState>(
          _filterConditionsBloc,
          Stream.value(
            ConditionsInitialized(
              activeAndConditions: {
                generateConditionKey('id', _mockItem1.id),
                generateConditionKey('common', _mockItem2.common),
              },
              activeOrConditions: const {},
              availableConditions: const {},
            ),
          ),
        );
        whenListen<String>(_searchQueryCubit, Stream.value(''));
        whenListen<MockSourceBlocState>(
          _sourceBloc,
          Stream.value(
            const MockSourceBlocClassItems(
                [_mockItem1, _mockItem2, _mockItem3]),
          ),
        );

        return ItemListBloc<MockItemClass, MockSourceBlocClassItems>(
          filterConditionsBloc: _filterConditionsBloc,
          searchQueryCubit: _searchQueryCubit,
          sourceBloc: _sourceBloc,
        );
      },
      expect: () => [
        const ItemResults([_mockItem1]),
      ],
    );

    blocTest<ItemListBloc, ItemListState>(
      'returns source items matching active "and" and "or" conditions',
      build: () {
        whenListen<FilterConditionsState>(
          _filterConditionsBloc,
          Stream.value(
            ConditionsInitialized(
              activeAndConditions: {
                generateConditionKey('common', _mockItem2.common),
              },
              activeOrConditions: {
                generateConditionKey('id', _mockItem1.id),
                generateConditionKey('id', _mockItem3.id),
              },
              availableConditions: const {},
            ),
          ),
        );
        whenListen<String>(_searchQueryCubit, Stream.value(''));
        whenListen<MockSourceBlocState>(
          _sourceBloc,
          Stream.value(
            const MockSourceBlocClassItems(
                [_mockItem1, _mockItem2, _mockItem3]),
          ),
        );

        return ItemListBloc<MockItemClass, MockSourceBlocClassItems>(
          filterConditionsBloc: _filterConditionsBloc,
          searchQueryCubit: _searchQueryCubit,
          sourceBloc: _sourceBloc,
        );
      },
      expect: () => [
        const ItemResults([_mockItem1]),
      ],
    );

    blocTest<ItemListBloc, ItemListState>(
      'returns source items matching a single active boolean condition key',
      build: () {
        whenListen<FilterConditionsState>(
          _filterConditionsBloc,
          Stream.value(
            ConditionsInitialized(
              activeAndConditions: const {},
              activeOrConditions: {
                generateConditionKey('conditional', 'True'),
              },
              availableConditions: const {},
            ),
          ),
        );
        whenListen<String>(_searchQueryCubit, Stream.value(''));
        whenListen<MockSourceBlocState>(
          _sourceBloc,
          Stream.value(
            const MockSourceBlocClassItems(
                [_mockItem1, _mockItem2, _mockItem3]),
          ),
        );

        return ItemListBloc<MockItemClass, MockSourceBlocClassItems>(
          filterConditionsBloc: _filterConditionsBloc,
          searchQueryCubit: _searchQueryCubit,
          sourceBloc: _sourceBloc,
        );
      },
      expect: () => [
        const ItemResults([_mockItem1, _mockItem3]),
      ],
    );

    blocTest<ItemListBloc, ItemListState>(
      'returns source items matching multiple active condition keys',
      build: () {
        whenListen<FilterConditionsState>(
          _filterConditionsBloc,
          Stream.value(
            ConditionsInitialized(
              activeAndConditions: const {},
              activeOrConditions: {
                generateConditionKey('id', _mockItem1.id),
                generateConditionKey('conditional', 'True'),
              },
              availableConditions: const {},
            ),
          ),
        );
        whenListen<String>(_searchQueryCubit, Stream.value(''));
        whenListen<MockSourceBlocState>(
          _sourceBloc,
          Stream.value(
            const MockSourceBlocClassItems(
                [_mockItem1, _mockItem2, _mockItem3]),
          ),
        );

        return ItemListBloc<MockItemClass, MockSourceBlocClassItems>(
          filterConditionsBloc: _filterConditionsBloc,
          searchQueryCubit: _searchQueryCubit,
          sourceBloc: _sourceBloc,
        );
      },
      expect: () => [
        const ItemResults([_mockItem1, _mockItem3]),
      ],
    );

    blocTest<ItemListBloc, ItemListState>(
      'returns source items matching only a query',
      build: () {
        whenListen<FilterConditionsState>(
          _filterConditionsBloc,
          Stream.value(
            const ConditionsInitialized(
              activeAndConditions: {},
              activeOrConditions: {},
              availableConditions: {},
            ),
          ),
        );
        whenListen<String>(_searchQueryCubit, Stream.value('value2'));
        whenListen<MockSourceBlocState>(
          _sourceBloc,
          Stream.value(
            const MockSourceBlocClassItems(
                [_mockItem1, _mockItem2, _mockItem3]),
          ),
        );

        return ItemListBloc<MockItemClass, MockSourceBlocClassItems>(
          filterConditionsBloc: _filterConditionsBloc,
          searchQueryCubit: _searchQueryCubit,
          sourceBloc: _sourceBloc,
          searchProperties: ['extra'],
        );
      },
      expect: () => [
        const ItemResults([_mockItem2]),
      ],
    );

    blocTest<ItemListBloc, ItemListState>(
      'returns source items matching a query after filtering',
      build: () {
        whenListen<FilterConditionsState>(
          _filterConditionsBloc,
          Stream.value(
            ConditionsInitialized(
              activeAndConditions: const {},
              activeOrConditions: {
                generateConditionKey('id', _mockItem1.id),
                generateConditionKey('id', _mockItem2.id),
                generateConditionKey('id', _mockItem3.id),
              },
              availableConditions: const {},
            ),
          ),
        );
        whenListen<String>(_searchQueryCubit, Stream.value('value2'));
        whenListen<MockSourceBlocState>(
          _sourceBloc,
          Stream.value(
            const MockSourceBlocClassItems(
                [_mockItem1, _mockItem2, _mockItem3]),
          ),
        );

        return ItemListBloc<MockItemClass, MockSourceBlocClassItems>(
          filterConditionsBloc: _filterConditionsBloc,
          searchQueryCubit: _searchQueryCubit,
          sourceBloc: _sourceBloc,
          searchProperties: ['extra'],
        );
      },
      expect: () => [
        const ItemResults([_mockItem2]),
      ],
    );

    blocTest<ItemListBloc, ItemListState>(
      // ignore: lines_longer_than_80_chars
      'returns source items matching a query after filtering active "and" and "or" conditions',
      build: () {
        whenListen<FilterConditionsState>(
          _filterConditionsBloc,
          Stream.value(
            ConditionsInitialized(
              activeAndConditions: {
                generateConditionKey('common', _mockItem1.common),
              },
              activeOrConditions: {
                generateConditionKey('id', _mockItem1.id),
                generateConditionKey('id', _mockItem2.id),
                generateConditionKey('id', _mockItem3.id),
              },
              availableConditions: const {},
            ),
          ),
        );
        whenListen<String>(_searchQueryCubit, Stream.value('value2'));
        whenListen<MockSourceBlocState>(
          _sourceBloc,
          Stream.value(
            const MockSourceBlocClassItems(
                [_mockItem1, _mockItem2, _mockItem3]),
          ),
        );

        return ItemListBloc<MockItemClass, MockSourceBlocClassItems>(
          filterConditionsBloc: _filterConditionsBloc,
          searchQueryCubit: _searchQueryCubit,
          sourceBloc: _sourceBloc,
          searchProperties: ['extra'],
        );
      },
      expect: () => [
        const ItemResults([_mockItem2]),
      ],
    );

    blocTest<ItemListBloc, ItemListState>(
      'sets filter empty state with no source items matching query',
      build: () {
        whenListen<FilterConditionsState>(
          _filterConditionsBloc,
          Stream.value(
            ConditionsInitialized(
              activeAndConditions: const {},
              activeOrConditions: {
                generateConditionKey('id', _mockItem1.id),
                generateConditionKey('id', _mockItem2.id),
                generateConditionKey('id', _mockItem3.id),
              },
              availableConditions: const {},
            ),
          ),
        );
        whenListen<String>(_searchQueryCubit, Stream.value('123'));
        whenListen<MockSourceBlocState>(
          _sourceBloc,
          Stream.value(
            const MockSourceBlocClassItems(
                [_mockItem1, _mockItem2, _mockItem3]),
          ),
        );

        return ItemListBloc<MockItemClass, MockSourceBlocClassItems>(
          filterConditionsBloc: _filterConditionsBloc,
          searchQueryCubit: _searchQueryCubit,
          sourceBloc: _sourceBloc,
          searchProperties: ['extra'],
        );
      },
      expect: () => [
        const ItemEmptyState(),
      ],
    );
  });
}

class MockFilterConditionsBloc
    extends MockBloc<FilterConditionsEvent, FilterConditionsState>
    implements FilterConditionsBloc {}

class MockSearchQueryCubit extends MockCubit<String>
    implements SearchQueryCubit {}
