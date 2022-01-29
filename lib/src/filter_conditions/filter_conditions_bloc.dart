import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../item_source.dart';
import '../utils.dart';

part 'filter_conditions_event.dart';
part 'filter_conditions_state.dart';

/// {@template filterconditionsbloc}
/// Attaches to the provided [_sourceBloc] in order to dynamically generate
/// groupings of available conditions that correspond to the
/// provided [_filterProperties].
///
/// Additionally exposes events to add or remove active conditions
/// from the state.
///
/// There should be no need to ever manually construct a [FilterConditionsBloc].
/// It should, instead, be retrieved from within the `ListManager`
/// in order to construct whatever filtering UI you desire.
/// {@endtemplate}
class FilterConditionsBloc<T extends ItemSourceState>
    extends Bloc<FilterConditionsEvent, FilterConditionsState> {
  final List<String> _filterProperties;
  final Bloc _sourceBloc;

  StreamSubscription _sourceSubscription;
  final Map<String, FilterMode> _conditionKeyTracker = {};

  /// {@macro filterconditionsbloc}
  FilterConditionsBloc({
    @required List<String> filterProperties,
    @required Bloc sourceBloc,
  })  : assert(filterProperties != null),
        assert(sourceBloc != null),
        _filterProperties = filterProperties,
        _sourceBloc = sourceBloc,
        super(const ConditionsUninitialized()) {
    _sourceSubscription = _sourceBloc.stream.listen((sourceState) {
      if (sourceState is! T) {
        return;
      }

      final modifiedFilterConditions = Set.from(_filterProperties);
      final booleanProperties = <String>{};

      final availableConditions = _generateFilterPropertiesMap();
      final availableConditionKeys = <String>{};

      for (final item in sourceState.items) {
        for (final property in modifiedFilterConditions) {
          final value = item[property];

          if (value is bool) {
            booleanProperties.add(property);

            availableConditions[property].add('True');
            availableConditions[property].add('False');

            availableConditionKeys.add(generateConditionKey(property, 'True'));
            availableConditionKeys.add(generateConditionKey(property, 'False'));
          }

          if (value is String && value.isNotEmpty) {
            final conditionKey = generateConditionKey(property, value);

            availableConditions[property].add(value);
            availableConditionKeys.add(conditionKey);
          }
        }

        // We don't want to repeatedly loop through boolean properties that
        // have already been parsed. Nor do we want to sort them (below).
        if (booleanProperties.isNotEmpty) {
          modifiedFilterConditions.removeWhere(booleanProperties.contains);
          booleanProperties.clear();
        }
      }

      final currentState = state;
      final activeAndConditions = currentState is ConditionsInitialized
          ? currentState.activeAndConditions
          : <String>{};
      final activeOrConditions = currentState is ConditionsInitialized
          ? currentState.activeOrConditions
          : <String>{};

      for (final property in modifiedFilterConditions) {
        // Ensure only unique entries are present and that entries are sorted.
        // Removing duplicates before sorting will save a few cycles.
        availableConditions[property] =
            availableConditions[property].toSet().toList()..sort();
      }

      _conditionKeyTracker
          .removeWhere((key, _) => !availableConditionKeys.contains(key));

      add(RefreshConditions(
        activeAndConditions:
            activeAndConditions.intersection(availableConditionKeys),
        activeOrConditions:
            activeOrConditions.intersection(availableConditionKeys),
        availableConditions: availableConditions,
      ));
    });

    on<RefreshConditions>((event, emit) => emit(ConditionsInitialized(
          activeAndConditions: event.activeAndConditions,
          activeOrConditions: event.activeOrConditions,
          availableConditions: event.availableConditions,
        )));

    on<AddCondition>(
        (event, emit) => emit(_addConditionToActiveConditions(event)));
    on<RemoveCondition>(
        (event, emit) => emit(_removeConditionFromActiveConditions(event)));
  }

  @override
  Future<void> close() async {
    await _sourceSubscription?.cancel();
    return super.close();
  }

  /// Helper that checks whether a [value] for a given [property] exists in
  /// the current state as an active condition.
  bool isConditionActive(String property, String value) {
    final conditionKey = generateConditionKey(property, value);
    return _conditionKeyTracker.containsKey(conditionKey);
  }

  FilterConditionsState _addConditionToActiveConditions(
    AddCondition event,
  ) {
    if (state is ConditionsUninitialized) {
      return state;
    }

    final currentState = (state as ConditionsInitialized);
    final conditionKey = generateConditionKey(event.property, event.value);
    final conditionMode = _conditionKeyTracker[conditionKey];
    final doModesMatch = event.mode == conditionMode;

    if (doModesMatch) {
      return currentState;
    }

    final activeAndConditions =
        Set<String>.from(currentState.activeAndConditions);
    final activeOrConditions =
        Set<String>.from(currentState.activeOrConditions);

    switch (event.mode) {
      case FilterMode.and:
        activeAndConditions.add(conditionKey);
        activeOrConditions.remove(conditionKey);
        break;

      case FilterMode.or:
        activeAndConditions.remove(conditionKey);
        activeOrConditions.add(conditionKey);
        break;
    }

    _conditionKeyTracker[conditionKey] = event.mode;
    return ConditionsInitialized(
      activeAndConditions: activeAndConditions,
      activeOrConditions: activeOrConditions,
      availableConditions: currentState.availableConditions,
    );
  }

  Map<String, List<String>> _generateFilterPropertiesMap() {
    return { for (var item in _filterProperties) item : [] };
  }

  FilterConditionsState _removeConditionFromActiveConditions(
    RemoveCondition event,
  ) {
    if (state is ConditionsUninitialized) {
      return state;
    }

    final currentState = (state as ConditionsInitialized);
    final conditionKey = generateConditionKey(event.property, event.value);
    final conditionMode = _conditionKeyTracker[conditionKey];

    if (conditionMode == null) {
      return currentState;
    }

    var activeAndConditions = currentState.activeAndConditions;
    var activeOrConditions = currentState.activeOrConditions;

    switch (conditionMode) {
      case FilterMode.and:
        activeAndConditions = Set<String>.from(activeAndConditions);
        activeAndConditions.remove(conditionKey);
        break;

      case FilterMode.or:
        activeOrConditions = Set<String>.from(activeOrConditions);
        activeOrConditions.remove(conditionKey);
        break;
    }

    _conditionKeyTracker.remove(conditionKey);
    return ConditionsInitialized(
      activeAndConditions: activeAndConditions,
      activeOrConditions: activeOrConditions,
      availableConditions: currentState.availableConditions,
    );
  }
}

/// Available filter modes that can be attached to a condition key.
enum FilterMode {
  /// Designates a condition to be filtered subtractively.
  and,

  /// Designates a condition to be filtered additively (the default).
  or,
}
