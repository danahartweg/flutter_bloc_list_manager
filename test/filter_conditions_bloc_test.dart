import 'dart:async';
import 'package:mockito/mockito.dart';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_bloc_list_manager/flutter_bloc_list_manager.dart';
import 'package:flutter_bloc_list_manager/src/utils.dart';

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
    conditional: false,
  );
  const _mockItem3 = MockItemClass(
    id: 'idValue3',
    name: 'nameValue3',
    extra: 'extraValue3',
    conditional: true,
  );

  group('FilterConditionsBloc', () {
    MockSourceBloc _sourceBloc;
    StreamController<MockSourceBlocState> _sourceStreamController;

    setUp(() {
      _sourceBloc = MockSourceBloc();
      _sourceStreamController = StreamController();

      when(_sourceBloc.listen(any)).thenAnswer((invocation) {
        return _sourceStreamController.stream.listen(invocation
            .positionalArguments.first as Function(MockSourceBlocState));
      });
    });

    tearDown(() {
      _sourceStreamController.close();
    });

    test('sets an initial state', () {
      final bloc = FilterConditionsBloc(
        sourceBloc: _sourceBloc,
        filterProperties: [],
      );

      expect(bloc.state, ConditionsUninitialized());
    });

    group('available conditions', () {
      blocTest<FilterConditionsBloc, FilterConditionsState>(
        'does not act on a source bloc state with no items',
        build: () {
          whenListen<MockSourceBlocState>(
              _sourceBloc, Stream.value(MockSourceBlocNoItems()));

          return FilterConditionsBloc<MockSourceBlocClassItems>(
            sourceBloc: _sourceBloc,
            filterProperties: [],
          );
        },
        expect: [],
      );

      blocTest<FilterConditionsBloc, FilterConditionsState>(
        'handles an empty filter properties array',
        build: () {
          whenListen<MockSourceBlocState>(
            _sourceBloc,
            Stream.value(MockSourceBlocClassItems([_mockItem1])),
          );

          return FilterConditionsBloc<MockSourceBlocClassItems>(
            sourceBloc: _sourceBloc,
            filterProperties: [],
          );
        },
        expect: [
          ConditionsInitialized(
            activeConditions: <String>{},
            availableConditions: {},
          )
        ],
      );

      blocTest<FilterConditionsBloc, FilterConditionsState>(
        'extracts each requested filter property from a class',
        build: () {
          whenListen<MockSourceBlocState>(
            _sourceBloc,
            Stream.value(MockSourceBlocClassItems([_mockItem1])),
          );

          return FilterConditionsBloc<MockSourceBlocClassItems>(
            sourceBloc: _sourceBloc,
            filterProperties: ['id', 'extra'],
          );
        },
        expect: [
          ConditionsInitialized(
            activeConditions: <String>{},
            availableConditions: {
              'id': [_mockItem1.id],
              'extra': [_mockItem1.extra],
            },
          )
        ],
      );

      blocTest<FilterConditionsBloc, FilterConditionsState>(
        'ignores null, empty, and non-string values',
        build: () {
          whenListen<MockSourceBlocState>(
            _sourceBloc,
            Stream.value(MockSourceBlocClassItems([
              MockItemClass(
                id: 'idValue',
                name: '',
                extra: null,
              ),
            ])),
          );

          return FilterConditionsBloc<MockSourceBlocClassItems>(
            sourceBloc: _sourceBloc,
            filterProperties: ['name', 'extra'],
          );
        },
        expect: [
          ConditionsInitialized(
            activeConditions: <String>{},
            availableConditions: {
              'name': [],
              'extra': [],
            },
          )
        ],
      );

      blocTest<FilterConditionsBloc, FilterConditionsState>(
        'extracts from multiple source items',
        build: () {
          whenListen<MockSourceBlocState>(
            _sourceBloc,
            Stream.value(
                MockSourceBlocClassItems([_mockItem1, _mockItem2, _mockItem3])),
          );

          return FilterConditionsBloc<MockSourceBlocClassItems>(
            sourceBloc: _sourceBloc,
            filterProperties: ['id', 'extra'],
          );
        },
        expect: [
          ConditionsInitialized(
            activeConditions: <String>{},
            availableConditions: {
              'id': [_mockItem1.id, _mockItem2.id, _mockItem3.id],
              'extra': [_mockItem1.extra, _mockItem2.extra, _mockItem3.extra],
            },
          )
        ],
      );

      blocTest<FilterConditionsBloc, FilterConditionsState>(
        'updates when the source bloc updates',
        build: () {
          whenListen<MockSourceBlocState>(
            _sourceBloc,
            Stream.fromIterable([
              MockSourceBlocClassItems([_mockItem1]),
              MockSourceBlocClassItems([_mockItem2, _mockItem3])
            ]),
          );

          return FilterConditionsBloc<MockSourceBlocClassItems>(
            sourceBloc: _sourceBloc,
            filterProperties: ['id', 'extra'],
          );
        },
        expect: [
          ConditionsInitialized(
            activeConditions: <String>{},
            availableConditions: {
              'id': [_mockItem1.id],
              'extra': [_mockItem1.extra],
            },
          ),
          ConditionsInitialized(
            activeConditions: <String>{},
            availableConditions: {
              'id': [_mockItem2.id, _mockItem3.id],
              'extra': [_mockItem2.extra, _mockItem3.extra],
            },
          )
        ],
      );

      blocTest<FilterConditionsBloc, FilterConditionsState>(
        'retains valid active conditions when the source list updates',
        build: () => FilterConditionsBloc<MockSourceBlocClassItems>(
          sourceBloc: _sourceBloc,
          filterProperties: ['id', 'extra'],
        ),
        act: (bloc) async {
          _sourceStreamController.add(MockSourceBlocClassItems([_mockItem1]));
          await Future.delayed(Duration());

          bloc.add(AddCondition(property: 'id', value: _mockItem1.id));
          await Future.delayed(Duration());

          _sourceStreamController
              .add(MockSourceBlocClassItems([_mockItem1, _mockItem2]));
          await Future.delayed(Duration());

          _sourceStreamController.add(MockSourceBlocClassItems([_mockItem2]));
          await Future.delayed(Duration());
        },
        expect: [
          ConditionsInitialized(
            activeConditions: <String>{},
            availableConditions: {
              'id': [_mockItem1.id],
              'extra': [_mockItem1.extra],
            },
          ),
          ConditionsInitialized(
            activeConditions: <String>{
              generateConditionKey('id', _mockItem1.id),
            },
            availableConditions: {
              'id': [_mockItem1.id],
              'extra': [_mockItem1.extra],
            },
          ),
          ConditionsInitialized(
            activeConditions: <String>{
              generateConditionKey('id', _mockItem1.id),
            },
            availableConditions: {
              'id': [_mockItem1.id, _mockItem2.id],
              'extra': [_mockItem1.extra, _mockItem2.extra],
            },
          ),
          ConditionsInitialized(
            activeConditions: <String>{},
            availableConditions: {
              'id': [_mockItem2.id],
              'extra': [_mockItem2.extra],
            },
          )
        ],
      );

      blocTest<FilterConditionsBloc, FilterConditionsState>(
        'removes duplicate values',
        build: () {
          whenListen<MockSourceBlocState>(
            _sourceBloc,
            Stream.value(
                MockSourceBlocClassItems([_mockItem1, _mockItem1, _mockItem2])),
          );

          return FilterConditionsBloc<MockSourceBlocClassItems>(
            sourceBloc: _sourceBloc,
            filterProperties: ['id', 'extra'],
          );
        },
        expect: [
          ConditionsInitialized(
            activeConditions: <String>{},
            availableConditions: {
              'id': [_mockItem1.id, _mockItem2.id],
              'extra': [_mockItem1.extra, _mockItem2.extra],
            },
          )
        ],
      );

      blocTest<FilterConditionsBloc, FilterConditionsState>(
        'sorts values alphabetically',
        build: () {
          whenListen<MockSourceBlocState>(
            _sourceBloc,
            Stream.value(
                MockSourceBlocClassItems([_mockItem3, _mockItem2, _mockItem1])),
          );

          return FilterConditionsBloc<MockSourceBlocClassItems>(
            sourceBloc: _sourceBloc,
            filterProperties: ['id', 'extra'],
          );
        },
        expect: [
          ConditionsInitialized(
            activeConditions: <String>{},
            availableConditions: {
              'id': [_mockItem1.id, _mockItem2.id, _mockItem3.id],
              'extra': [_mockItem1.extra, _mockItem2.extra, _mockItem3.extra],
            },
          )
        ],
      );

      blocTest<FilterConditionsBloc, FilterConditionsState>(
        'formats boolean property values for display without repeating',
        build: () {
          whenListen<MockSourceBlocState>(
            _sourceBloc,
            Stream.value(
                MockSourceBlocClassItems([_mockItem1, _mockItem2, _mockItem3])),
          );

          return FilterConditionsBloc<MockSourceBlocClassItems>(
            sourceBloc: _sourceBloc,
            filterProperties: ['conditional'],
          );
        },
        expect: [
          ConditionsInitialized(
            activeConditions: <String>{},
            availableConditions: {
              'conditional': [
                'True',
                'False',
              ],
            },
          )
        ],
      );

      blocTest<FilterConditionsBloc, FilterConditionsState>(
        'filtering one item on a boolean property should still add both items',
        build: () {
          whenListen<MockSourceBlocState>(
            _sourceBloc,
            Stream.value(MockSourceBlocClassItems([_mockItem1])),
          );

          return FilterConditionsBloc<MockSourceBlocClassItems>(
            sourceBloc: _sourceBloc,
            filterProperties: ['conditional'],
          );
        },
        expect: [
          ConditionsInitialized(
            activeConditions: <String>{},
            availableConditions: {
              'conditional': [
                'True',
                'False',
              ],
            },
          )
        ],
      );
    });

    group('active conditions', () {
      blocTest<FilterConditionsBloc, FilterConditionsState>(
        'does not add an active condition when uninitialized',
        build: () => FilterConditionsBloc<MockSourceBlocClassItems>(
          sourceBloc: _sourceBloc,
          filterProperties: [],
        ),
        act: (bloc) => bloc.add(AddCondition(property: 'id', value: '123')),
        expect: [ConditionsUninitialized()],
      );

      blocTest<FilterConditionsBloc, FilterConditionsState>(
        'adds and removes active conditions',
        build: () => FilterConditionsBloc<MockSourceBlocClassItems>(
          sourceBloc: _sourceBloc,
          filterProperties: [],
        )..emit(ConditionsInitialized(
            availableConditions: {},
            activeConditions: {},
          )),
        act: (bloc) => bloc
          ..add(AddCondition(property: 'id', value: '123'))
          ..add(AddCondition(property: 'extra', value: 'something'))
          ..add(AddCondition(property: 'conditional', value: 'True'))
          ..add(AddCondition(property: 'id', value: '456'))
          ..add(AddCondition(property: 'conditional', value: 'False'))
          ..add(RemoveCondition(property: 'id', value: '123'))
          ..add(RemoveCondition(property: 'conditional', value: 'False'))
          ..add(RemoveCondition(property: 'id', value: '456'))
          ..add(RemoveCondition(property: 'conditional', value: 'True'))
          ..add(RemoveCondition(property: 'extra', value: 'something')),
        expect: [
          ConditionsInitialized(
            activeConditions: <String>{
              generateConditionKey('id', '123'),
            },
            availableConditions: {},
          ),
          ConditionsInitialized(
            activeConditions: <String>{
              generateConditionKey('id', '123'),
              generateConditionKey('extra', 'something'),
            },
            availableConditions: {},
          ),
          ConditionsInitialized(
            activeConditions: <String>{
              generateConditionKey('id', '123'),
              generateConditionKey('extra', 'something'),
              generateConditionKey('conditional', 'True'),
            },
            availableConditions: {},
          ),
          ConditionsInitialized(
            activeConditions: <String>{
              generateConditionKey('id', '123'),
              generateConditionKey('id', '456'),
              generateConditionKey('extra', 'something'),
              generateConditionKey('conditional', 'True'),
            },
            availableConditions: {},
          ),
          ConditionsInitialized(
            activeConditions: <String>{
              generateConditionKey('id', '123'),
              generateConditionKey('id', '456'),
              generateConditionKey('extra', 'something'),
              generateConditionKey('conditional', 'True'),
              generateConditionKey('conditional', 'False'),
            },
            availableConditions: {},
          ),
          // Conditions start to be removed.
          ConditionsInitialized(
            activeConditions: <String>{
              generateConditionKey('id', '456'),
              generateConditionKey('extra', 'something'),
              generateConditionKey('conditional', 'True'),
              generateConditionKey('conditional', 'False'),
            },
            availableConditions: {},
          ),
          ConditionsInitialized(
            activeConditions: <String>{
              generateConditionKey('id', '456'),
              generateConditionKey('extra', 'something'),
              generateConditionKey('conditional', 'True'),
            },
            availableConditions: {},
          ),
          ConditionsInitialized(
            activeConditions: <String>{
              generateConditionKey('extra', 'something'),
              generateConditionKey('conditional', 'True'),
            },
            availableConditions: {},
          ),
          ConditionsInitialized(
            activeConditions: <String>{
              generateConditionKey('extra', 'something'),
            },
            availableConditions: {},
          ),
          ConditionsInitialized(
            activeConditions: <String>{},
            availableConditions: {},
          ),
        ],
      );
    });

    test('closes the source bloc subscription', () {
      final stream = Stream.value(MockSourceBlocNoItems()).asBroadcastStream();
      final onDoneCallback = expectAsync0(() {});

      whenListen<MockSourceBlocState>(_sourceBloc, stream);
      stream.listen((_) {}, onDone: onDoneCallback);

      final filterConditionsBloc = FilterConditionsBloc(
        sourceBloc: _sourceBloc,
        filterProperties: [],
      );

      filterConditionsBloc.close();
    });
  });
}
