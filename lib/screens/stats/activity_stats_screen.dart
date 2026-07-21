import 'dart:math' as math;

import 'package:client/l10n/app_localizations.dart';
import 'package:client/models/activity_stats.dart';
import 'package:client/services/activity_service.dart';
import 'package:client/ui/theme/app_theme.dart';
import 'package:client/ui/widgets/activity_presentation.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

enum _StatsMode { daily, weekly, events }

class ActivityStatsScreen extends StatefulWidget {
  const ActivityStatsScreen({super.key});

  @override
  State<ActivityStatsScreen> createState() => _ActivityStatsScreenState();
}

class _ActivityStatsScreenState extends State<ActivityStatsScreen> {
  final ActivityService _service = ActivityService();

  _StatsMode _mode = _StatsMode.daily;
  ActivityStats? _stats;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _isLoading = _stats == null;
      _error = null;
    });

    try {
      final stats = await _service.loadActivityStats();
      if (!mounted) return;
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.statsTitle),
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [_buildContent(context, l10n)],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations l10n) {
    final stats = _stats;

    if (_isLoading) {
      return const _StatusBox(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _StatusBox(
        child: _ErrorState(message: _error!, onRetry: _load),
      );
    }

    if (stats == null || stats.isEmpty) {
      return _StatusBox(child: _EmptyText(l10n.statsEmpty));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<_StatsMode>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(
              value: _StatsMode.daily,
              label: Text(l10n.statsDailyTab),
            ),
            ButtonSegment(
              value: _StatsMode.weekly,
              label: Text(l10n.statsWeeklyTab),
            ),
            ButtonSegment(
              value: _StatsMode.events,
              label: Text(l10n.statsEventsTab),
            ),
          ],
          selected: {_mode},
          onSelectionChanged: (selected) {
            setState(() => _mode = selected.first);
          },
        ),
        const SizedBox(height: 16),
        _StatsPanel(
          title: switch (_mode) {
            _StatsMode.daily => l10n.statsDailyTitle,
            _StatsMode.weekly => l10n.statsWeeklyTitle,
            _StatsMode.events => l10n.statsEventsTitle,
          },
          child: switch (_mode) {
            _StatsMode.daily =>
              stats.daily.isEmpty
                  ? _EmptyText(l10n.statsNoDaily)
                  : _DailyChart(points: stats.daily),
            _StatsMode.weekly =>
              stats.weekly.isEmpty
                  ? _EmptyText(l10n.statsNoWeekly)
                  : _WeeklyChart(points: stats.weekly),
            _StatsMode.events =>
              stats.events.isEmpty
                  ? _EmptyText(l10n.statsNoEvents)
                  : _EventChart(events: stats.events),
          },
        ),
      ],
    );
  }
}

class _StatsPanel extends StatelessWidget {
  const _StatsPanel({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.appPanelSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.appPanelBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(height: 260, child: child),
        ],
      ),
    );
  }
}

class _DailyChart extends StatelessWidget {
  const _DailyChart({required this.points});

  final List<ActivityStatPoint> points;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final maxY = _maxY(points.map((point) => point.xp));

    return BarChart(
      BarChartData(
        maxY: maxY,
        alignment: BarChartAlignment.spaceBetween,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: colors.appPanelBorder, strokeWidth: 1),
        ),
        titlesData: _axisTitles(
          context,
          points,
          leftInterval: _axisInterval(maxY),
        ),
        barGroups: [
          for (var i = 0; i < points.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: points[i].xp.toDouble(),
                  width: points.length > 20 ? 7 : 12,
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart({required this.points});

  final List<ActivityStatPoint> points;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final maxY = _maxY(points.map((point) => point.xp));

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: points.length > 1 ? (points.length - 1).toDouble() : 1,
        minY: 0,
        maxY: maxY,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: colors.appPanelBorder, strokeWidth: 1),
        ),
        titlesData: _axisTitles(
          context,
          points,
          leftInterval: _axisInterval(maxY),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < points.length; i++)
                FlSpot(i.toDouble(), points[i].xp.toDouble()),
            ],
            isCurved: true,
            color: colors.primary,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: colors.primary.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventChart extends StatelessWidget {
  const _EventChart({required this.events});

  final List<ActivityEventStat> events;

  @override
  Widget build(BuildContext context) {
    final total = events.fold<int>(0, (sum, event) => sum + event.value);

    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 46,
              sectionsSpace: 3,
              sections: [
                for (final event in events)
                  PieChartSectionData(
                    value: event.value.toDouble(),
                    color: activityColorFor(event.type),
                    radius: 72,
                    title: '${(event.value / total * 100).round()}%',
                    titleStyle: Theme.of(context).textTheme.labelMedium
                        ?.copyWith(
                          color: _onChartColor(activityColorFor(event.type)),
                          fontWeight: FontWeight.w800,
                        ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            for (final event in events)
              _LegendItem(
                color: activityColorFor(event.type),
                label: _eventLabel(AppLocalizations.of(context), event.type),
              ),
          ],
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.appOnSurfaceMuted,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _StatusBox extends StatelessWidget {
  const _StatusBox({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.58,
      child: Center(child: child),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.statsLoadError,
          style: theme.textTheme.titleMedium?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.appOnSurfaceSubtle,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(onPressed: onRetry, child: Text(l10n.statsRetry)),
      ],
    );
  }
}

class _EmptyText extends StatelessWidget {
  const _EmptyText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.appOnSurfaceSubtle,
          height: 1.5,
        ),
      ),
    );
  }
}

FlTitlesData _axisTitles(
  BuildContext context,
  List<ActivityStatPoint> points, {
  required double leftInterval,
}) {
  final theme = Theme.of(context);
  final colors = theme.colorScheme;

  return FlTitlesData(
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 36,
        interval: leftInterval,
        getTitlesWidget: (value, meta) => Text(
          value.toInt().toString(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: colors.appOnSurfaceFaint,
          ),
        ),
      ),
    ),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 30,
        interval: points.length <= 5 ? 1 : (points.length / 4).ceilToDouble(),
        getTitlesWidget: (value, meta) {
          if (value != value.roundToDouble()) return const SizedBox.shrink();
          final index = value.toInt();
          if (index < 0 || index >= points.length) {
            return const SizedBox.shrink();
          }
          final date = points[index].date;
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${date.month}/${date.day}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.appOnSurfaceFaint,
              ),
            ),
          );
        },
      ),
    ),
  );
}

double _maxY(Iterable<int> values) {
  final maxValue = values.fold<int>(0, math.max);
  return math.max(1, maxValue).toDouble() * 1.2;
}

double _axisInterval(double maxY) {
  if (maxY <= 4) return 1;
  return (maxY / 4).ceilToDouble();
}

String _eventLabel(AppLocalizations l10n, String type) {
  switch (type) {
    case 'push':
      return l10n.statsEventPush;
    case 'pull_request':
      return l10n.statsEventPullRequest;
    case 'issue':
      return l10n.statsEventIssue;
    case 'star':
      return l10n.statsEventStar;
    default:
      return l10n.statsEventOther;
  }
}

Color _onChartColor(Color color) {
  return ThemeData.estimateBrightnessForColor(color) == Brightness.light
      ? const Color(0xFF0F172A)
      : Colors.white;
}
