import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tatlacas_flutter_core/tatlacas_flutter_core.dart';

class ItemsList<TBloc extends ItemsManagerBloc> extends StatefulWidget {
 final ItemsListState<TBloc> Function()? onCreateState;
  const ItemsList({Key? key,this.onCreateState}) : super(key: key);

  bool get buildSliversInSliverOverlapInjector => false;

  bool get useFixedCrossAxisCount => false;

  int get fixedCrossAxisCount => 1;

  double get maxCrossAxisExtent => 200;

  double get childAspectRatio => 1;

  double get crossAxisSpacing => 16;

  double get mainAxisSpacing => 16;

  @override
  ItemsListState<TBloc> createState() => onCreateState?.call() ?? ItemsListState<TBloc>();
}

class ItemsListState<TBloc extends ItemsManagerBloc>
    extends State<ItemsList<TBloc>> with AutomaticKeepAliveClientMixin {
  late TBloc bloc;

  final Map<int, GlobalKey<SliverAnimatedListState>> _animatedListKeys =
      Map<int, GlobalKey<SliverAnimatedListState>>();

  @protected
  SliverAnimatedListState _animatedList(int section) =>
      _animatedListKeys[section]!.currentState!;

  @protected
  void resetAnimatedListKey(dynamic section) {
    assert(section is int);
    if (!useAnimatedList(section)) return;
    _animatedListKeys[section] = new GlobalKey<SliverAnimatedListState>();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    bloc = context.read<TBloc>();
    var content = widget.buildSliversInSliverOverlapInjector
        ? buildSectionsWithOverlapInjector(context)
        : buildSections(context);
    return RefreshIndicator(
      onRefresh: () async {
        bloc.add(ReloadItemsRequested());
      },
      child: CustomScrollView(
        key: PageStorageKey<String>(TBloc.runtimeType.toString()),
        slivers: content,
      ),
    );
  }

  bool useAnimatedList(int section) => false;

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

  List<Widget> buildSections(BuildContext context) {
    final List<Widget> sections = [];
    if (bloc.isNotEmpty) {
      for (int sectionIndex = 0;
          sectionIndex < bloc.totalSections;
          sectionIndex++) {
        if (bloc.sectionHeader(sectionIndex) != null) {
          sections.add(buildSectionHeader(
              sectionIndex, context, bloc.sectionHeader(sectionIndex)));
        }
        double marginBottom = sectionIndex == bloc.totalSections - 1 ? 80 : 0;
        sections.add(
          bloc.usesGrid(sectionIndex)
              ? sectionSliverGrid(sectionIndex, context,
                  bloc.section(sectionIndex), marginBottom)
              : sectionSliverList(sectionIndex, context,
                  bloc.section(sectionIndex), marginBottom),
        );
      }
    } else {
      sections.add(SliverPadding(
        padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
        sliver: SliverFillRemaining(
          hasScrollBody: false,
          child: buildEmptyView(),
        ),
      ));
    }
    return sections;
  }

  Widget buildSectionHeader(
      int section, BuildContext context, dynamic sectionHeader) {
    return SliverToBoxAdapter(
      child: Text('Build section header'),
    );
  }

  Widget sectionSliverGrid(int sectionIndex, BuildContext context,
      Section section, double marginBottom) {
    return section.horizontalScroll
        ? buildHorizontalSliverGrid(sectionIndex, section)
        : buildVerticalSliverGrid(sectionIndex, section);
  }

  Widget buildHorizontalSliverGrid(int section, Section sectionItems) {
    return SliverToBoxAdapter(
      child: Container(
        height: sectionItems.horizontalScrollHeight,
        child: GridView.builder(
          gridDelegate: _buildSliverGridDelegate(),
          itemBuilder: (context, index) {
            return Text('Content here');
          },
          itemCount: sectionItems.totalItems(),
          scrollDirection: Axis.horizontal,
        ),
      ),
    );
  }

  SliverGridDelegate _buildSliverGridDelegate() {
    return widget.useFixedCrossAxisCount
        ? SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.fixedCrossAxisCount,
            childAspectRatio: widget.childAspectRatio,
            crossAxisSpacing: widget.crossAxisSpacing,
            mainAxisSpacing: widget.mainAxisSpacing,
          )
        : SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: widget.maxCrossAxisExtent,
            childAspectRatio: widget.childAspectRatio,
            crossAxisSpacing: widget.crossAxisSpacing,
            mainAxisSpacing: widget.mainAxisSpacing,
          );
  }

  SliverGrid buildVerticalSliverGrid(int section, Section sectionItems) {
    return SliverGrid(
      key: Key("${section}sectionSliverGrid"),
      gridDelegate: _buildSliverGridDelegate(),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Text('Content here again');
        },
        childCount: sectionItems.totalItems(),
      ),
    );
  }

  Widget sectionSliverList(int section, BuildContext context,
      Section sectionItems, double marginBottom) {
    return sectionItems.horizontalScroll
        ? buildHorizontalSliverList(section, sectionItems)
        : buildVerticalSliverList(section, sectionItems);
  }

  Widget buildHorizontalSliverList(int section, Section sectionItems) {
    return SliverToBoxAdapter(
      child: Container(
        height: sectionItems.horizontalScrollHeight,
        child: useAnimatedList(section)
            ? _buildHorizontalAnimatedList(section, sectionItems)
            : _buildHorizontalList(section, sectionItems),
      ),
    );
  }

  ListView _buildHorizontalList(int section, Section sectionItems) {
    return ListView.builder(
      itemBuilder: (context, index) {
        var item = sectionItems.items[index];
        return buildHorizontalListItem(
          context: context,
          item: item,
          section: section,
          row: index,
        );
      },
      itemCount: sectionItems.totalItems(),
      scrollDirection: Axis.horizontal,
    );
  }

  Widget buildHorizontalListItem({
    required BuildContext context,
    required item,
    required int section,
    required int row,
  }) {
    return Text('buildHorizontalListItem');
  }

  AnimatedList _buildHorizontalAnimatedList(int section, Section sectionItems) {
    if (!_animatedListKeys.containsKey(section)) {
      _animatedListKeys[section] = GlobalKey<SliverAnimatedListState>();
    }
    return AnimatedList(
      key: _animatedListKeys[section],
      itemBuilder:
          (BuildContext context, int index, Animation<double> animation) =>
              buildDefaultListItem(context, index, animation, sectionItems),
      initialItemCount: sectionItems.totalItems(),
      scrollDirection: Axis.horizontal,
    );
  }

  Widget buildVerticalSliverList(int section, Section sectionItems) {
    return useAnimatedList(section)
        ? _buildVerticalSliverAnimatedList(section, sectionItems)
        : buildVerticalSliverListDefault(section, sectionItems);
  }

  Widget buildVerticalSliverListDefault(int section, Section sectionItems) {
    return SliverList(
      key: ValueKey('${section}sectionSliverList'),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          var item = sectionItems.items[index];
          return buildVerticalSliverListItem(
            context: context,
            item: item,
            section: section,
            row: index,
          );
        },
        childCount: sectionItems.totalItems(),
      ),
    );
  }

  Widget buildVerticalSliverListItem({
    required BuildContext context,
    required dynamic item,
    required int section,
    required int row,
  }) {
    return Text('buildVerticalSliverListItem');
  }

  Widget _buildVerticalSliverAnimatedList(int section, Section sectionItems) {
    if (!_animatedListKeys.containsKey(section)) {
      _animatedListKeys[section] = GlobalKey<SliverAnimatedListState>();
    }
    return SliverAnimatedList(
      key: _animatedListKeys[section],
      itemBuilder:
          (BuildContext context, int index, Animation<double> animation) =>
              buildDefaultListItem(context, index, animation, sectionItems),
      initialItemCount: sectionItems.totalItems(),
    );
  }

  @protected
  Widget buildDefaultListItem(BuildContext context, int index,
      Animation<double> animation, Section sectionItems) {
    final item = sectionItems.items[index];
    return Text('buildDefaultListItem');
  }

  @protected
  Widget buildRemovedListItem(dynamic item, int row, BuildContext context,
      Animation<double> animation) {
    return Text('buildRemovedListItem');
  }

  void removeListItem(
    dynamic removedItem, {
    required int section,
    required int row,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    removeListItemAnimated(
      animatedList: _animatedList(section),
      removedItem: removedItem,
      row: row,
      duration: duration,
    );
  }

  void insertListItem(
    dynamic removedItem, {
    required int section,
    required int row,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    insertListItemAnimated(
      animatedList: _animatedList(section),
      removedItem: removedItem,
      row: row,
      duration: duration,
    );
  }

  void removeListItemAnimated({
    required SliverAnimatedListState animatedList,
    required dynamic removedItem,
    required int row,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    animatedList.removeItem(
      row,
      (context, animation) =>
          buildRemovedListItem(removedItem, row, context, animation),
      duration: duration,
    );
  }

  void insertListItemAnimated({
    required SliverAnimatedListState animatedList,
    required dynamic removedItem,
    required int row,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    animatedList.insertItem(row, duration: duration);
  }

  Widget buildEmptyView({String? emptyMessage}) {
    return Center(child: Text('Empty View'));
  }

  @override
  bool get wantKeepAlive => true;
}
