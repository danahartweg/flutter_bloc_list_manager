part of 'filter_conditions_bloc.dart';

/// {@template filterconditionsstate}
/// Base [FilterConditionsState] for extension.
/// {@endtemplate}
abstract class FilterConditionsState extends Equatable {
  /// {@macro filterconditionsstate}
  const FilterConditionsState();
}

/// {@template conditionsuninitialized}
/// State when available conditions have yet to be generated.
/// This will generally happen if the source bloc has not yet
/// emitted a state containing items to process.
/// {@endtemplate}
class ConditionsUninitialized extends FilterConditionsState {
  /// {@macro conditionsuninitialized}
  const ConditionsUninitialized();

  @override
  List<Object> get props => ['Uninitialized'];
}

/// {@template conditionsinitialized}
/// {@endtemplate}
class ConditionsInitialized extends FilterConditionsState {
  /// Each property contains a [List] of values that correspond
  /// to at least one item from the source bloc.
  ///
  /// These groups are used to construct UI that can then dispatch
  /// `AddCondition` and `RemoveCondition` events to the `FilterConditionsBloc`.
  final Map<String, List<String>> availableConditions;

  /// Any `property::value` pairs that are currently being
  /// used to filter items from the source bloc using the `and` mode.
  ///
  /// There should be no need to interact directly with this state property.
  final Set<String> activeAndConditions;

  /// Any `property::value` pairs that are currently being
  /// used to filter items from the source bloc using the `or` mode.
  ///
  /// There should be no need to interact directly with this state property.
  final Set<String> activeOrConditions;

  /// {@macro conditionsinitialized}
  const ConditionsInitialized({
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
