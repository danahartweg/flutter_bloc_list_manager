import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'search_query_event.dart';

/// {@template searchquerybloc}
/// Very simple bloc that simply acts as a holder for the current
/// search query.
///
/// There should be no need to ever manually construct a [SearchQueryBloc].
/// It should, instead, be retrieved from within the `ListManager`
/// in order to dispatch events to add or clear the search query.
/// /// {@endtemplate}
class SearchQueryBloc extends Bloc<SearchQueryEvent, String> {
  /// {@macro searchquerybloc}
  SearchQueryBloc() : super('');

  @override
  Stream<String> mapEventToState(
    SearchQueryEvent event,
  ) async* {
    if (event is ClearSearchQuery) {
      yield '';
    } else if (event is SetSearchQuery) {
      yield event.query.toLowerCase();
    }
  }
}
