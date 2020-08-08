import 'package:bloc/bloc.dart';

/// {@template searchquerycubit}
/// Cubit that acts as a holder for the current search query.
///
/// There should be no need to ever manually construct a [SearchQueryCubit].
/// It should, instead, be retrieved from within the `ListManager`
/// in order to set or clear the search query.
/// {@endtemplate}
class SearchQueryCubit extends Cubit<String> {
  /// {@macro searchquerycubit}
  SearchQueryCubit() : super('');

  /// Called from your UI to clear the current search query.
  ///
  /// *Note:* this is functionally equivalent to setting
  /// the search query to an empty string.
  void clearQuery() => emit('');

  /// Called from your UI to set a search query to be applied
  /// against the items from the source bloc.
  ///
  /// *Note:* the query will be stored lowercase.
  void setQuery(String query) => emit(query.toLowerCase());
}
