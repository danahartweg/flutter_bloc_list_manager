part of 'filter_conditions_bloc.dart';

abstract class FilterConditionsEvent extends Equatable {
  const FilterConditionsEvent();
}

class SetAvailableValuesForProperties extends FilterConditionsEvent {
  final Map<String, List<String>> valuesForProperties;

  const SetAvailableValuesForProperties(this.valuesForProperties);

  @override
  List<Object> get props => [valuesForProperties];
}

class AddCondition extends FilterConditionsEvent {
  final String property;
  final String value;

  const AddCondition(
      {@required this.property, @required this.value});

  @override
  List<Object> get props => [property, value];
}

class RemoveCondition extends FilterConditionsEvent {
  final String property;
  final String value;

  const RemoveCondition(
      {@required this.property, @required this.value});

  @override
  List<Object> get props => [property, value];
}
