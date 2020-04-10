import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'package:bloc_filter_search_list/bloc_filter_search_list.dart';
import '../utils.dart';

part 'item_list_state.dart';

enum ItemListEvent {
  FilterConditionsUpdated,
  SearchQueryUpdated,
  SourceUpdated
}

class ItemListBloc<I extends ItemClassWithPropGetter, T extends ItemSource, S>
    extends Bloc<ItemListEvent, ItemListState> {
  final FilterConditionsBloc _filterConditionsBloc;
  final SearchQueryBloc _searchQueryBloc;
  final Bloc<dynamic, S> _sourceBloc;
  final List<String> _searchProperties;

  StreamSubscription _filterConditionsSubscription;
  StreamSubscription _searchQuerySubscription;
  StreamSubscription _sourceSubscription;

  ItemListBloc({
    @required FilterConditionsBloc filterConditionsBloc,
    @required SearchQueryBloc searchQueryBloc,
    @required Bloc<dynamic, S> sourceBloc,
    List<String> searchProperties,
  })  : assert(filterConditionsBloc != null),
        assert(searchQueryBloc != null),
        assert(sourceBloc != null),
        _filterConditionsBloc = filterConditionsBloc,
        _searchQueryBloc = searchQueryBloc,
        _sourceBloc = sourceBloc,
        _searchProperties = searchProperties {
    _filterConditionsSubscription = _filterConditionsBloc.listen((_) {
      add(ItemListEvent.FilterConditionsUpdated);
    });

    _searchQuerySubscription = _searchQueryBloc.listen((_) {
      add(ItemListEvent.SearchQueryUpdated);
    });

    _sourceSubscription = _sourceBloc.listen((_) {
      add(ItemListEvent.SourceUpdated);
    });
  }

  @override
  ItemListState get initialState => EmptySource();

  @override
  Stream<ItemListState> mapEventToState(
    ItemListEvent event,
  ) async* {
    if (_filterConditionsBloc.state is! ConditionsInitialized ||
        _sourceBloc.state is! T) {
      yield EmptySource();
      return;
    }

    if (event != ItemListEvent.SourceUpdated &&
        event != ItemListEvent.FilterConditionsUpdated &&
        event != ItemListEvent.SearchQueryUpdated) {
      return;
    }

    final items = (_sourceBloc.state as T).items;
    final filterResults = _filterSource(items);
    final searchResults = _searchSource(_searchQueryBloc.state, filterResults);

    if (searchResults.isEmpty) {
      yield NoResults();
    } else {
      yield ItemListResults<I>(searchResults.toList());
    }
  }

  Iterable<I> _filterSource(List<I> items) {
    final activeConditions =
        (_filterConditionsBloc.state as ConditionsInitialized).activeConditions;

    if (activeConditions.isEmpty) {
      return items;
    }

    return items.where((item) => activeConditions.any((conditionKey) {
          final conditionKeyValue = splitConditionKey(conditionKey);
          return item[conditionKeyValue[0]] == conditionKeyValue[1];
        }));
  }

  Iterable<I> _searchSource(String searchQuery, Iterable<I> items) {
    if (searchQuery.isEmpty) {
      return items;
    }

    return items.where((item) => _searchProperties.any((property) {
          final value = item[property];
          return value is String
              ? value.toLowerCase().contains(searchQuery)
              : false;
        }));
  }

  @override
  Future<void> close() async {
    await _filterConditionsSubscription?.cancel();
    await _searchQuerySubscription?.cancel();
    await _sourceSubscription?.cancel();

    return super.close();
  }
}
