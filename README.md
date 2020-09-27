# Flutter Bloc List Manager

[![Pub](https://img.shields.io/pub/v/flutter_bloc_list_manager.svg)](https://pub.dev/packages/flutter_bloc_list_manager)
[![style: effective dart](https://img.shields.io/badge/style-effective_dart-40c4ff.svg)](https://github.com/tenhobi/effective_dart)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

A Flutter package built on top of [flutter_bloc](https://pub.dev/packages/flutter_bloc) that makes it easy to manage filtering and searching a list of items while allowing you to concentrate on building your UI.

Read more about [the implementation](https://medium.com/flutter-community/building-a-package-to-manage-lists-with-flutter-bloc-7197e2dd7811) and about [adding boolean filtering support](https://medium.com/flutter-community/adding-boolean-filtering-to-flutter-bloc-list-manager-5847ee68be26).

## Widgets

### ListManager Widget

The `ListManager` widget is the entry-point to accessing the blocs provided by this package. There is no need to manually create any of the other blocs this package provides, they are all available from the build context underneath the `ListManager` widget.

`ListManager` should be established with:

_Types_

- `I` - the [item class](#ItemClassWithAccessor) holding the data for the list
- `T` - the [state](#ItemSourceState) containing the loaded items
- `B` - the bloc that contains the above state

_Parameters_

- `filterProperties` - properties that exist on your item class `I` that should be used to generate filter conditions
- `searchProperties` - properties that exist on your item class `I` that should be used to run search queries against
- `child` - the widget to be rendered by the `ListManager`, which will have access to the remaining blocs

_Example_

```dart
BlocProvider<SourceBloc>(
  create: (_) => SourceBloc(),
  child: ListManager<ItemClass, SourceLoaded, SourceBloc>(
    filterProperties: ['property1'],
    searchProperties: ['property2'],
    child: Column(
      children: [
        BlocBuilder<FilterConditionsBloc, FilterConditionsState>(
          builder: (context, state) {
            return Text('Render filter conditions UI.');
          },
        ),
        BlocBuilder<SearchQueryCubit, String>(
          builder: (context, state) {
            return Text('Render Search UI.');
          },
        ),
        BlocBuilder<ItemListBloc, ItemListState>(
          builder: (context, state) {
            return Text('Render list UI.');
          },
        ),
      ],
    ),
  ),
)
```

### FilterConditionsBloc

State from `FilterConditionsBloc` is used to render your filtering UI. Filter conditions will be updated whenever the source bloc is updated.

String values are treated normally.

Boolean values are treated a little differently. If a boolean value is requested to be used as a `filterCondition`, display-friendly `True` and `False` conditions will automatically be added for you.

_Example_

```dart
BlocBuilder<FilterConditionsBloc, FilterConditionsState>(
  builder: (_, state) {
    if (state is ConditionsInitialized) {
      return ListView.builder(
        itemCount: state.availableConditions.length,
        itemBuilder: (_, index) {
          final condition = state.availableConditions.entries.elementAt(index);
          return Column(
            children: [
              Text(condition.key),
              ...condition.value.map(
                (value) => Text(value),
              ),
            ],
          ),
        },
      );
    }

    return CircularProgressIndicator();
  },
)
```

#### Dispatching events

Events can be dispatched against the `FilterConditionsBloc` to add/remove active property/value condition pairs. Whenever the source bloc is updated, active conditions that no longer apply are automatically removed.

_Example_

```dart
context.bloc<FilterConditionsBloc>().add(AddCondition(
  property: 'property',
  value: 'value',
));

context.bloc<FilterConditionsBloc>().add(RemoveCondition(
  property: 'property',
  value: 'value',
));
```

Note: If you want to manually toggle a boolean condition (i.e. not via constructing UI from the `availableConditions`), you would want to use `AddCondition('booleanProperty', 'True')` or `AddCondition('booleanProperty', 'False')` as those are the underlying display values.

#### Filter modes

You can choose to override the default filter mode when adding a specific condition for filtering. Perhaps you'd like the main filtering UI to be additive, but you would like to add a global toggle to add and remove a subtractive filter condition into the mix.

_Example_

```dart
context.bloc<FilterConditionsBloc>().add(AddCondition(
  property: 'property',
  value: 'value',
  mode: FilterMode.and,
));
```

### SearchQueryCubit

The simplest cubit of the bunch, the `SearchQueryCubit` is solely responsible for setting or clearing the search query that drives list searching.

_Example_

```dart
context.bloc<SearchQueryCubit>().setQuery('query');
context.bloc<SearchQueryCubit>().clearQuery();
```

### ItemListBloc

`ItemListBloc` is responsible for connecting all of the other blocs, performing the actual filtering and searching, and providing state in order to render your list UI. There is never a reason to dispatch events to this bloc.

_Note on filter modes_
Without a much more sophisticated means to assemble filter queries, there is no current way to support compound filtering: i.e. `(Condition 1 AND Condition 2) OR (Condition 3 AND Condition 4)` or priority scenarios: i.e. the difference between `(Condition 1 OR Condition 2 OR Condition 3) AND Condition 4` and `Condition 4 AND (Condition 1 OR Condition 2 OR Condition 3)`. As such, we've chosen to implement filtering such that additive (`or`) conditions are matched first and subtractive (`and`) conditions are matched last.

Practically, what does this mean?

Your list of items will first be filtered such that *every item* matching *any* single `or` condition is sent through. The resulting list will then be filtered such that *every item* matching *all* `and` conditions are sent through. The `and` conditions technically refine the resulting list and the `or` conditions generate the first pass of the list that should be refined.

_Example_

```dart
BlocBuilder<ItemListBloc, ItemListState>(
  builder: (_, state) {
    if (state is NoSourceItems) {
      return Text('No source items');
    }

    if (state is ItemEmptyState) {
      return Text('No matching results');
    }

    if (state is ItemResults<ItemClass>) {
      return ListView(
        children: state.items
            .map(
              (item) => ListTile(
                key: ValueKey(item.id),
                title: Text(item.name),
              ),
            )
            .toList(),
      );
    }

    return Container();
  },
)
```

## Data classes

There are a few setup pieces that are required in order to properly manage the data in your list.

### ItemClassWithAccessor

Flutter cannot use the dart mirroring packages, so the class used to store individual items in the list must have a prop accessor for any data that needs to be accessed dynamically (either by filtering or searching). The item class will generally also extend equatable as it will be used as part of your source bloc state.

```dart
class ItemClass extends Equatable implements ItemClassWithAccessor {
  final String id;
  final String name;

  const ItemClass({
    this.id,
    this.name,
  });

  dynamic operator [](String prop) {
    switch (prop) {
      case 'id':
        return id;
        break;
      case 'name':
        return name;
        break;
      default:
        throw ArgumentError(
          'Property `$prop` does not exist on ItemClass.',
        );
    }
  }

  @override
  List<Object> get props => [id, name];
}
```

### ItemSourceState

You are free to manage your source bloc however you see fit. The only requirement in order to instantiate a `ListManager` is that one of the states of your source bloc must implement `ItemSourceState`. This allows blocs in this package to know when source items are actually flowing through your source bloc.

_Example_

```dart
class SourceLoaded extends SourceBlocState implements ItemSourceState<ItemClass> {
  final items;

  const SourceLoaded(this.items);

  @override
  List<Object> get props => [items];
}
```

## Upcoming improvements

- Pluggable search callback (allowing integration of fuzzy search)
- Conditional instantiation of the `SearchQueryCubit`
- Integrating opinionated pre-composed UI widgets
- Potentially moving away from the source bloc concept and requiring a repository instead

## Examples

[Basic UI implementing all of the above blocs](./example/lib/main.dart)
