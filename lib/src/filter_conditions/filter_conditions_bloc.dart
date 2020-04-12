import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../item_source.dart';
import '../utils.dart';

part 'filter_conditions_event.dart';
part 'filter_conditions_state.dart';

class FilterConditionsBloc<T extends ItemSource>
    extends Bloc<FilterConditionsEvent, FilterConditionsState> {
  final List<String> _filterProperties;
  final Bloc _sourceBloc;

  StreamSubscription _sourceSubscription;

  FilterConditionsBloc({
    @required List<String> filterProperties,
    @required Bloc sourceBloc,
  })  : assert(filterProperties != null),
        assert(sourceBloc != null),
        _filterProperties = filterProperties,
        _sourceBloc = sourceBloc {
    _sourceSubscription = _sourceBloc.listen((sourceState) {
      if (sourceState is! T) {
        return;
      }

      final availableConditions = _generateFilterPropertiesMap();
      final availableConditionKeys = <String>{};

      for (final item in sourceState.items) {
        for (final property in _filterProperties) {
          final value = item[property];

          if (value is String && value.isNotEmpty) {
            final conditionKey = generateConditionKey(property, value);

            availableConditions[property].add(value);
            availableConditionKeys.add(conditionKey);
          }
        }
      }

      final currentState = state;
      final activeConditions = currentState is ConditionsInitialized
          ? currentState.activeConditions
          : <String>{};

      for (final property in _filterProperties) {
        // ensure only unique entries are present and that entries are sorted...
        // removing duplicates before sorting will save a few cycles
        availableConditions[property] =
            availableConditions[property].toSet().toList()..sort();
      }

      add(RefreshConditions(
        activeConditions: activeConditions.intersection(availableConditionKeys),
        availableConditions: availableConditions,
      ));
    });
  }

  @override
  FilterConditionsState get initialState => ConditionsUninitialized();

  @override
  Stream<FilterConditionsState> mapEventToState(
    FilterConditionsEvent event,
  ) async* {
    if (event is RefreshConditions) {
      yield ConditionsInitialized(
        activeConditions: event.activeConditions,
        availableConditions: event.availableConditions,
      );
    } else if (event is AddCondition) {
      yield _addConditionToActiveConditions(event);
    } else if (event is RemoveCondition) {
      yield _removeConditionFromActiveConditions(event);
    }
  }

  FilterConditionsState _addConditionToActiveConditions(
    AddCondition event,
  ) {
    if (state is ConditionsUninitialized) {
      return state;
    }

    final currentState = (state as ConditionsInitialized);
    final conditionKey = generateConditionKey(event.property, event.value);

    if (currentState.activeConditions.contains(conditionKey)) {
      return currentState;
    }

    final activeConditions = Set<String>.from(currentState.activeConditions);
    activeConditions.add(conditionKey);

    return ConditionsInitialized(
      activeConditions: activeConditions,
      availableConditions: currentState.availableConditions,
    );
  }

  FilterConditionsState _removeConditionFromActiveConditions(
    RemoveCondition event,
  ) {
    if (state is ConditionsUninitialized) {
      return state;
    }

    final currentState = (state as ConditionsInitialized);
    final conditionKey = generateConditionKey(event.property, event.value);

    if (!currentState.activeConditions.contains(conditionKey)) {
      return currentState;
    }

    final activeConditions = Set<String>.from(currentState.activeConditions);
    activeConditions.remove(conditionKey);

    return ConditionsInitialized(
      activeConditions: activeConditions,
      availableConditions: currentState.availableConditions,
    );
  }

  Map<String, List<String>> _generateFilterPropertiesMap() {
    return Map.fromIterable(
      _filterProperties,
      key: (item) => item,
      value: (_) => [],
    );
  }

  bool isConditionActive(String property, String value) {
    final currentState = state;
    final conditionKey = generateConditionKey(property, value);

    return currentState is ConditionsInitialized
        ? currentState.activeConditions.contains(conditionKey)
        : false;
  }

  @override
  Future<void> close() async {
    await _sourceSubscription?.cancel();
    return super.close();
  }
}
