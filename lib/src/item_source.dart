/// Flutter cannot use the dart mirroring packages, so the class
/// used to store individual items in the list must have a prop accessor
/// for any data that needs to be accessed dynamically.
///
/// This item class will generally also extend equatable.
///
/// ```dart
/// class MockItemClass extends Equatable implements ItemClassWithPropGetter {
///   final String id;
///   final String name;

///   const MockItemClass({
///     this.id,
///     this.name,
///   });

///   dynamic operator [](String prop) {
///     switch (prop) {
///       case 'id':
///         return id;
///         break;
///       case 'name':
///         return name;
///         break;
///       default:
///         throw ArgumentError(
///           'Property `$prop` does not exist on PlantVarietyIndex.',
///         );
///     }
///   }

///   @override
///   List<Object> get props => [id, name];
/// }
/// ```
abstract class ItemClassWithAccessor {
  /// Dynamic [prop] accessor.
  dynamic operator [](String prop) {}
}

/// {@template itemsourcestate}
/// The state on the source bloc that contains the actual items to be
/// filtered and searched. This allows the source bloc to have multiple states
/// that it can manage internally.
/// {@endtemplate}
abstract class ItemSourceState<I extends ItemClassWithAccessor> {
  /// Raw list of items that are emitted from the source bloc.
  final List<I> items;

  /// {@macro itemsourcestate}
  const ItemSourceState(this.items);
}
