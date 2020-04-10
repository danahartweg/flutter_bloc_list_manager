import 'package:bloc/bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:equatable/equatable.dart';

import 'package:bloc_filter_search_list/bloc_filter_search_list.dart';

class MockSourceBloc extends MockBloc<ItemSource, MockSourceBlocState>
    implements Bloc<ItemSource, MockSourceBlocState> {}

abstract class MockSourceBlocState extends Equatable {
  const MockSourceBlocState();
}

class MockSourceBlocNoItems extends MockSourceBlocState {
  const MockSourceBlocNoItems();

  @override
  List<Object> get props => ['No Items'];
}

class MockItemClass extends Equatable implements ItemClassWithPropGetter {
  final String id;
  final String name;
  final String extra;
  final bool conditional;

  const MockItemClass({
    this.id,
    this.name,
    this.extra,
    this.conditional,
  });

  dynamic operator [](String prop) {
    switch (prop) {
      case 'id':
        return this.id;
        break;
      case 'name':
        return this.name;
        break;
      case 'extra':
        return this.extra;
        break;
      case 'conditional':
        return this.conditional;
        break;
      default:
        throw ArgumentError(
          'Property `${prop}` does not exist on PlantVarietyIndex.',
        );
    }
  }

  @override
  List<Object> get props => [id, name, extra, conditional];
}

class MockSourceBlocClassItems extends MockSourceBlocState
    implements ItemSourceClass<MockItemClass> {
  final items;

  const MockSourceBlocClassItems(this.items);

  @override
  List<Object> get props => [items];
}

class MockSourceBlocMapItems extends MockSourceBlocState
    implements ItemSourceMap<Map<String, dynamic>> {
  final items;

  const MockSourceBlocMapItems(this.items);

  @override
  List<Object> get props => [items];
}
