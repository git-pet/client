import 'dart:async';

import 'package:client/l10n/app_localizations.dart';
import 'package:client/services/notification_service.dart';
import 'package:client/ui/theme/app_theme.dart';
import 'package:client/ui/widgets/activity_presentation.dart';
import 'package:flutter/material.dart';

enum NotificationDestination { home, friends }

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({
    super.key,
    this.service = const NotificationService(),
  });

  final NotificationService service;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<AppNotification> _notifications = const [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = _notifications.isEmpty;
      _error = null;
    });
    try {
      final notifications = await widget.service.loadNotifications();
      if (!mounted) return;
      setState(() {
        _notifications = notifications;
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

  Future<void> _open(AppNotification notification) async {
    if (!notification.isRead) {
      try {
        await widget.service.markRead(notification.id);
        if (!mounted) return;
        setState(() {
          _notifications = [
            for (final item in _notifications)
              item.id == notification.id ? item.copyWith(isRead: true) : item,
          ];
        });
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).notificationReadFailed),
          ),
        );
      }
    }
    if (!mounted) return;
    Navigator.of(context).pop(notificationDestinationFor(notification));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationsTitle),
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
      ),
      body: RefreshIndicator(onRefresh: _load, child: _buildBody(l10n)),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_isLoading) {
      return const _StatusList(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return _StatusList(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.notificationsLoadError),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _load,
              child: Text(l10n.notificationsRetry),
            ),
          ],
        ),
      );
    }
    if (_notifications.isEmpty) {
      return _StatusList(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.notifications_none_rounded, size: 40),
            const SizedBox(height: 12),
            Text(l10n.notificationsEmpty),
          ],
        ),
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      itemCount: _notifications.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return _NotificationTile(
          notification: notification,
          onTap: () => _open(notification),
        );
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Semantics(
      button: true,
      label: notification.isRead ? null : l10n.notificationUnread,
      child: Material(
        color: notification.isRead
            ? colors.appPanelSurface
            : colors.primary.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: colors.appPanelBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: CircleAvatar(
            backgroundColor: colors.primary.withValues(alpha: 0.16),
            foregroundColor: colors.primary,
            child: Icon(notificationIconFor(notification.type)),
          ),
          title: Text(
            notificationMessageFor(l10n, notification),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colors.onSurface,
              fontWeight: notification.isRead
                  ? FontWeight.w500
                  : FontWeight.w700,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              formatRelativeActivityTime(l10n, notification.createdAt),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.appOnSurfaceSubtle,
              ),
            ),
          ),
          trailing: notification.isRead
              ? null
              : Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
        ),
      ),
    );
  }
}

class _StatusList extends StatelessWidget {
  const _StatusList({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.6,
          child: Center(child: child),
        ),
      ],
    );
  }
}

NotificationDestination notificationDestinationFor(
  AppNotification notification,
) {
  return switch (notification.type) {
    'friend_request' || 'friend_accepted' => NotificationDestination.friends,
    _ => NotificationDestination.home,
  };
}

IconData notificationIconFor(String type) {
  return switch (type) {
    'friend_request' || 'friend_accepted' => Icons.person_add_alt_1_rounded,
    'level_up' => Icons.trending_up_rounded,
    'achievement' => Icons.emoji_events_rounded,
    'room_visited' => Icons.home_rounded,
    'xp_gained' => Icons.bolt_rounded,
    'pet_evolved' || 'evolution' => Icons.auto_awesome_rounded,
    _ => Icons.notifications_rounded,
  };
}

String notificationMessageFor(
  AppLocalizations l10n,
  AppNotification notification,
) {
  final payload = notification.payload;
  final name =
      payload['requester_name'] ??
      payload['friend_name'] ??
      payload['visitor_name'] ??
      payload['sender_name'];

  switch (notification.type) {
    case 'friend_request':
      return l10n.notificationFriendRequest(
        name?.toString() ?? l10n.notificationSomeone,
      );
    case 'friend_accepted':
      return l10n.notificationFriendAccepted(
        name?.toString() ?? l10n.notificationSomeone,
      );
    case 'level_up':
      final level = _intValue(payload['new_level'] ?? payload['level']);
      return level == null
          ? l10n.notificationGeneric
          : l10n.notificationLevelUp(level);
    case 'achievement':
      return l10n.notificationAchievement(
        (payload['title'] ?? payload['name'] ?? '').toString(),
      );
    case 'room_visited':
      return l10n.notificationRoomVisited(
        name?.toString() ?? l10n.notificationSomeone,
      );
    case 'xp_gained':
      final xp = _intValue(payload['xp_gained'] ?? payload['amount']);
      return xp == null
          ? l10n.notificationGeneric
          : l10n.notificationXpGained(xp);
    case 'pet_evolved':
    case 'evolution':
      final stage = payload['stage'] ?? payload['new_stage'];
      return stage == null
          ? l10n.notificationGeneric
          : l10n.notificationPetEvolved(stage.toString());
    default:
      return payload['message']?.toString() ?? l10n.notificationGeneric;
  }
}

int? _intValue(Object? value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

OverlayEntry? _activeToast;
Timer? _toastTimer;

void showNotificationToast(
  BuildContext context,
  AppNotification notification, {
  VoidCallback? onTap,
}) {
  final overlay = Overlay.maybeOf(context);
  if (overlay == null) return;

  _toastTimer?.cancel();
  _activeToast?.remove();

  late final OverlayEntry entry;
  void close() {
    if (entry.mounted) entry.remove();
    if (identical(_activeToast, entry)) _activeToast = null;
  }

  entry = OverlayEntry(
    builder: (overlayContext) {
      final theme = Theme.of(overlayContext);
      final colors = theme.colorScheme;
      return SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Material(
              elevation: 8,
              color: colors.surfaceContainerHigh,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: colors.appPanelBorder),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap == null
                    ? close
                    : () {
                        close();
                        onTap();
                      },
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        notificationIconFor(notification.type),
                        color: colors.primary,
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          notificationMessageFor(
                            AppLocalizations.of(overlayContext),
                            notification,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
  _activeToast = entry;
  overlay.insert(entry);
  _toastTimer = Timer(const Duration(seconds: 4), close);
}
