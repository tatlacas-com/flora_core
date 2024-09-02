import 'package:flora_core/flora_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TestItemsBloc extends ItemsManagerBloc {
  @override
  Future<ResponseItems<Section>> getLocalItems(
      Emitter<ItemsManagerState> emit) async {
    await Future.delayed(const Duration(seconds: 2));
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
