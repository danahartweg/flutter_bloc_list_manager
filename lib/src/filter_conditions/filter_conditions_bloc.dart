import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../item_source.dart';

part 'filter_conditions_event.dart';
part 'filter_conditions_state.dart';

class FilterConditionsBloc<T extends ItemSource, S>
    extends Bloc<FilterConditionsEvent, FilterConditionsState> {
  final List<String> _filterProperties;
  final Bloc<dynamic, S> _sourceBloc;

  StreamSubscription _sourceSubscription;

  FilterConditionsBloc({
    @required List<String> filterProperties,
    @required Bloc<dynamic, S> sourceBloc,
  })  : assert(filterProperties != null),
        assert(sourceBloc != null),
        _filterProperties = filterProperties,
        _sourceBloc = sourceBloc {
    _sourceSubscription = _sourceBloc.listen((state) {
      if (state is! T) {
        return;
      }

      final valuesForProperties = _generateFilterPropertiesMap();

      (state as T).items.forEach((item) {
        _filterProperties.forEach((property) {
          final value = item[property];

          if (value is String && value.isNotEmpty) {
            valuesForProperties[property].add(value);
          }
        });
      });

      // ensure only unique entries are present and that the entries are sorted...
      // removing duplicates before sorting will save a few cycles
      _filterProperties.forEach((property) {
        valuesForProperties[property] =
            valuesForProperties[property].toSet().toList()..sort();
      });

      add(SetAvailableValuesForProperties(valuesForProperties));
    });
  }

  @override
  FilterConditionsState get initialState => ConditionsUninitialized();

  @override
  Stream<FilterConditionsState> mapEventToState(
    FilterConditionsEvent event,
  ) async* {
    if (event is SetAvailableValuesForProperties) {
      yield _mapSetAvailableValuesForPropertiesToState(event);
    } else if (event is AddCondition) {
      yield _addConditionToActiveConditions(event);
    } else if (event is RemoveCondition) {
      yield _removeConditionFromActiveConditions(event);
    }
  }

  FilterConditionsState _mapSetAvailableValuesForPropertiesToState(
    SetAvailableValuesForProperties event,
  ) {
    return ConditionsInitialized(
      availableConditions: event.valuesForProperties,
      activeConditions: {},
    );
  }

  FilterConditionsState _addConditionToActiveConditions(
    AddCondition event,
  ) {
    if (state is ConditionsUninitialized) {
      return this.state;
    }

    final currentState = (this.state as ConditionsInitialized);

    if ((currentState.activeConditions[event.property] ?? [])
        .contains(event.value)) {
      return currentState;
    }

    final activeConditions =
        Map.fromEntries(currentState.activeConditions.entries);

    activeConditions.update(
      event.property,
      (activeValues) => List.from([...activeValues, event.value]),
      ifAbsent: () => [event.value],
    );

    return ConditionsInitialized(
      availableConditions: currentState.availableConditions,
      activeConditions: activeConditions,
    );
  }

  FilterConditionsState _removeConditionFromActiveConditions(
    RemoveCondition event,
  ) {
    if (state is ConditionsUninitialized) {
      return this.state;
    }

    final currentState = (this.state as ConditionsInitialized);
    final targetCondition = currentState.activeConditions[event.property];

    if (targetCondition == null || !targetCondition.contains(event.value)) {
      return currentState;
    }

    final activeConditions =
        Map.fromEntries(currentState.activeConditions.entries);

    activeConditions.update(
      event.property,
      (activeValues) => List.from(activeValues)..remove(event.value),
    );

    if (activeConditions[event.property].isEmpty) {
      activeConditions.remove(event.property);
    }

    return ConditionsInitialized(
      availableConditions: currentState.availableConditions,
      activeConditions: activeConditions,
    );
  }

  Map<String, List<String>> _generateFilterPropertiesMap() {
    return Map.fromIterable(
      _filterProperties,
      key: (item) => item,
      value: (_) => [],
    );
  }

  @override
  Future<void> close() async {
    await _sourceSubscription?.cancel();
    return super.close();
  }
}
