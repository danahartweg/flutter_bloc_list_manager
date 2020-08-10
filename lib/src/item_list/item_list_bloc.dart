import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../filter_conditions/filter_conditions_bloc.dart';
import '../item_source.dart';
import '../search_query/search_query.dart';
import '../utils.dart';

part 'item_list_state.dart';

enum _itemListEvent {
  filterConditionsUpdated,
  searchQueryUpdated,
  sourceUpdated
}

/// {@template itemlistbloc}
/// Attaches to the provided [_filterConditionsBloc], [_searchQueryCubit],
/// and [_sourceBloc] and uses supplied [_searchProperties]
/// in order to generate a list of items that should be rendered to the UI.
///
/// The active conditions from the supplied [_filterConditionsBloc]
/// are additive, so items matching *any* of the active conditions will be
/// returned. Once the source items have been filtered, the search query
/// will be applied to any remaining items to generate the final list state.
///
/// There should be no need to ever manually construct an [ItemListBloc].
/// It should, instead, be retrieved from within the `ListManager`
/// in order to render your list UI however you see fit.
/// {@endtemplate}
class ItemListBloc<I extends ItemClassWithAccessor, T extends ItemSourceState>
    extends Bloc<_itemListEvent, ItemListState> {
  final FilterConditionsBloc _filterConditionsBloc;
  final SearchQueryCubit _searchQueryCubit;
  final Bloc _sourceBloc;
  final List<String> _searchProperties;

  StreamSubscription _filterConditionsSubscription;
  StreamSubscription _searchQuerySubscription;
  StreamSubscription _sourceSubscription;

  /// {@macro itemlistbloc}
  ItemListBloc({
    @required FilterConditionsBloc filterConditionsBloc,
    @required SearchQueryCubit searchQueryCubit,
    @required Bloc sourceBloc,
    List<String> searchProperties,
  })  : assert(filterConditionsBloc != null),
        assert(searchQueryCubit != null),
        assert(sourceBloc != null),
        _filterConditionsBloc = filterConditionsBloc,
        _searchQueryCubit = searchQueryCubit,
        _sourceBloc = sourceBloc,
        _searchProperties = searchProperties,
        super(NoSourceItems()) {
    _filterConditionsSubscription = _filterConditionsBloc.listen((_) {
      add(_itemListEvent.filterConditionsUpdated);
    });

    _searchQuerySubscription = _searchQueryCubit.listen((_) {
      add(_itemListEvent.searchQueryUpdated);
    });

    _sourceSubscription = _sourceBloc.listen((_) {
      add(_itemListEvent.sourceUpdated);
    });
  }

  @override
  Stream<ItemListState> mapEventToState(
    _itemListEvent event,
  ) async* {
    if (_filterConditionsBloc.state is! ConditionsInitialized ||
        _sourceBloc.state is! T) {
      yield NoSourceItems();
      return;
    }

    if (event != _itemListEvent.sourceUpdated &&
        event != _itemListEvent.filterConditionsUpdated &&
        event != _itemListEvent.searchQueryUpdated) {
      return;
    }

    final items = (_sourceBloc.state as T).items;
    final filterResults = _filterSource(items);
    final searchResults = _searchSource(_searchQueryCubit.state, filterResults);

    if (searchResults.isEmpty) {
      yield ItemEmptyState();
    } else {
      yield ItemResults(searchResults.toList());
    }
  }

  Iterable<I> _filterSource(List<I> items) {
    final activeOrConditions =
        (_filterConditionsBloc.state as ConditionsInitialized)
            .activeOrConditions;

    if (activeOrConditions.isEmpty) {
      return items;
    }

    // If any active condition matches we can immediately return that item.
    return items.where((item) => activeOrConditions.any((conditionKey) {
          final parsedConditionKey = splitConditionKey(conditionKey);

          final property = parsedConditionKey[0];
          final itemValue = item[property];
          final targetValue = parsedConditionKey[1];

          if (itemValue is bool) {
            return itemValue.toString() == targetValue.toLowerCase();
          }

          return itemValue == targetValue;
        }));
  }

  Iterable<I> _searchSource(String searchQuery, Iterable<I> items) {
    if (searchQuery.isEmpty) {
      return items;
    }

    // Search queries are stored lowercase, so we want to match
    // against a lowercase value as well.
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
