import 'package:bloc/bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:equatable/equatable.dart';

import 'package:flutter_bloc_list_manager/flutter_bloc_list_manager.dart';

class MockSourceBloc extends MockBloc<MockSourceBlocState>
    implements Bloc<ItemSourceState, MockSourceBlocState> {}

abstract class MockSourceBlocState extends Equatable {
  const MockSourceBlocState();
}

class MockSourceBlocNoItems extends MockSourceBlocState {
  const MockSourceBlocNoItems();

  @override
  List<Object> get props => ['No Items'];
}

class MockItemClass extends Equatable implements ItemClassWithAccessor {
  final String id;
  final String name;
  final String extra;
  final String common;
  final bool conditional;

  const MockItemClass({
    this.id,
    this.name,
    this.extra,
    this.common,
    this.conditional,
  });

  dynamic operator [](String prop) {
    switch (prop) {
      case 'id':
        return id;
        break;
      case 'name':
        return name;
        break;
      case 'extra':
        return extra;
        break;
      case 'common':
        return common;
        break;
      case 'conditional':
        return conditional;
        break;
      default:
        throw ArgumentError(
          'Property `$prop` does not exist on PlantVarietyIndex.',
        );
    }
  }

  @override
  List<Object> get props => [id, name, extra, common, conditional];
}

class MockSourceBlocClassItems extends MockSourceBlocState
    implements ItemSourceState<MockItemClass> {
  final List<MockItemClass> items;

  const MockSourceBlocClassItems(this.items);

  @override
  List<Object> get props => [items];
}
