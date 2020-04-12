import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

import '../bloc_filter_search_list.dart';

class BlocFilterSearchList<I extends ItemClassWithAccessor,
    T extends ItemSourceState, B extends Bloc> extends StatelessWidget {
  final Widget child;
  final List<String> filterProperties;
  final List<String> searchProperties;
  final B sourceBloc;

  BlocFilterSearchList({
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
