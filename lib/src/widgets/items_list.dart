import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tatlacas_flutter_core/tatlacas_flutter_core.dart';

/// {@template itemsList}
/// A base class for showing list or grid of widgets on ui. For sample see [ItemsManagerBloc]
/// {@endtemplate}
class ItemsList<TBloc extends ItemsManagerBloc> extends StatefulWidget {
  const ItemsList({
    super.key,
    this.stateBuilder,
    this.buildSliversInSliverOverlapInjector = false,
  });
  final ItemsListState<TBloc> Function()? stateBuilder;

  final bool buildSliversInSliverOverlapInjector;

  @override
  ItemsListState<TBloc> createState() =>
      // ignore: no_logic_in_create_state
      stateBuilder?.call() ?? ItemsListState<TBloc>();
}

class ItemsListState<TBloc extends ItemsManagerBloc>
    extends State<ItemsList<TBloc>> with AutomaticKeepAliveClientMixin {
  ItemsListState({ScrollController? scrollController}) {
    this.scrollController = scrollController ?? ScrollController();
  }
  late TBloc bloc;

  double get reloadThresholdPixels => 250;

  bool get pullToRefresh => true;

  bool get floatHeaderSlivers => false;

  bool get useNestedScrollView => true;

  late final ScrollController scrollController;

  bool get buildSliversInSliverOverlapInjector => false;

  bool useFixedCrossAxisCount(int section) => false;

  int fixedCrossAxisCount(int section) => 1;

  double maxCrossAxisExtent(int section) => 200;

  double childAspectRatio(int section) => 1;

  double crossAxisSpacing(int section) => 8;

  double mainAxisSpacing(int section) => 8;

  final Map<int, GlobalKey<SliverAnimatedListState>> _animatedListKeys =
      <int, GlobalKey<SliverAnimatedListState>>{};

  @protected
  SliverAnimatedListState? _animatedList(int section) {
    if (_animatedListKeys[section]?.currentState == null) {
      resetAnimatedListKey(section);
    }
    return _animatedListKeys[section]?.currentState;
  }

  @protected
  void resetAnimatedListKey(int section) {
    if (!useAnimatedList(section)) return;
    _animatedListKeys[section] = GlobalKey<SliverAnimatedListState>();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    bloc = context.read<TBloc>();
    return useNestedScrollView
        ? NestedScrollView(
            controller: scrollController,
            floatHeaderSlivers: floatHeaderSlivers,
            headerSliverBuilder: (BuildContext cnxt, bool innerBoxIsScrolled) {
              return buildAppBarSlivers(context);
            },
            body: buildScrollViewWithListeners(context))
        : buildScrollViewWithListeners(context);
  }

  List<BlocListener> blocListeners(BuildContext context) => [];

  Widget buildScrollView(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        onScrollNotification(scrollInfo);
        return true;
      },
      child: pullToRefresh
          ? RefreshIndicator(
              onRefresh: onRefreshIndicatorRefresh,
              child: buildCustomScrollView(context),
            )
          : buildCustomScrollView(context),
    );
  }

  Future onRefreshIndicatorRefresh() async {
    bloc.add(ReloadItemsEvent());
  }

  Widget buildScrollViewWithListeners(BuildContext context) {
    final listeners = blocListeners(context);
    if (listeners.isNotEmpty) {
      return MultiBlocListener(
        listeners: listeners,
        child: buildScrollView(context),
      );
    } else {
      return buildScrollView(context);
    }
  }

  Widget buildCustomScrollView(BuildContext context) {
    return BlocConsumer<TBloc, ItemsManagerState>(
      listener: (context, state) {
        if (state is ItemRemovedState) {
          _removeItem(state);
        } else if (state is ItemInsertedState) {
          _insertItem(state);
        } else if (state is ItemReplacedState) {
          _removeItem(
            ItemRemovedState(
              itemSection: state.itemSection,
              changeParams: state.changeParams,
              reachedBottom: state.reachedBottom,
              itemIndex: state.itemIndex,
              removedItem: state.removedItem,
              sections: state.sections,
            ),
            isReplace: true,
          );
          _insertItem(
            ItemInsertedState(
              itemSection: state.itemSection,
              reachedBottom: state.reachedBottom,
              itemIndex: state.itemIndex,
              changeParams: state.changeParams,
              insertedItem: state.insertedItem,
              sections: state.sections,
            ),
            isReplace: true,
          );
        }
      },
      listenWhen: (prev, next) => next is ItemChangedState,
      buildWhen: (prev, next) => next is ItemsBuildUi,
      builder: (context, state) {
        return buildOnStateChanged(context, state);
      },
    );
  }

  void _removeItem(
    ItemRemovedState state, {
    bool isReplace = false,
  }) {
    if (state.sections[state.itemSection].usesGrid) {
      bloc.add(EmitRetrievedEvent());
      return;
    }
    removeListItem(
      state: state,
      isReplace: isReplace,
    );
  }

  void _insertItem(
    ItemInsertedState state, {
    bool isReplace = false,
  }) {
    if (state.sections[state.itemSection].usesGrid) {
      bloc.add(EmitRetrievedEvent());
      return;
    }
    insertListItem(
      state: state,
      isReplace: isReplace,
    );
  }

  Widget buildOnStateChanged(
    BuildContext context,
    ItemsManagerState state,
  ) {
    if (state is ItemsLoadingState || state is ItemsInitialState) {
      return buildLoadingView(context);
    }
    if (state is LoadItemsFailedState) {
      return _buildLoadingFailed(state, context);
    }
    if (state is ItemsRetrievedState || state is LoadedState) {
      return buildItemsRetrievedScrollView(context);
    }
    throw ArgumentError('buildOnStateChanged Not supported state $state');
  }

  @protected
  void onLoadItemsFailedState(LoadItemsFailedState state) {}

  void onScrollNotification(ScrollNotification scrollInfo) {
    var diff = scrollInfo.metrics.maxScrollExtent - scrollInfo.metrics.pixels;
    if (diff < reloadThresholdPixels) {
      bloc.add(LoadMoreItemsEvent());
    }
  }

  Widget buildItemsRetrievedScrollView(BuildContext context) {
    var withInjector = widget.buildSliversInSliverOverlapInjector ||
        buildSliversInSliverOverlapInjector;
    return CustomScrollView(
      key: PageStorageKey<String>('${TBloc.runtimeType}${bloc.itemsCount}'),
      physics:
          const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      controller: scrollController,
      //needed for RefreshIndicator to work
      slivers: withInjector
          ? buildSectionsWithOverlapInjector(context)
          : buildSections(context),
    );
  }

  Widget _buildLoadingFailed(LoadItemsFailedState state, BuildContext context) {
    onLoadItemsFailedState(state);
    return RefreshIndicator(
      onRefresh: onRefreshIndicatorRefresh,
      child: CustomScrollView(
        controller: scrollController,
        key: PageStorageKey<String>(TBloc.runtimeType.toString()),
        slivers: buildLoadingFailedSlivers(context, state),
      ),
    );
  }

  List<Widget> buildLoadingFailedSlivers(
      BuildContext context, LoadItemsFailedState state) {
    return [
      SliverPadding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        sliver: SliverFillRemaining(
          hasScrollBody: false,
          child: buildLoadingFailedWidget(context, state),
        ),
      )
    ];
  }

  Widget buildLoadingFailedWidget(
      BuildContext context, LoadItemsFailedState state) {
    return const Center(
      child: Text('Show Screen Failed to load items widget here...'),
    );
  }

  Widget buildLoadingView(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 60,
        height: 60,
        child: CircularProgressIndicator(),
      ),
    );
  }

  bool useAnimatedList(int section) => true;

  List<Widget> buildSectionsWithOverlapInjector(BuildContext context) {
    var sections = buildSections(context);
    List<Widget> widgets = [
      SliverOverlapInjector(
// This is the flip side of the SliverOverlapAbsorber
// above.
        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
      ),
    ];
    widgets.addAll(sections);
    return widgets;
  }

  List<Widget> buildAppBarSlivers(BuildContext context) {
    return [];
  }

  List<Widget> buildSections(BuildContext context) {
    final state = bloc.state as LoadedState;
    final List<Widget> sections = []; //buildAppBarSlivers(context);
    if (state.isNotEmpty) {
      for (int sectionIndex = 0;
          sectionIndex < state.totalSections;
          sectionIndex++) {
        if (state.sectionHeader(sectionIndex) != null) {
          sections.add(buildSectionHeaderSliver(
              sectionIndex, context, state.sectionHeader(sectionIndex)));
        }
        double marginBottom = sectionIndex == state.totalSections - 1 ? 80 : 0;
        if (state.section(sectionIndex).isEmpty) {
          sections.add(buildEmptySectionSliver(
              context, sectionIndex, state.section(sectionIndex).emptyEntity));
        } else {
          sections.add(
            state.usesGrid(sectionIndex)
                ? sectionSliverGrid(sectionIndex, context,
                    state.section(sectionIndex), marginBottom)
                : sectionSliverList(sectionIndex, context,
                    state.section(sectionIndex), marginBottom),
          );
        }
      }
    } else {
      sections.add(buildEmptySliver(context));
    }
    return sections;
  }

  Widget buildEmptySectionSliver(
      BuildContext context, int sectionIndex, dynamic emptyEntity) {
    return SliverPadding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      sliver: SliverToBoxAdapter(
        child: buildSectionEmptyView(sectionIndex, context, emptyEntity),
      ),
    );
  }

  Widget buildEmptySliver(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      sliver: SliverFillRemaining(
        hasScrollBody: false,
        child: buildEmptyView(context),
      ),
    );
  }

  Widget buildSectionHeaderSliver(
      int section, BuildContext context, dynamic sectionHeader) {
    return SliverToBoxAdapter(
      child: buildSectionHeader(section, context, sectionHeader),
    );
  }

  Widget buildSectionHeader(
      int section, BuildContext context, dynamic sectionHeader) {
    if (sectionHeader is Widgetable) {
      return sectionHeader.build(
          section: section,
          index: -1,
          onClick: () => onListHeaderClick(
                context: context,
                section: section,
                item: sectionHeader,
              ));
    }
    throw ArgumentError(
        'unsupported list header item $sectionHeader. Either override buildSectionHeader() in your UI or make item implement Widgetable');
  }

  Widget buildSectionEmptyView(
      int section, BuildContext context, dynamic emptyEntity) {
    if (emptyEntity is Widgetable) {
      return emptyEntity.build(
        section: section,
        index: -1,
      );
    } else if (emptyEntity is SizedBox) {
      return emptyEntity;
    }
    return buildEmptyView(context);
  }

  Widget sectionSliverGrid(int sectionIndex, BuildContext context,
      Section section, double marginBottom) {
    return section.horizontalScroll
        ? buildHorizontalSliverGrid(sectionIndex, section)
        : buildVerticalSliverGrid(sectionIndex, section);
  }

  Widget sectionSliverList(int section, BuildContext context,
      Section sectionItems, double marginBottom) {
    return sectionItems.horizontalScroll
        ? buildHorizontalSliverList(section, sectionItems)
        : buildVerticalSliverList(section, sectionItems);
  }

  Widget buildHorizontalSliverGrid(int section, Section sectionItems) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: sectionItems.horizontalScrollHeight,
        child: GridView.builder(
          gridDelegate: _buildSliverGridDelegate(section),
          itemBuilder: (context, index) {
            return buildListItem(
              context: context,
              section: section,
              index: index,
              item: sectionItems.items[index],
            );
          },
          itemCount: sectionItems.totalItems(),
          scrollDirection: Axis.horizontal,
        ),
      ),
    );
  }

  Widget buildVerticalSliverGrid(int section, Section sectionItems) {
    return buildVerticalSliverGridDefault(section, sectionItems);
  }

  Widget buildHorizontalSliverList(int section, Section sectionItems) {
    return SliverToBoxAdapter(
      child: buildHorizontalSliverListContents(section, sectionItems),
    );
  }

  Widget buildHorizontalSliverListContents(int section, Section sectionItems) {
    return SizedBox(
      height: sectionItems.horizontalScrollHeight,
      child: useAnimatedList(section)
          ? _buildHorizontalAnimatedList(section, sectionItems)
          : _buildHorizontalList(section, sectionItems),
    );
  }

  Widget buildVerticalSliverList(int section, Section sectionItems) {
    return useAnimatedList(section)
        ? _buildVerticalSliverAnimatedList(section, sectionItems)
        : buildVerticalSliverListDefault(section, sectionItems);
  }

  SliverGrid buildVerticalSliverGridDefault(int section, Section sectionItems) {
    return SliverGrid(
      key: Key('${section}sectionSliverGrid'),
      gridDelegate: _buildSliverGridDelegate(section),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return buildListItem(
            context: context,
            section: section,
            index: index,
            item: sectionItems.items[index],
          );
        },
        childCount: sectionItems.totalItems(),
      ),
    );
  }

  Widget buildListItem({
    required BuildContext context,
    required int section,
    required int index,
    required dynamic item,
    Animation<double>? animation,
    bool isReplace = false,
    bool isRemoved = false,
  }) {
    if (item is Widgetable) {
      return item.build(
          section: section,
          index: index,
          animation: animation,
          onClick: () => onListItemClick(
                context: context,
                item: item,
                section: section,
                index: index,
              ));
    }
    throw ArgumentError('unsupported list item $item');
  }

  FutureOr<void> onListItemClick({
    required BuildContext context,
    required dynamic item,
    required int section,
    required int index,
  }) {
    if (kDebugMode) print('List item clicked. Remember to handle this..');
  }

  FutureOr<void> onListHeaderClick({
    required BuildContext context,
    required int section,
    required dynamic item,
  }) {
    if (kDebugMode) print('Header item clicked. Remember to handle this..');
  }

  SliverGridDelegate _buildSliverGridDelegate(int section) {
    return useFixedCrossAxisCount(section)
        ? SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: fixedCrossAxisCount(section),
            childAspectRatio: childAspectRatio(section),
            crossAxisSpacing: crossAxisSpacing(section),
            mainAxisSpacing: mainAxisSpacing(section),
          )
        : SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: maxCrossAxisExtent(section),
            childAspectRatio: childAspectRatio(section),
            crossAxisSpacing: crossAxisSpacing(section),
            mainAxisSpacing: mainAxisSpacing(section),
          );
  }

  ListView _buildHorizontalList(int section, Section sectionItems) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return buildListItem(
          context: context,
          section: section,
          index: index,
          item: sectionItems.items[index],
        );
      },
      itemCount: sectionItems.totalItems(),
      scrollDirection: Axis.horizontal,
    );
  }

  Widget _buildHorizontalAnimatedList(int section, Section sectionItems) {
    if (!_animatedListKeys.containsKey(section) || resetAnimatedKey(section)) {
      _animatedListKeys[section] = GlobalKey<SliverAnimatedListState>();
    }
    return AnimatedList(
      key: _animatedListKeys[section],
      itemBuilder:
          (BuildContext context, int index, Animation<double> animation) =>
              buildAnimatedListItem(
                  context: context,
                  index: index,
                  animation: animation,
                  section: section,
                  item: sectionItems.items[index]),
      initialItemCount: sectionItems.totalItems(),
      scrollDirection: Axis.horizontal,
    );
  }

  Widget buildVerticalSliverListDefault(int section, Section sectionItems) {
    return SliverList(
      key: ValueKey('${section}sectionSliverList'),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return buildListItem(
            context: context,
            section: section,
            index: index,
            item: sectionItems.items[index],
          );
        },
        childCount: sectionItems.totalItems(),
      ),
    );
  }

  bool resetAnimatedKey(int section) =>
      _animatedListKeys[section]?.currentState == null;

  Widget _buildVerticalSliverAnimatedList(int section, Section sectionItems) {
    if (!_animatedListKeys.containsKey(section) || resetAnimatedKey(section)) {
      _animatedListKeys[section] = GlobalKey<SliverAnimatedListState>();
    }
    return SliverAnimatedList(
      key: _animatedListKeys[section],
      itemBuilder:
          (BuildContext context, int index, Animation<double> animation) {
        try {
          return buildAnimatedListItem(
              context: context,
              index: index,
              animation: animation,
              section: section,
              item: sectionItems.items[index]);
        } catch (e) {
          debugPrint(
              'Error building section: $section index:$index totalItemsInSection: ${sectionItems.totalItems()}/${sectionItems.items.length} -- $e');
        }
        return const SizedBox();
      },
      initialItemCount: sectionItems.totalItems(),
    );
  }

  @protected
  Widget buildAnimatedListItem({
    required BuildContext context,
    required int index,
    required Animation<double> animation,
    required int section,
    required dynamic item,
  }) {
    final isReplace =
        bloc.isReplacingItem(section: section, index: index, item: item);
    if (isReplace) {
      return buildAnimatedReplaceListItem(
        context: context,
        state: bloc.state as ItemReplacedState,
        animation: animation,
      );
    }
    return FadeTransition(
      opacity: Tween<double>(
        begin: 0,
        end: 1,
      ).animate(animation),
      child: buildListItem(
        context: context,
        section: section,
        index: index,
        animation: animation,
        item: item,
      ),
    );
  }

  @protected
  Widget buildAnimatedReplaceListItem({
    required BuildContext context,
    required Animation<double> animation,
    required ItemReplacedState state,
  }) {
    return buildListItem(
        context: context,
        section: state.itemSection,
        index: state.itemIndex,
        animation: animation,
        item: state.insertedItem,
        isReplace: true);
  }

  @protected
  Widget buildRemovedListItem(
      {required dynamic item,
      required int index,
      required int section,
      required BuildContext context,
      required Animation<double> animation,
      required bool isReplace}) {
    if (isReplace) {
      return buildListItem(
        context: context,
        section: section,
        index: index,
        animation: animation,
        item: item,
        isReplace: true,
        isRemoved: true,
      );
    }
    return buildAnimatedListItem(
        context: context,
        index: index,
        animation: animation,
        section: section,
        item: item);
  }

  void removeListItem({
    required ItemRemovedState state,
    Duration duration = const Duration(milliseconds: 300),
    bool isReplace = false,
    bool animDurationZeroOnReplace = true,
  }) {
    final animState = _animatedList(state.itemSection);
    if (animState == null) {
      debugPrint(
          'Tried to access null animateListState for section ${state.itemSection} ${state.itemIndex} in removeListItem');
    }
    animState?.removeItem(
      state.itemIndex,
      (context, animation) => buildRemovedListItem(
          item: state.removedItem,
          index: state.itemIndex,
          section: state.itemSection,
          context: context,
          animation: animation,
          isReplace: isReplace),
      duration:
          isReplace && animDurationZeroOnReplace ? Duration.zero : duration,
    );
  }

  void insertListItem({
    required ItemInsertedState state,
    required bool isReplace,
    Duration duration = const Duration(milliseconds: 300),
    bool animDurationZeroOnReplace = true,
  }) {
    final animState = _animatedList(state.itemSection);
    if (animState == null) {
      debugPrint(
          'Tried to access null animateListState for section ${state.itemSection} ${state.itemIndex} in insertListItem');
    }
    animState?.insertItem(state.itemIndex,
        duration:
            isReplace && animDurationZeroOnReplace ? Duration.zero : duration);
  }

  Widget buildEmptyView(BuildContext context) {
    return const Center(
      child: Text('Empty View'),
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
