part of 'filter_conditions_bloc.dart';

abstract class FilterConditionsState extends Equatable {
  const FilterConditionsState();
}

class ConditionsUninitialized extends FilterConditionsState {
  const ConditionsUninitialized();

  @override
  List<Object> get props => ['Uninitialized'];
}

class ConditionsInitialized extends FilterConditionsState {
  final Map<String, List<String>> availableConditions;
  final Set<String> activeConditions;

  const ConditionsInitialized(
      {@required this.availableConditions, @required this.activeConditions});

  @override
  List<Object> get props => [availableConditions, activeConditions];
}
