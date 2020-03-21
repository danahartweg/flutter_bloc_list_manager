part of 'item_list_bloc.dart';

abstract class ItemListState extends Equatable {
  const ItemListState();
}

class EmptySource extends ItemListState {
  const EmptySource();

  @override
  List<Object> get props => ['Empty Source'];
}

class NoFilteredResults extends ItemListState {
  const NoFilteredResults();

  @override
  List<Object> get props => ['No Filtered Results'];
}

class ItemListResults<I> extends ItemListState {
  final List<I> items;

  const ItemListResults(this.items);

  @override
  List<Object> get props => [items];
}
