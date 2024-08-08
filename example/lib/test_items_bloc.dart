import 'package:flora_core/flora_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TestItemsBloc extends ItemsManagerBloc {
  @override
  Future<ResponseItems<Section>> loadItemsFromLocalStorage(
      Emitter<ItemsManagerState> emit) async {
    final section0 = [0, 1, 2];
    return ResponseItems(
      items: [Section(items: section0)],
      count: section0.length,
    );
  }
}
