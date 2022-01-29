// In this example we'll set up a source bloc and associated item class.
// Additionally we'll flesh out a basic UI that will provide a search bar,
// a rendered list, and a bottom sheet that will display
// UI for managing the filter conditions.

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_list_manager/flutter_bloc_list_manager.dart';

// Data, state, and event classes.

// Base data class that will be supplied by the source bloc.
void main() {
  runApp(
    // Provide our source bloc to the remainder of the tree. In an actual app,
    // this would happen much close to where it was needed.
    BlocProvider<JournalEntryBloc>(
      create: (_) => JournalEntryBloc()..add(_journalEntryEvent.load),
      child: MaterialApp(
        title: 'Flutter Bloc List Manager',
        home: Scaffold(
          appBar: AppBar(
            title: Text('Flutter Bloc List Manager'),
          ),
          body: ListManager<JournalEntry, Loaded, JournalEntryBloc>(
            filterProperties: ['author', 'category', 'isPublished'],
            searchProperties: ['content', 'description', 'title'],
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SearchInput(),
                    FilterConditionsLauncher(),
                  ],
                ),
                SizedBox(height: 10.0),
                Expanded(
                  child: ItemListRenderer(),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

// The base state for the source bloc.
const _filterPropertyLabelMap = {
  'author': 'Author',
  'category': 'Category',
  'isPublished': 'Published',
};

// State of the source bloc where items have not yet been loaded.
class FilterConditionGroup extends StatelessWidget {
  final MapEntry<String, List<String>> condition;
  final Function(String property, String value) isOptionActive;
  final Function updateCondition;

  FilterConditionGroup({
    Key key,
    @required this.condition,
    @required this.isOptionActive,
    @required this.updateCondition,
  }) : super(key: key);

  @override
  Widget build(_) {
    return Container(
      key: ValueKey(condition.key),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _filterPropertyLabelMap[condition.key],
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          ...condition.value.map(
            (option) => CheckboxListTile(
              key: ValueKey(option),
              title: Text(option),
              value: isOptionActive(condition.key, option),
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (isChecked) =>
                  updateCondition(condition.key, option, isChecked),
            ),
          ),
        ],
      ),
    );
  }
}

// State of the source bloc that indicates items have been loaded
// and are ready for further processing.
class FilterConditionsLauncher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.filter_list),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (_) => FilterConditionsSheet(
            filterConditionsBloc: context.read<FilterConditionsBloc>(),
          ),
          elevation: 1,
        );
      },
    );
  }
}

// Just a stub event for example purposes.
// Your actual source bloc would have more logic.
class FilterConditionsSheet extends StatelessWidget {
  // You must pass the FilterConditionsBloc to this widget, as the build
  // context will now belong to the Scaffold rendering the bottom sheet.
  final FilterConditionsBloc _filterConditionsBloc;

  const FilterConditionsSheet({@required filterConditionsBloc})
      : assert(filterConditionsBloc != null),
        _filterConditionsBloc = filterConditionsBloc;

  // Helper to avoid duplication in the child components and to avoid
  // having to pass the bloc down another level.
  // Handles toggling property/value pair in the filter conditions bloc.
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      child: BlocBuilder<FilterConditionsBloc, FilterConditionsState>(
        bloc: _filterConditionsBloc,
        builder: (_, state) {
          if (state is ConditionsInitialized) {
            // This could be further optimized by removing
            // the `FilterConditionGroup` all together and conditionally
            // rendering title or option rows.
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: state.availableConditions.length,
              itemBuilder: (_, index) {
                final condition =
                    state.availableConditions.entries.elementAt(index);
                return FilterConditionGroup(
                  condition: condition,
                  isOptionActive: _isOptionActive,
                  updateCondition: _updateCondition,
                );
              },
            );
          }

          return CircularProgressIndicator();
        },
      ),
    );
  }

  bool _isOptionActive(String property, String value) {
    return _filterConditionsBloc.isConditionActive(property, value);
  }

  void _updateCondition(String property, String value, bool isChecked) {
    isChecked
        ? _filterConditionsBloc.add(AddCondition(
            property: property,
            value: value,
          ))
        : _filterConditionsBloc.add(RemoveCondition(
            property: property,
            value: value,
          ));
  }
}

