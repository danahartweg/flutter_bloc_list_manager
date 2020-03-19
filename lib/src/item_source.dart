abstract class ItemClassWithPropGetter {
  dynamic operator [](String prop) {}
}

abstract class ItemSourceClass<T extends ItemClassWithPropGetter> extends ItemSource<T> {
  const ItemSourceClass(List<T> items): super(items);
}

abstract class ItemSourceMap<T extends Map<String, dynamic>> extends ItemSource<T> {
  const ItemSourceMap(List<T> items): super(items);
}

abstract class ItemSource<T> {
  final List<T> items;

  const ItemSource(this.items);
}
