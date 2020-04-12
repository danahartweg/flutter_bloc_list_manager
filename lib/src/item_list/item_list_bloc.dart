import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../filter_conditions/filter_conditions_bloc.dart';
import '../item_source.dart';
import '../search_query/search_query_bloc.dart';
import '../utils.dart';

part 'item_list_state.dart';

enum _itemListEvent {
  filterConditionsUpdated,
  searchQueryUpdated,
  sourceUpdated
}

class ItemListBloc<I extends ItemClassWithPropGetter, T extends ItemSource>
    extends Bloc<_itemListEvent, ItemListState> {
  final FilterConditionsBloc _filterConditionsBloc;
  final SearchQueryBloc _searchQueryBloc;
  final Bloc _sourceBloc;
  final List<String> _searchProperties;

  StreamSubscription _filterConditionsSubscription;
  StreamSubscription _searchQuerySubscription;
  StreamSubscription _sourceSubscription;

  ItemListBloc({
    @required FilterConditionsBloc filterConditionsBloc,
    @required SearchQueryBloc searchQueryBloc,
    @required Bloc sourceBloc,
    List<String> searchProperties,
  })  : assert(filterConditionsBloc != null),
        assert(searchQueryBloc != null),
        assert(sourceBloc != null),
        _filterConditionsBloc = filterConditionsBloc,
        _searchQueryBloc = searchQueryBloc,
        _sourceBloc = sourceBloc,
        _searchProperties = searchProperties {
    _filterConditionsSubscription = _filterConditionsBloc.listen((_) {
      add(_itemListEvent.filterConditionsUpdated);
    });

    _searchQuerySubscription = _searchQueryBloc.listen((_) {
      add(_itemListEvent.searchQueryUpdated);
    });

    _sourceSubscription = _sourceBloc.listen((_) {
      add(_itemListEvent.sourceUpdated);
    });
  }

  @override
  ItemListState get initialState => EmptySource();

  @override
  Stream<ItemListState> mapEventToState(
    _itemListEvent event,
  ) async* {
    if (_filterConditionsBloc.state is! ConditionsInitialized ||
        _sourceBloc.state is! T) {
      yield EmptySource();
      return;
    }

    if (event != _itemListEvent.sourceUpdated &&
        event != _itemListEvent.filterConditionsUpdated &&
        event != _itemListEvent.searchQueryUpdated) {
      return;
    }

    final items = (_sourceBloc.state as T).items;
    final filterResults = _filterSource(items);
    final searchResults = _searchSource(_searchQueryBloc.state, filterResults);

    if (searchResults.isEmpty) {
      yield NoResults();
    } else {
      yield ItemListResults(searchResults.toList());
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
