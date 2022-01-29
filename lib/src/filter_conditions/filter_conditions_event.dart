part of 'filter_conditions_bloc.dart';

/// {@template addcondition}
/// Dispatched to add the requested [property] [value] pair to the list
/// of conditions that are currently active.
/// {@endtemplate}
class AddCondition extends FilterConditionsEvent {
  /// The [property] identifier containing the [value],
  /// matching a filter property supplied to the `FilterConditionsBloc`.
  final String property;

  /// The value to be added.
  final String value;

  /// The filter mode to use for this condition.
  final FilterMode mode;

  /// {@macro addcondition}
  const AddCondition({
    @required this.property,
    @required this.value,
    this.mode = FilterMode.or,
  });

  @override
  List<Object> get props => [property, value, mode];
}

/// {@template filterconditionsevent}
/// Base [FilterConditionsEvent] for extension.
/// {@endtemplate}
abstract class FilterConditionsEvent extends Equatable {
  /// {@macro filterconditionsevent}
  const FilterConditionsEvent();
}

/// {@template refreshconditions}
/// Dispatched whenever the source bloc receives new state.
/// [availableConditions] entries are regenerated and [activeAndConditions]
/// and [activeOrConditions] that still have a corresponding entry
/// in the regenerated [availableConditions] are maintained.
/// {@endtemplate}
class RefreshConditions extends FilterConditionsEvent {
  /// Each property contains a [List] of values that correspond
  /// to at least one item from the source bloc.
  final Map<String, List<String>> availableConditions;

  /// Any property/value pairs (in the format `$property::$value`)
  /// that are currently being used to filter items from the source bloc
  /// using the `and` mode.
  final Set<String> activeAndConditions;

  /// Any property/value pairs (in the format `$property::$value`)
  /// that are currently being used to filter items from the source bloc
  /// using the `or` mode.
  final Set<String> activeOrConditions;

  /// {@macro refreshconditions}
  const RefreshConditions({
    @required this.availableConditions,
    @required this.activeAndConditions,
    @required this.activeOrConditions,
  });

  @override
  List<Object> get props => [
        availableConditions,
        activeAndConditions,
        activeOrConditions,
      ];
}

/// {@template removecondition}
/// Dispatched to remove the requested [property] [value] pair from the list
/// of conditions that are currently active.
/// {@endtemplate}
class RemoveCondition extends FilterConditionsEvent {
  /// The [property] identifier containing the [value],
  /// matching a filter property supplied to the bloc.
  final String property;

  /// The value to be removed.
  final String value;

  /// {@macro removecondition}
  const RemoveCondition({
    @required this.property,
    @required this.value,
  });

  @override
  List<Object> get props => [property, value];
}
