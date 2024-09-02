import 'package:example/test_items_bloc.dart';
import 'package:flora_core/flora_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class AnimtedSwitchView extends StatelessWidget {
  const AnimtedSwitchView(
      {super.key,
      required this.child,
      this.duration,
      required this.switcherKey});
  final Widget child;
  final Duration? duration;
  final Key switcherKey;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, animation) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: const Offset(0.0, 0.0),
        ).animate(animation),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
      child: KeyedSubtree(
        key: switcherKey,
        child: child,
      ),
    );
  }
}

class TestItemsPage extends ItemsListState<TestItemsBloc> {
  bool _goingUp = false;

  @override
  List<Widget> buildAppBarSlivers(BuildContext context) {
    return [
      const SliverAppBar(
        floating: true,
        titleSpacing: 0,
        title: Text('Test App'),
        centerTitle: true,
      ),
    ];
  }

  @override
  Widget buildItemsRetrievedScrollView(
      BuildContext context, ItemsManagerState state) {
    return AnimtedSwitchView(
      switcherKey: ValueKey(state.runtimeType),
      child: super.buildItemsRetrievedScrollView(context, state),
    );
  }

  @override
  void onScrollNotification(
      BuildContext context, ScrollNotification scrollInfo) {
    super.onScrollNotification(context, scrollInfo);
    setState(() {
      _goingUp = (scrollDirection == ScrollDirection.forward ||
              _goingUp && scrollDirection == ScrollDirection.idle) &&
          primaryScrollController.position.pixels > 50;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: super.build(context),
      floatingActionButton: _goingUp
          ? FloatingActionButton.small(
              heroTag: 'new',
              onPressed: () {
                _scrollToTop();
              },
              child: const Icon(Icons.arrow_upward),
            )
          : null,
    );
  }

  @override
  Widget buildItem({
    required BuildContext context,
    required int section,
    required int index,
    required item,
    Animation<double>? animation,
    bool isReplace = false,
    bool isRemoved = false,
  }) {
    if (item is int) {
      return ListTile(
        title: Text('Item $item'),
      );
    }
    return super.buildItem(
      context: context,
      section: section,
      index: index,
      item: item,
      animation: animation,
      isReplace: isReplace,
      isRemoved: isRemoved,
    );
  }

  void _scrollToTop() {
    debugPrint('#### CURR OFFSET: ${primaryScrollController.position.pixels}');
    var i = 0;
    for (final pos in primaryScrollController.positions) {
      debugPrint('#### CURR OFFSET ${i++}: ${pos.pixels}');
    }
    if (primaryScrollController.position.pixels < 2100) {
      primaryScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
      return;
    }
  }
}
