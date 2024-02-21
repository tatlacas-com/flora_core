import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tatlacas_flutter_core/tatlacas_flutter_core.dart';

mixin ItemsSliversMixin<T extends StatefulWidget,
    TBloc extends ItemsManagerBloc> on State<T> {
  late TBloc bloc;

  final Map<int, GlobalKey<SliverAnimatedListState>> _sliverAnimatedListKeys =
      <int, GlobalKey<SliverAnimatedListState>>{};

  final Map<int, GlobalKey<AnimatedListState>> _animatedListKeys =
      <int, GlobalKey<AnimatedListState>>{};
  final Map<int, GlobalKey<SliverAnimatedGridState>> _animatedGridKeys =
      <int, GlobalKey<SliverAnimatedGridState>>{};

  bool useFixedCrossAxisCount(int section) => false;

  int fixedCrossAxisCount(int section) => 1;

  double maxCrossAxisExtent(int section) => 200;

  double childAspectRatio(int section) => 1;

  double crossAxisSpacing(int section) => 8;

  double mainAxisSpacing(int section) => 8;

  bool useAnimated(int section) => true;

  double horizontalHeight(int section) => throw Exception(
      'Provide height for this horizontal list section: $section');

  ScrollController? controllerFor(int section) => null;

  @protected
  SliverAnimatedListState? sliverAnimatedListState(int section) {
    if (_sliverAnimatedListKeys[section]?.currentState == null) {
      resetSliverAnimatedListKey(section);
    }
    return _sliverAnimatedListKeys[section]?.currentState;
  }

  @protected
  AnimatedListState? animatedListState(int section) {
    if (_animatedListKeys[section]?.currentState == null) {
      resetAnimatedListKey(section);
    }
    return _animatedListKeys[section]?.currentState;
  }

  @protected
  SliverAnimatedGridState? sliverAnimatedGridState(int section) {
    if (_animatedGridKeys[section]?.currentState == null) {
      resetAnimatedGridKey(section);
    }
    return _animatedGridKeys[section]?.currentState;
  }

  @protected
  void resetSliverAnimatedListKey(int section) {
    if (!useAnimated(section)) return;
    _sliverAnimatedListKeys[section] = GlobalKey<SliverAnimatedListState>();
  }

  @protected
  void resetAnimatedListKey(int section) {
    if (!useAnimated(section)) return;
    _animatedListKeys[section] = GlobalKey<AnimatedListState>();
  }

  @protected
  void resetAnimatedGridKey(int section) {
    if (!useAnimated(section)) return;
    _animatedGridKeys[section] = GlobalKey<SliverAnimatedGridState>();
  }

  Widget buildEmptySliver(BuildContext context) {
    return SliverList.list(
      children: [buildEmptyView(context)],
    );
  }

  List<Widget> buildLoadingFailedSlivers(
      BuildContext context, LoadItemsFailedState state) {
    return [
      SliverList.list(
        children: [buildLoadingFailedWidget(context, state)],
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
    return Center(
      child: ListView(
        shrinkWrap: true,
        children: const [
          Padding(
            padding: EdgeInsets.only(top: 24.0),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> buildLoadingSlivers(BuildContext context) {
    return [
      SliverList.list(
        children: [buildLoadingView(context)],
      )
    ];
  }

  List<Widget> buildSections(BuildContext context, ItemsManagerState state) {
    if (state is ItemsLoadingState ||
        state is ItemsInitialState ||
        state is! LoadedState) {
      return buildLoadingSlivers(context);
    }
    final List<Widget> sections = [];
    if (state.isNotEmpty) {
      for (int sectionIndex = 0;
          sectionIndex < state.totalSections;
          sectionIndex++) {
        sections.add(SliverToBoxAdapter(
          child: buildSectionHeader(
              sectionIndex, context, state.sectionHeader(sectionIndex)),
        ));
        addSectionSliver(sectionIndex, state, sections, context);
        sections.add(SliverToBoxAdapter(
          child: buildSectionFooter(
              sectionIndex, context, state.sectionFooter(sectionIndex)),
        ));
      }
    } else {
      sections.add(buildEmptySliver(context));
    }
    return sections;
  }

  void addSectionSliver(int sectionIndex, LoadedState state,
      List<Widget> sections, BuildContext context) {
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

  Widget buildEmptySectionSliver(
      BuildContext context, int sectionIndex, dynamic emptyEntity) {
    return SliverToBoxAdapter(
      child: buildSectionEmptyView(sectionIndex, context, emptyEntity),
    );
  }

  Widget buildSectionFooter(
      int section, BuildContext context, dynamic sectionFooter) {
    if (sectionFooter is Widgetable) {
      return sectionFooter.build(
          section: section,
          context: context,
          index: -1,
          onClick: () => onListHeaderClick(
                context: context,
                section: section,
                item: sectionFooter,
              ));
    }
    if (sectionFooter != null && !kReleaseMode) {
      throw ArgumentError(
          'unsupported list footer item $sectionFooter. Either override buildSectionFooter() in your UI or make item implement Widgetable');
    }
    return const SizedBox();
  }

  Widget buildSectionHeader(
      int section, BuildContext context, dynamic sectionHeader) {
    if (sectionHeader is Widgetable) {
      return sectionHeader.build(
          section: section,
          context: context,
          index: -1,
          onClick: () => onListHeaderClick(
                context: context,
                section: section,
                item: sectionHeader,
              ));
    }
    if (sectionHeader != null && !kReleaseMode) {
      throw ArgumentError(
          'unsupported list header item $sectionHeader. Either override buildSectionHeader() in your UI or make item implement Widgetable');
    }
    return const SizedBox();
  }

  Widget buildSectionEmptyView(
      int section, BuildContext context, dynamic emptyEntity) {
    if (emptyEntity is Widgetable) {
      return emptyEntity.build(
        section: section,
        context: context,
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
        height: horizontalHeight(section),
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
    return useAnimated(section)
        ? _buildVerticalSliverAnimatedGrid(section, sectionItems)
        : buildVerticalSliverGridDefault(section, sectionItems);
  }

  Widget buildHorizontalSliverList(int section, Section sectionItems) {
    return SliverToBoxAdapter(
      child: buildHorizontalSliverListContents(section, sectionItems),
    );
  }

  Widget buildHorizontalSliverListContents(int section, Section sectionItems) {
    return SizedBox(
      height: horizontalHeight(section),
      child: useAnimated(section)
          ? _buildHorizontalAnimatedList(section, sectionItems)
          : _buildHorizontalList(section, sectionItems),
    );
  }

  Widget buildVerticalSliverList(int section, Section sectionItems) {
    return useAnimated(section)
        ? _buildVerticalSliverAnimatedList(section, sectionItems)
        : buildVerticalSliverListDefault(section, sectionItems);
  }

  Widget _buildVerticalSliverAnimatedGrid(int section, Section sectionItems) {
    if (!_animatedGridKeys.containsKey(section) ||
        resetAnimatedKey(section, isGrid: true)) {
      _animatedGridKeys[section] = GlobalKey<SliverAnimatedGridState>();
    }
    return SliverAnimatedGrid(
      key: _animatedGridKeys[section],
      gridDelegate: _buildSliverGridDelegate(section),
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
          context: context,
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
    if (!_animatedListKeys.containsKey(section) ||
        resetAnimatedKey(
          section,
          horizontal: true,
        )) {
      _animatedListKeys[section] = GlobalKey<AnimatedListState>();
    }
    return AnimatedList(
      key: _animatedListKeys[section],
      controller: controllerFor(section),
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

  bool resetAnimatedKey(int section,
      {bool isGrid = false, bool horizontal = false}) {
    if (isGrid) {
      return _animatedGridKeys[section]?.currentState == null;
    }

    return horizontal
        ? _animatedListKeys[section]?.currentState == null
        : _sliverAnimatedListKeys[section]?.currentState == null;
  }

  Widget _buildVerticalSliverAnimatedList(int section, Section sectionItems) {
    if (!_sliverAnimatedListKeys.containsKey(section) ||
        resetAnimatedKey(section)) {
      _sliverAnimatedListKeys[section] = GlobalKey<SliverAnimatedListState>();
    }
    return SliverAnimatedList(
      key: _sliverAnimatedListKeys[section],
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

  void replaceItem(ItemReplacedState state) {
    removeItem(
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
    insertItem(
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

  void removeItem(
    ItemRemovedState state, {
    bool isReplace = false,
  }) {
    removeListItem(
      state: state,
      isReplace: isReplace,
    );
  }

  void insertItem(
    ItemInsertedState state, {
    bool isReplace = false,
    bool animated = false,
  }) {
    insertListItem(
      state: state,
      isReplace: isReplace,
      animated: animated,
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
    if (state.sections[state.itemSection].usesGrid) {
      final animState = sliverAnimatedGridState(state.itemSection);
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
    } else if (state.sections[state.itemSection].horizontalScroll) {
      final animState = animatedListState(state.itemSection);
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
    } else {
      final animState = sliverAnimatedListState(state.itemSection);
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
  }

  void insertListItem({
    required ItemInsertedState state,
    required bool isReplace,
    Duration duration = const Duration(milliseconds: 300),
    bool animDurationZeroOnReplace = true,
    bool animated = false,
  }) {
    if (state.sections[state.itemSection].usesGrid) {
      final animState = sliverAnimatedGridState(state.itemSection);
      if (animState == null) {
        debugPrint(
            'Tried to access null animateListState for section ${state.itemSection} ${state.itemIndex} in insertListItem');
      }
      animState?.insertItem(state.itemIndex,
          duration: !animated || (isReplace && animDurationZeroOnReplace)
              ? Duration.zero
              : duration);
    } else if (state.sections[state.itemSection].horizontalScroll) {
      final animState = animatedListState(state.itemSection);
      if (animState == null) {
        debugPrint(
            'Tried to access null animateListState for section ${state.itemSection} ${state.itemIndex} in insertListItem');
      }
      animState?.insertItem(state.itemIndex,
          duration: !animated || (isReplace && animDurationZeroOnReplace)
              ? Duration.zero
              : duration);
    } else {
      final animState = sliverAnimatedListState(state.itemSection);
      if (animState == null) {
        debugPrint(
            'Tried to access null animateListState for section ${state.itemSection} ${state.itemIndex} in insertListItem');
      }
      animState?.insertItem(state.itemIndex,
          duration: !animated || (isReplace && animDurationZeroOnReplace)
              ? Duration.zero
              : duration);
    }
  }

  Widget buildEmptyView(BuildContext context) {
    return const Center(
      child: Text('Empty View'),
    );
  }
}
