// ignore_for_file: dangling_library_doc_comments, sized_box_for_whitespace

/// Pull-to-refresh wrapper widget
/// 
/// Provides consistent pull-to-refresh functionality across the app.
/// 
/// Example:
/// ```dart
/// PullToRefreshWrapper(
///   onRefresh: () async {
///     await loadData();
///   },
///   child: ListView(
///     children: items,
///   ),
/// )
/// ```
library;

import 'package:flutter/material.dart' as material;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../utils/haptic_helper.dart';

/// Pull-to-refresh wrapper widget
class PullToRefreshWrapper extends material.StatefulWidget {
  final material.Widget child;
  final Future<void> Function() onRefresh;
  final material.VoidCallback? onLoading;
  final bool enablePullDown;
  final bool enablePullUp;

  const PullToRefreshWrapper({
    super.key,
    required this.child,
    required this.onRefresh,
    this.onLoading,
    this.enablePullDown = true,
    this.enablePullUp = false,
  });

  @override
  material.State<PullToRefreshWrapper> createState() => _PullToRefreshWrapperState();
}

class _PullToRefreshWrapperState extends material.State<PullToRefreshWrapper> {
  final RefreshController _refreshController = RefreshController();

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    HapticHelper.lightImpact();
    try {
      await widget.onRefresh();
      _refreshController.refreshCompleted();
    } catch (e) {
      _refreshController.refreshFailed();
    }
  }

  void _onLoading() {
    widget.onLoading?.call();
    _refreshController.loadComplete();
  }

  @override
  material.Widget build(material.BuildContext context) {
    return SmartRefresher(
      controller: _refreshController,
      enablePullDown: widget.enablePullDown,
      enablePullUp: widget.enablePullUp,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      header: CustomHeader(
        builder: (context, mode) {
          return material.Container(
            height: 60,
            child: material.Center(
              child: _buildRefreshIndicator(mode),
            ),
          );
        },
      ),
      footer: CustomFooter(
        builder: (context, mode) {
          return material.Container(
            height: 60,
            child: material.Center(
              child: _buildLoadMoreIndicator(mode),
            ),
          );
        },
      ),
      child: widget.child,
    );
  }

  material.Widget _buildRefreshIndicator(RefreshStatus? mode) {
    switch (mode) {
      case RefreshStatus.idle:
        return const material.Icon(material.Icons.arrow_downward, color: material.Colors.grey);
      case RefreshStatus.canRefresh:
        return const material.Icon(material.Icons.refresh, color: material.Colors.green);
      case RefreshStatus.refreshing:
        return const material.CircularProgressIndicator();
      case RefreshStatus.completed:
        return const material.Icon(material.Icons.check_circle, color: material.Colors.green);
      case RefreshStatus.failed:
        return const material.Icon(material.Icons.error, color: material.Colors.red);
      default:
        return const material.SizedBox.shrink();
    }
  }

  material.Widget _buildLoadMoreIndicator(LoadStatus? mode) {
    switch (mode) {
      case LoadStatus.idle:
        return const material.Icon(material.Icons.arrow_upward, color: material.Colors.grey);
      case LoadStatus.canLoading:
        return const material.Icon(material.Icons.more_horiz, color: material.Colors.green);
      case LoadStatus.loading:
        return const material.CircularProgressIndicator();
      case LoadStatus.noMore:
        return const material.Text('No more data', style: material.TextStyle(color: material.Colors.grey));
      case LoadStatus.failed:
        return const material.Icon(material.Icons.error, color: material.Colors.red);
      default:
        return const material.SizedBox.shrink();
    }
  }
}

/// Simple refresh indicator wrapper (iOS style)
class SimpleRefreshWrapper extends material.StatelessWidget {
  final material.Widget child;
  final Future<void> Function() onRefresh;

  const SimpleRefreshWrapper({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  material.Widget build(material.BuildContext context) {
    return material.RefreshIndicator(
      onRefresh: onRefresh,
      child: child,
    );
  }
}
