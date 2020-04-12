part of 'item_list_bloc.dart';

abstract class ItemListState extends Equatable {
  const ItemListState();
}

class EmptySource extends ItemListState {
  const EmptySource();

  @override
  List<Object> get props => ['Empty Source'];
}

class NoResults extends ItemListState {
  const NoResults();

  @override
  List<Object> get props => ['No Results'];
}

class ItemListResults<I extends ItemClassWithPropGetter> extends ItemListState {
  final List<I> items;

  const ItemListResults(this.items);

  @override
  List<Object> get props => [items];
}
