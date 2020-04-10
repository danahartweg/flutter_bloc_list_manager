abstract class ItemClassWithPropGetter {
  dynamic operator [](String prop) {}
}

abstract class ItemSource<I extends ItemClassWithPropGetter> {
  final List<I> items;

  const ItemSource(this.items);
}
