part of 'item_list_bloc.dart';

/// {@template itemsemptystate}
/// State corresponding to no items matching
/// the active conditions or search query.
///
/// This state should be used to present an empty state to the user.
/// {@endtemplate}
class ItemEmptyState extends ItemListState {
  /// {@macro itemsemptystate}
  const ItemEmptyState();

  @override
  List<Object> get props => ['No Results'];
}

/// {@template itemliststate}
/// Base [FilterConditionsState] for extension.
/// {@endtemplate}
abstract class ItemListState extends Equatable {
  /// {@macro itemliststate}
  const ItemListState();
}

/// {@template itemresults}
/// State containing the [items] that have been filtered and searched
/// according to the active conditions and search query.
///
/// The items should be the source of truth to render in your list UI.
/// {@endtemplate}
class ItemResults<I extends ItemClassWithAccessor> extends ItemListState {
  /// Items that have made it past filtering and searching.
  final List<I> items;

  /// {@macro itemresults}
  const ItemResults(this.items);

  @override
  List<Object> get props => [items];
}

/// {@template nosourceitems}
/// State corresponding to no items received from the source bloc.
///
/// This state should be used to present an empty state to the user.
/// {@endtemplate}
class NoSourceItems extends ItemListState {
  /// {@macro nosourceitems}
  const NoSourceItems();

  @override
  List<Object> get props => ['Empty Source'];
}
