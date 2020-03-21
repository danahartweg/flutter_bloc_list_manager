import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

import '../bloc_filter_search_list.dart';

class BlocFilterSearchList<I, T extends ItemSource, S, B extends Bloc<dynamic, S>>
    extends StatelessWidget {
  final Widget child;
  final List<String> filterProperties;
  final Bloc<dynamic, S> sourceBloc;

  BlocFilterSearchList({
    @required this.child,
    @required this.filterProperties,
    this.sourceBloc,
  })  : assert(child != null),
        assert(filterProperties != null);

  @override
  Widget build(BuildContext context) {
    final _sourceBloc = sourceBloc ?? context.bloc<B>();

    return MultiBlocProvider(
      providers: [
        BlocProvider<FilterConditionsBloc>(
          create: (context) => FilterConditionsBloc<T, S>(
            sourceBloc: _sourceBloc,
            filterProperties: filterProperties,
          ),
        ),
        BlocProvider<ItemListBloc>(
          create: (context) => ItemListBloc<I, T, S>(
            sourceBloc: _sourceBloc,
            filterConditionsBloc: context.bloc<FilterConditionsBloc>(),
          ),
        )
      ],
      child: child,
    );
  }
}
