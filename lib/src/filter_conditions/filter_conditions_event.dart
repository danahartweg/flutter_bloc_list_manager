part of 'filter_conditions_bloc.dart';

abstract class FilterConditionsEvent extends Equatable {
  const FilterConditionsEvent();
}

class RefreshConditions extends FilterConditionsEvent {
  final Map<String, List<String>> availableConditions;
  final Set<String> activeConditions;

  const RefreshConditions(
      {@required this.availableConditions, @required this.activeConditions});

  @override
  List<Object> get props => [availableConditions, activeConditions];
}

class AddCondition extends FilterConditionsEvent {
  final String property;
  final String value;

  const AddCondition({@required this.property, @required this.value});

  @override
  List<Object> get props => [property, value];
}

class RemoveCondition extends FilterConditionsEvent {
  final String property;
  final String value;

  const RemoveCondition({@required this.property, @required this.value});

  @override
  List<Object> get props => [property, value];
}
