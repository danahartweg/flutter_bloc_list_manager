import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bloc_filter_search_list/bloc_filter_search_list.dart';

import './mocks.dart';

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

  group('FilterConditionsBloc', () {
    MockSourceBloc _sourceBloc;

    setUp(() {
      _sourceBloc = MockSourceBloc();
    });

    blocTest(
      'sets an initial state',
      build: () async {
        return FilterConditionsBloc(
          sourceBloc: _sourceBloc,
          filterProperties: [],
        );
      },
      skip: 0,
      expect: [ConditionsUninitialized()],
    );

    group('available conditions', () {
      blocTest(
        'does not act on a source bloc state with no items',
        build: () async {
          whenListen(_sourceBloc, Stream.value(MockSourceBlocNoItems()));

          return FilterConditionsBloc<MockSourceBlocClassItems,
              MockSourceBlocState>(
            sourceBloc: _sourceBloc,
            filterProperties: [],
          );
        },
        expect: [],
      );

      blocTest(
        'handles an empty filter properties array',
        build: () async {
          whenListen(
            _sourceBloc,
            Stream.value(MockSourceBlocClassItems([_mockItem1])),
          );

          return FilterConditionsBloc<MockSourceBlocClassItems,
              MockSourceBlocState>(
            sourceBloc: _sourceBloc,
            filterProperties: [],
          );
        },
        expect: [
          ConditionsInitialized(
            activeConditions: {},
            availableConditions: {},
          )
        ],
      );

      blocTest(
        'extracts each requested filter property from a class',
        build: () async {
          whenListen(
            _sourceBloc,
            Stream.value(MockSourceBlocClassItems([_mockItem1])),
          );

          return FilterConditionsBloc<MockSourceBlocClassItems,
              MockSourceBlocState>(
            sourceBloc: _sourceBloc,
            filterProperties: ['id', 'extra'],
          );
        },
        expect: [
          ConditionsInitialized(
            activeConditions: {},
            availableConditions: {
              'id': [_mockItem1.id],
              'extra': [_mockItem1.extra],
            },
          )
        ],
      );

      blocTest(
        'extracts each requested filter property from a map',
        build: () async {
          whenListen(
            _sourceBloc,
            Stream.value(MockSourceBlocMapItems([
              {
                'id': 'idValue',
                'name': 'nameValue',
                'extra': 'extraValue',
                'conditional': true,
              },
            ])),
          );

          return FilterConditionsBloc<MockSourceBlocMapItems,
              MockSourceBlocState>(
            sourceBloc: _sourceBloc,
            filterProperties: ['id', 'extra'],
          );
        },
        expect: [
          ConditionsInitialized(
            activeConditions: {},
            availableConditions: {
              'id': ['idValue'],
              'extra': ['extraValue'],
            },
          )
        ],
      );

      blocTest(
        'ignores null, empty, and non-string values',
        build: () async {
          whenListen(
            _sourceBloc,
            Stream.value(MockSourceBlocClassItems([
              MockItemClass(
                id: 'idValue',
                name: '',
                extra: null,
                conditional: true,
              ),
            ])),
          );

          return FilterConditionsBloc<MockSourceBlocClassItems,
              MockSourceBlocState>(
            sourceBloc: _sourceBloc,
            filterProperties: ['name', 'extra', 'conditional'],
          );
        },
        expect: [
          ConditionsInitialized(
            activeConditions: {},
            availableConditions: {
              'name': [],
              'extra': [],
              'conditional': [],
            },
          )
        ],
      );

      blocTest(
        'extracts from multiple source items',
        build: () async {
          whenListen(
            _sourceBloc,
            Stream.value(
                MockSourceBlocClassItems([_mockItem1, _mockItem2, _mockItem3])),
          );

          return FilterConditionsBloc<MockSourceBlocClassItems,
              MockSourceBlocState>(
            sourceBloc: _sourceBloc,
            filterProperties: ['id', 'extra'],
          );
        },
        expect: [
          ConditionsInitialized(
            activeConditions: {},
            availableConditions: {
              'id': [_mockItem1.id, _mockItem2.id, _mockItem3.id],
              'extra': [_mockItem1.extra, _mockItem2.extra, _mockItem3.extra],
            },
          )
        ],
      );

      blocTest(
        'updates when the source bloc updates',
        build: () async {
          whenListen(
            _sourceBloc,
            Stream.fromIterable([
              MockSourceBlocClassItems([_mockItem1]),
              MockSourceBlocClassItems([_mockItem2, _mockItem3])
            ]),
          );

          return FilterConditionsBloc<MockSourceBlocClassItems,
              MockSourceBlocState>(
            sourceBloc: _sourceBloc,
            filterProperties: ['id', 'extra'],
          );
        },
        expect: [
          ConditionsInitialized(
            activeConditions: {},
            availableConditions: {
              'id': [_mockItem1.id],
              'extra': [_mockItem1.extra],
            },
          ),
          ConditionsInitialized(
            activeConditions: {},
            availableConditions: {
              'id': [_mockItem2.id, _mockItem3.id],
              'extra': [_mockItem2.extra, _mockItem3.extra],
            },
          )
        ],
      );

      blocTest(
        'removes duplicate values',
        build: () async {
          whenListen(
            _sourceBloc,
            Stream.value(
                MockSourceBlocClassItems([_mockItem1, _mockItem1, _mockItem2])),
          );

          return FilterConditionsBloc<MockSourceBlocClassItems,
              MockSourceBlocState>(
            sourceBloc: _sourceBloc,
            filterProperties: ['id', 'extra'],
          );
        },
        expect: [
          ConditionsInitialized(
            activeConditions: {},
            availableConditions: {
              'id': [_mockItem1.id, _mockItem2.id],
              'extra': [_mockItem1.extra, _mockItem2.extra],
            },
          )
        ],
      );

      blocTest(
        'sorts values alphabetically',
        build: () async {
          whenListen(
            _sourceBloc,
            Stream.value(
                MockSourceBlocClassItems([_mockItem3, _mockItem2, _mockItem1])),
          );

          return FilterConditionsBloc<MockSourceBlocClassItems,
              MockSourceBlocState>(
            sourceBloc: _sourceBloc,
            filterProperties: ['id', 'extra'],
          );
        },
        expect: [
          ConditionsInitialized(
            activeConditions: {},
            availableConditions: {
              'id': [_mockItem1.id, _mockItem2.id, _mockItem3.id],
              'extra': [_mockItem1.extra, _mockItem2.extra, _mockItem3.extra],
            },
          )
        ],
      );
    });

    group('active conditions', () {
      blocTest(
        'does not add an active condition when uninitialized',
        build: () async {
          return FilterConditionsBloc<MockSourceBlocClassItems,
              MockSourceBlocState>(
            sourceBloc: _sourceBloc,
            filterProperties: [],
          );
        },
        act: (bloc) => bloc.add(AddCondition(property: 'id', value: '123')),
        skip: 0,
        expect: [ConditionsUninitialized()],
      );

      blocTest(
        'adds and removes active conditions',
        build: () async {
          whenListen(_sourceBloc, Stream.value(MockSourceBlocClassItems([])));

          return FilterConditionsBloc<MockSourceBlocClassItems,
              MockSourceBlocState>(
            sourceBloc: _sourceBloc,
            filterProperties: [],
          );
        },
        act: (bloc) {
          bloc
            ..add(AddCondition(property: 'id', value: '123'))
            ..add(AddCondition(property: 'extra', value: 'something'))
            ..add(AddCondition(property: 'id', value: '456'))
            ..add(RemoveCondition(property: 'id', value: '123'))
            ..add(RemoveCondition(property: 'id', value: '456'))
            ..add(RemoveCondition(property: 'extra', value: 'something'));

          return;
        },
        skip: 2,
        expect: [
          ConditionsInitialized(
            activeConditions: {
              'id': ['123'],
            },
            availableConditions: {},
          ),
          ConditionsInitialized(
            activeConditions: {
              'id': ['123'],
              'extra': ['something'],
            },
            availableConditions: {},
          ),
          ConditionsInitialized(
            activeConditions: {
              'id': ['123', '456'],
              'extra': ['something'],
            },
            availableConditions: {},
          ),
          ConditionsInitialized(
            activeConditions: {
              'id': ['456'],
              'extra': ['something'],
            },
            availableConditions: {},
          ),
          ConditionsInitialized(
            activeConditions: {
              'extra': ['something'],
            },
            availableConditions: {},
          ),
          ConditionsInitialized(
            activeConditions: {},
            availableConditions: {},
          ),
        ],
      );
    });

    test('closes the source bloc subscription', () {
      final stream = Stream.value(MockSourceBlocNoItems()).asBroadcastStream();
      final onDoneCallback = expectAsync0(() {});

      whenListen(_sourceBloc, stream);
      stream.listen((_) {}, onDone: onDoneCallback);

      final filterConditionsBloc = FilterConditionsBloc(
        sourceBloc: _sourceBloc,
        filterProperties: [],
      );

      filterConditionsBloc.close();
    });
  });
}
