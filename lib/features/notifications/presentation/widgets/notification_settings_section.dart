import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/repositories/forge_providers.dart';
import '../../application/notification_settings_providers.dart';
import '../../application/notification_settings_controller.dart';
import '../../../../domain/entities/notification_settings.dart';
import '../../domain/notification_permission_status.dart';

class NotificationSettingsSection extends ConsumerStatefulWidget {
  const NotificationSettingsSection({super.key});

  @override
  ConsumerState<NotificationSettingsSection> createState() =>
      _NotificationSettingsSectionState();
}

class _NotificationSettingsSectionState
    extends ConsumerState<NotificationSettingsSection>
    with WidgetsBindingObserver {
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(notificationPermissionStatusProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(notificationSettingsProvider);

    return settingsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text('Caricamento impostazioni notifiche...'),
      ),
      error: (_, _) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text('Impossibile caricare le impostazioni notifiche.'),
      ),
      data: (settings) {
        final permission = settings.hasDesiredPlannedActivityReminders
            ? ref.watch(notificationPermissionStatusProvider).valueOrNull
            : null;
        return _content(context, settings, permission);
      },
    );
  }

  Widget _content(
    BuildContext context,
    NotificationSettings settings,
    NotificationPermissionStatus? permission,
  ) {
    final permissionGranted =
        permission == NotificationPermissionStatus.granted;
    final reminderMinutes = settings.plannedActivityReminderTimeMinutes;
    final effective =
        settings.hasDesiredPlannedActivityReminders && permissionGranted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Notifiche', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        const Text(
          'Gestisci i promemoria locali di Forge. Non verrà richiesto alcun '
          'permesso automaticamente all\'avvio.',
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          key: const ValueKey('notifications-master-switch'),
          contentPadding: EdgeInsets.zero,
          title: const Text('Notifiche'),
          subtitle: const Text('Abilita le notifiche di Forge.'),
          value: settings.notificationsEnabled,
          onChanged: _isBusy ? null : _onMasterChanged,
        ),
        SwitchListTile(
          key: const ValueKey('planned-activity-reminders-switch'),
          contentPadding: EdgeInsets.zero,
          title: const Text('Promemoria attività pianificate'),
          subtitle: const Text(
            'Promemoria per gli allenamenti e le camminate pianificate.',
          ),
          value: settings.plannedActivityRemindersEnabled,
          onChanged: _isBusy
              ? null
              : (value) => _onCategoryChanged(value, settings),
        ),
        ListTile(
          key: const ValueKey('planned-activity-reminder-time'),
          contentPadding: EdgeInsets.zero,
          title: const Text('Ora promemoria'),
          subtitle: Text(
            reminderMinutes == null
                ? 'Scegli un orario'
                : _formatMinutes(reminderMinutes),
          ),
          trailing: const Icon(Icons.access_time_outlined),
          enabled: !_isBusy,
          onTap: _pickReminderTime,
        ),
        if (effective)
          const Text(
            'Promemoria attività attivi.',
            key: ValueKey('notifications-effective-enabled'),
          )
        else if (settings.hasDesiredPlannedActivityReminders &&
            permission == NotificationPermissionStatus.denied)
          const Text(
            'Le notifiche sono disattivate nelle impostazioni del dispositivo.',
            key: ValueKey('notifications-permission-denied'),
          )
        else if (settings.hasDesiredPlannedActivityReminders &&
            permission == NotificationPermissionStatus.unsupported)
          const Text(
            'Le notifiche non sono supportate su questo dispositivo.',
            key: ValueKey('notifications-permission-unsupported'),
          ),
      ],
    );
  }

  String _formatMinutes(int minutes) {
    final hour = minutes ~/ 60;
    final minute = minutes % 60;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  Future<void> _onMasterChanged(bool value) async {
    await _run(() async {
      final controller = ref.read(notificationSettingsControllerProvider);
      await controller.setMasterEnabled(value);
      if (value) {
        final settings = await controller.load();
        if (settings.hasDesiredPlannedActivityReminders) {
          await _requestPermission(controller);
        }
      }
    });
  }

  Future<void> _onCategoryChanged(
    bool value,
    NotificationSettings settings,
  ) async {
    if (value && !settings.notificationsEnabled) {
      _showMessage('Attiva prima le notifiche.');
      return;
    }

    var time = settings.plannedActivityReminderTimeMinutes;
    if (value && time == null) {
      final picked = await _showReminderTimePicker();
      if (picked == null || !mounted) return;
      time = picked;
    }

    await _run(() async {
      final controller = ref.read(notificationSettingsControllerProvider);
      if (time != settings.plannedActivityReminderTimeMinutes) {
        await controller.setReminderTimeMinutes(time);
      }
      await controller.setPlannedActivityRemindersEnabled(value);
      if (value) await _requestPermission(controller);
    });
  }

  Future<void> _pickReminderTime() async {
    final picked = await _showReminderTimePicker();
    if (picked == null || !mounted) return;
    await _run(() async {
      await ref
          .read(notificationSettingsControllerProvider)
          .setReminderTimeMinutes(picked);
      _showMessage('Ora promemoria aggiornata.');
    });
  }

  Future<int?> _showReminderTimePicker() async {
    final now = ref.read(clockProvider).now();
    final current = ref.read(notificationSettingsProvider).valueOrNull;
    final minutes = current?.plannedActivityReminderTimeMinutes;
    final initialTime = minutes == null
        ? TimeOfDay(hour: now.hour, minute: now.minute)
        : TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: 'Scegli l\'ora dei promemoria',
    );
    return picked == null ? null : picked.hour * 60 + picked.minute;
  }

  Future<void> _requestPermission(
    NotificationSettingsController controller,
  ) async {
    final status = await controller.requestPermission();
    ref.invalidate(notificationPermissionStatusProvider);
    if (status == NotificationPermissionStatus.denied) {
      _showMessage(
        'Le notifiche sono disattivate nelle impostazioni del dispositivo.',
      );
    } else if (status == NotificationPermissionStatus.unsupported) {
      _showMessage('Le notifiche non sono supportate su questo dispositivo.');
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    try {
      await action();
      ref.invalidate(notificationSettingsProvider);
    } on StateError catch (error) {
      _showMessage(error.message);
    } on ArgumentError catch (error) {
      _showMessage(error.message?.toString() ?? 'Valore non valido.');
    } catch (_) {
      _showMessage('Non è stato possibile aggiornare le notifiche.');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
