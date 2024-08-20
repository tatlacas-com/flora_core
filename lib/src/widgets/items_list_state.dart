import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flora_core/flora_core.dart';

class ItemsListState<TBloc extends ItemsManagerBloc>
    extends State<ItemsList<TBloc>>
    with
        AutomaticKeepAliveClientMixin,
        ItemsSliversMixin<ItemsList<TBloc>, TBloc> {
  ItemsListState({
    ScrollController? scrollController,
    bool needsScrollController = true,
    this.scrollPhysics,
  }) : assert(scrollController == null || needsScrollController) {
    if (scrollController == null && needsScrollController) {
      this.scrollController = ScrollController();
    } else {
      this.scrollController = scrollController;
    }
  }

  double get reloadThresholdPixels => 250;

  bool get pullToRefresh => true;
  bool get canLoadMoreItems => true;
  bool get canLoadMoreItemsHorizontal => false;

  bool get floatHeaderSlivers => false;

  late final ScrollController? scrollController;
  ScrollController get primaryScrollController => scrollController!;
  final ScrollPhysics? scrollPhysics;

  ScrollDirection get scrollDirection =>
      primaryScrollController.position.userScrollDirection;

  bool get buildSliversInSliverOverlapInjector => false;

  @protected
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    bloc = context.read<TBloc>();
    scrollBloc = context.read<ScrollNotificationBloc>();
  }

  void checkLoadFirstTime(BuildContext context) {
    if (bloc.state is ItemsInitialState) {
      bloc.add(LoadItemsEvent());
    }
  }

  @mustCallSuper
  @override
  Widget build(BuildContext context) {
    super.build(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkLoadFirstTime(context);
    });
    return _buildScrollViewWithListeners(context);
  }

  List<BlocListener> blocListeners(BuildContext context) => [];

  Widget _buildScrollView(BuildContext context) {
    return BlocListener<ScrollNotificationBloc, ScrollNotificationState>(
      listener: (context, state) {
        if (!scrolling && state is ScrolledNotificationState) {
          scrolling = true;
        }
        if (scrolling && state is PostScrolledNotificationState) {
          scrolling = false;
        }
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          scrollBloc.add(ScrolledEvent(scrollInfo: scrollInfo));
          scrollBloc.add(PostScrolledEvent(scrollInfo: scrollInfo));
          onScrollNotification(context, scrollInfo);
          return true;
        },
        child: pullToRefresh
            ? RefreshIndicator(
                key: refreshIndicatorKey,
                onRefresh: () => onRefreshIndicatorRefresh(context),
                child: _buildCustomScrollView(context),
              )
            : _buildCustomScrollView(context),
      ),
    );
  }

  Future onRefreshIndicatorRefresh(BuildContext context) async {
    final reloading = bloc.stream
        .where((state) =>
            !(state is ReloadingItemsState || state is ItemsLoadingState))
        .first;
    bloc.add(ReloadItemsEvent());
    await reloading;
  }

  Widget _buildScrollViewWithListeners(BuildContext context) {
    final listeners = blocListeners(context);
    if (listeners.isNotEmpty) {
      return MultiBlocListener(
        listeners: listeners,
        child: _buildScrollView(context),
      );
    } else {
      return _buildScrollView(context);
    }
  }

  Widget _buildCustomScrollView(BuildContext context) {
    return BlocConsumer<TBloc, ItemsManagerState>(
      listener: (context, state) {
        if (state is ItemRemovedState) {
          removeListItem(state);
        } else if (state is ItemInsertedState) {
          insertListItem(state);
        } else if (state is ItemReplacedState) {
          replaceItem(state);
        }
      },
      listenWhen: (prev, next) => next is ItemChangedState,
      buildWhen: (prev, next) => next is ItemsBuildUi,
      builder: (context, state) {
        return buildOnStateChanged(context, state);
      },
    );
  }

  Widget buildOnStateChanged(
    BuildContext context,
    ItemsManagerState state,
  ) {
    if (state is LoadItemsFailedState) {
      return _buildLoadingFailed(state, context);
    }
    if (state is ItemsLoadingState ||
        state is ItemsInitialState ||
        state is ItemsRetrievedState ||
        state is LoadedState) {
      return buildItemsRetrievedScrollView(context, state);
    }
    throw ArgumentError('buildOnStateChanged Not supported state $state');
  }

  void onScrollNotification(
      BuildContext context, ScrollNotification scrollInfo) {
    if (scrollInfo.metrics.axisDirection == AxisDirection.left ||
        scrollInfo.metrics.axisDirection == AxisDirection.right) {
      if (!canLoadMoreItemsHorizontal) {
        return;
      }
    } else if (!canLoadMoreItems) {
      return;
    }
    var diff = scrollInfo.metrics.maxScrollExtent - scrollInfo.metrics.pixels;
    if (diff < reloadThresholdPixels) {
      bloc.add(LoadMoreItemsEvent());
    }
  }

  Widget buildItemsRetrievedScrollView(
      BuildContext context, ItemsManagerState state) {
    var withInjector = widget.buildSliversInSliverOverlapInjector ||
        buildSliversInSliverOverlapInjector;
    final key = '${runtimeType}Items';
    return CustomScrollView(
      key: PageStorageKey<String>(key),
      physics: scrollPhysics ??
          const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      controller: scrollController,
      //needed for RefreshIndicator to work
      slivers: withInjector
          ? buildSectionsWithOverlapInjector(context, state)
          : buildSections(context, state),
    );
  }

  Widget _buildLoadingFailed(LoadItemsFailedState state, BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      key: PageStorageKey<String>(runtimeType.toString()),
      slivers: buildLoadingFailedSlivers(context, state),
    );
  }

  List<Widget> buildSectionsWithOverlapInjector(
      BuildContext context, ItemsManagerState state) {
    return [
      SliverOverlapInjector(
        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
      ),
      ...buildSections(context, state)
    ];
  }

  @override
  List<Widget> buildAppBarSlivers(BuildContext context) {
    return [];
  }

  @override
  void dispose() {
    scrollController?.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
