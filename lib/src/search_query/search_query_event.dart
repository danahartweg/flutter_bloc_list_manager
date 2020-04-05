part of 'search_query_bloc.dart';

abstract class SearchQueryEvent extends Equatable {
  const SearchQueryEvent();
}

class ClearSearchQuery extends SearchQueryEvent {
  const ClearSearchQuery();

  @override
  List<Object> get props => ['ClearSearchQuery'];
}

class SetSearchQuery extends SearchQueryEvent {
  final String query;

  const SetSearchQuery(this.query);

  @override
  List<Object> get props => [query];
}