class ItemListRenderer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ItemListBloc, ItemListState>(
      builder: (_, state) {
        if (state is NoSourceItems) {
          return Text('No source items');
        }

        if (state is ItemEmptyState) {
          return Text('No matching results');
        }

        if (state is ItemResults<JournalEntry>) {
          return ListView(
            children: state.items
                .map(
                  (entry) => ListTile(
                    key: ValueKey(entry.id),
                    title: Text(entry.title),
                    subtitle: Text(entry.description),
                  ),
                )
                .toList(),
          );
        }

        return Container();
      },
    );
  }
}

class JournalEntry extends Equatable implements ItemClassWithAccessor {
  final String author;
  final String category;
  final String content;
  final String description;
  final String id;
  final String title;
  final bool isPublished;

  const JournalEntry({
    this.author,
    this.category,
    this.content,
    this.description,
    this.id,
    this.title,
    this.isPublished,
  });

  // Every prop intended to be used in a filtering or sorting operation
  // should be included in this operator overload.
  @override
  List<Object> get props =>
      [author, content, description, id, title, isPublished];

  dynamic operator [](String prop) {
    switch (prop) {
      case 'author':
        return author;
        break;
      case 'category':
        return category;
        break;
      case 'content':
        return content;
        break;
      case 'description':
        return description;
        break;
      case 'title':
        return title;
        break;
      case 'isPublished':
        return isPublished;
        break;
      default:
        throw ArgumentError('Property `$prop` does not exist on JournalEntry.');
    }
  }
}

// Render an input that will funnel the value into the SearchQueryCubit.
class JournalEntryBloc extends Bloc<_journalEntryEvent, JournalEntryState> {
  JournalEntryBloc() : super(Loading());

  @override
  Stream<JournalEntryState> mapEventToState(
    _journalEntryEvent event,
  ) async* {
    if (event == _journalEntryEvent.load) {
      // Stub data for the example, you would likely be using some sort
      // of repository here to fetch your data.
      yield Loaded([
        JournalEntry(
          author: 'Author 1',
          category: 'Category 1',
          content: 'Content 1',
          description: 'Description 1',
          id: '1',
          title: 'Title 1',
          isPublished: true,
        ),
        JournalEntry(
          author: 'Author 2',
          category: 'Category 2',
          content: 'Content 2',
          description: 'Description 2',
          id: '2',
          title: 'Title 2',
          isPublished: false,
        ),
        JournalEntry(
          author: 'Author 3',
          category: 'Category 3',
          content: 'Content 3',
          description: 'Description 3',
          id: '3',
          title: 'Title 3',
          isPublished: true,
        )
      ]);
    }
  }
}

// Render an icon button that will launch the filter conditions UI sheet
// into the current scaffold.
abstract class JournalEntryState extends Equatable {
  const JournalEntryState();
}

// Hooks into the `FilterConditionsBloc` in order to render the filtering UI.
class Loaded extends JournalEntryState
    implements ItemSourceState<JournalEntry> {
  final List<JournalEntry> items;

  const Loaded(this.items);

  @override
  List<Object> get props => [items];
}

// As we've built a UI around filtering, we need display-friendly
// labels for the underlying property names.
// This could easily be provided statically by the base item class instead.
class Loading extends JournalEntryState {
  @override
  List<Object> get props => ['Loading'];
}

// Essentially just a pass-through widget to simplify the rendering
// of each condition group.
class SearchInput extends StatelessWidget {
  @override
  Widget build(_) {
    return BlocBuilder<SearchQueryCubit, String>(
      builder: (context, state) {
        return Flexible(
          child: TextField(
            decoration: const InputDecoration(
              icon: Icon(Icons.search),
              labelText: 'Search',
            ),
            textInputAction: TextInputAction.search,
            onChanged: (value) =>
                context.read<SearchQueryCubit>().setQuery(value),
          ),
        );
      },
    );
  }
}

// Hooks into the state from the `ItemListBloc` and renders the list
// portion of the UI.
enum _journalEntryEvent { load }
