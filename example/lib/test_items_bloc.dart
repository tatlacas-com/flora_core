import 'package:flora_core/flora_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TestItemsBloc extends ItemsManagerBloc {
  @override
  Future<ResponseItems<Section>> getLocalItems(
      Emitter<ItemsManagerState> emit) async {
    final section0 = List.generate(
      200,
      (index) => index,
    );
    return ResponseItems(
      items: [Section(items: section0)],
      count: section0.length,
    );
  }
}
