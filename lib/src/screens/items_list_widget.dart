import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../tatlacas_flutter_core.dart';

class ItemsListWidget<TBloc extends ItemsManagerBloc> extends StatelessWidget {
  final Widget Function(BuildContext context)? errorWidget;
  final Widget Function(BuildContext context)? loadingWidget;
  final Widget Function(BuildContext context)? bodyWidget;

  const ItemsListWidget({
    Key? key,
    this.errorWidget,
    this.loadingWidget,
    this.bodyWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TBloc, ItemsManagerState>(
      buildWhen: (prev, next) => next is ItemsBuildUi,
      builder: (context, state) {
        return _buildBody(state, context);
      },
    );
  }

  Widget _buildBody(ItemsManagerState state, BuildContext context) {
    if (state is ItemsLoading) return buildLoadingView(context);
    if (state is LoadItemsFailed) buildErrorView(context);
    return buildBodyContent(context);
  }

  Widget buildErrorView(BuildContext context) {
    return errorWidget?.call(context) ??
        Center(
          child: Text('Failed to load items'),
        );
  }

  Widget buildLoadingView(BuildContext context) {
    return loadingWidget?.call(context) ?? Center(
      child: SizedBox(
        child: CircularProgressIndicator(),
        width: 60,
        height: 60,
      ),
    );
  }

  Widget buildBodyContent(BuildContext context) {
    return bodyWidget?.call(context) ?? ItemsList<TBloc>();
  }
}
