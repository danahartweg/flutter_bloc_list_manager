import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

import '../flutter_bloc_list_manager.dart';

/// {@template listmanager}
/// Intended to be the main entry point and the only widget one should
/// ever construct when using this package. UI needing to consume
/// the child blocs should do so via traditional [BlocBuilder] implementations.
///
/// ```dart
/// class YourListWidget extends StatelessWidget {
///   @override
///   build(context) {
///     return Scaffold(
///       appBar: AppBar(
///         title: Text('List Widget'),
///       ),
///       body: BlocProvider<YourItemSourceBloc>(
///         create: (_) => YourItemSourceBloc(),
///         child: ListManager<
///             YourItemClass,
///             YourSourceBlocStateWithItems,
///             YourItemSourceBloc>(
///           filterProperties: ['property1'],
///           searchProperties: ['property2'],
///           child: Column(
///             children: [
///               BlocBuilder<FilterConditionsBloc, FilterConditionsState>(
///                 builder: (context, state) {
///                   return Text('Render your filter conditions UI.');
///                 },
///               ),
///               BlocBuilder<SearchQueryBloc, String>(
///                 builder: (context, state) {
///                   return Text('Render your Search UI.');
///                 },
///               ),
///               BlocBuilder<ItemListBloc, ItemListState>(
///                 builder: (context, state) {
///                   return Text('Render your list UI.');
///                 },
///               ),
///             ],
///           ),
///         ),
///       ),
///     );
///   }
/// }
/// ```
/// {@endtemplate}
class ListManager<I extends ItemClassWithAccessor, T extends ItemSourceState,
    B extends Bloc> extends StatelessWidget {
  /// The widget to be rendered. The build context will have access to all
  /// of the blocs created by this widget to manage your list.
  final Widget child;

  /// A [List] of property keys that should be used
  /// by the [FilterConditionsBloc] when generating available conditions.
  final List<String> filterProperties;

  /// A [List] of property keys that should be used
  /// by the [ItemListBloc] while searching against the active query.
  final List<String> searchProperties;

  /// [Bloc] that will contain an [ItemSourceState]. If one is not provided
  /// the current [BuildContext] will be used to look it up.
  final B sourceBloc;

  /// {@macro listmanager}
  ListManager({
    @required this.child,
    @required this.filterProperties,
    this.searchProperties,
    this.sourceBloc,
  })  : assert(child != null),
        assert(filterProperties != null);

  @override
  Widget build(BuildContext context) {
    final _sourceBloc = sourceBloc ?? context.bloc<B>();

    return MultiBlocProvider(
      providers: [
        BlocProvider<FilterConditionsBloc>(
          create: (context) => FilterConditionsBloc<T>(
            sourceBloc: _sourceBloc,
            filterProperties: filterProperties,
          ),
        ),
        BlocProvider<SearchQueryBloc>(
          create: (context) => SearchQueryBloc(),
        ),
        BlocProvider<ItemListBloc>(
          create: (context) => ItemListBloc<I, T>(
            sourceBloc: _sourceBloc,
            filterConditionsBloc: context.bloc<FilterConditionsBloc>(),
            searchQueryBloc: context.bloc<SearchQueryBloc>(),
            searchProperties: searchProperties,
          ),
        )
      ],
      child: child,
    );
  }
}
