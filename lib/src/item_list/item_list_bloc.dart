import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'package:bloc_filter_search_list/bloc_filter_search_list.dart';

part 'item_list_state.dart';

enum ItemListEvent { FilterConditionsUpdated, SourceUpdated }

class ItemListBloc<I, T extends ItemSource, S>
    extends Bloc<ItemListEvent, ItemListState> {
  final FilterConditionsBloc _filterConditionsBloc;
  final Bloc<dynamic, S> _sourceBloc;

  StreamSubscription _filterConditionsSubscription;
  StreamSubscription _sourceSubscription;

  ItemListBloc({
    @required FilterConditionsBloc filterConditionsBloc,
    @required Bloc<dynamic, S> sourceBloc,
  })  : assert(filterConditionsBloc != null),
        assert(sourceBloc != null),
        _filterConditionsBloc = filterConditionsBloc,
        _sourceBloc = sourceBloc {
    _filterConditionsSubscription = _filterConditionsBloc.listen((_) {
      add(ItemListEvent.FilterConditionsUpdated);
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
    if (event == ItemListEvent.FilterConditionsUpdated ||
        event == ItemListEvent.SourceUpdated) {
      yield _mapFilterConditionsAndSourceToState();
    }
  }

  ItemListState _mapFilterConditionsAndSourceToState() {
    if (_filterConditionsBloc.state is! ConditionsInitialized ||
        _sourceBloc.state is! T) {
      return EmptySource();
    }

    final activeConditions =
        (_filterConditionsBloc.state as ConditionsInitialized).activeConditions;
    final sourceItems = (_sourceBloc.state as T).items;

    if (activeConditions.isEmpty) {
      return ItemListResults<I>(sourceItems);
    }

    final filteredItems = sourceItems.where((item) => activeConditions.entries
        .any((entry) => entry.value.contains(item[entry.key])));

    if (filteredItems.isEmpty) {
      return NoFilteredResults();
    }

    return ItemListResults<I>(filteredItems.toList());
  }

  @override
  Future<void> close() async {
    await _filterConditionsSubscription?.cancel();
    await _sourceSubscription?.cancel();

    return super.close();
  }
}
