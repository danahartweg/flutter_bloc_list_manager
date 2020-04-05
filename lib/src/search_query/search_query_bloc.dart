import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'search_query_event.dart';

class SearchQueryBloc extends Bloc<SearchQueryEvent, String> {
  @override
  String get initialState => '';

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
