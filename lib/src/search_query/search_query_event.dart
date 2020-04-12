part of 'search_query_bloc.dart';

/// {@template searchqueryevent}
/// Base [SearchQueryEvent] for extension.
/// {@endtemplate}
abstract class SearchQueryEvent extends Equatable {
  /// {@macro searchqueryevent}
  const SearchQueryEvent();
}

/// {@template clearsearchquery}
/// Dispatched from your UI to clear the current search query.
///
/// *Note:* this is functionally equivalent to setting the search query to
/// an empty string.
/// {@endtemplate}
class ClearSearchQuery extends SearchQueryEvent {
  /// {@macro clearsearchquery}
  const ClearSearchQuery();

  @override
  List<Object> get props => ['ClearSearchQuery'];
}

/// {@template setsearchquery}
/// Dispatched from your UI to set a search query to be applied
/// against the items from the source bloc.
/// {@endtemplate}
class SetSearchQuery extends SearchQueryEvent {
  /// The search query to set to the state.
  final String query;

  /// {@macro setsearchquery}
  const SetSearchQuery(this.query);

  @override
  List<Object> get props => [query];
}
