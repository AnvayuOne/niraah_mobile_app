import 'package:material_ui/material_ui.dart';

import '../../../core/di/service_locator.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/area/area_access.dart';
import '../../../shared/area/area_widgets.dart';
import '../domain/me.dart';

/// Notification settings (spec 010 §13; spec 015): each category with a switch per channel. Notices the service
/// must send are shown as always on, with the reason, and cannot be switched off.
class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key, this.repository});

  final MeRepository? repository;

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  late final MeRepository _repo = widget.repository ?? getIt<MeRepository>();
  late Future<NotificationSettings> _settings = _repo.notificationSettings();
  bool _busy = false;

  Future<void> _set(String category, String channel, bool on) async {
    setState(() => _busy = true);
    try {
      final NotificationSettings n = await _repo.setNotification(category, channel, on);
      if (mounted) setState(() => _settings = Future<NotificationSettings>.value(n));
    } on Object catch (e) {
      if (mounted) showNote(context, failureText(e, S.of(context).commonLoadError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  static String _channel(S s, String c) => switch (c) {
        'push' => s.notifPush,
        'sms' => s.notifSms,
        'email' => s.notifEmail,
        _ => c,
      };

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AreaScaffold(
      title: s.notifTitle,
      body: AsyncBody<NotificationSettings>(
        future: _settings,
        onRetry: () => setState(() => _settings = _repo.notificationSettings()),
        builder: (BuildContext context, NotificationSettings n) => ListView(
          padding: const EdgeInsets.all(NSpace.lg),
          children: <Widget>[
            for (NotificationCategory c in n.categories) ...<Widget>[
              NCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(c.name, style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600)),
                    if (c.locked) Text(s.notifAlwaysOn(c.lockedReason ?? ''), style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                    for (ChannelSwitch ch in c.channels)
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(_channel(s, ch.channel), style: NType.bodySm.copyWith(color: NColors.inkPrimary)),
                        value: ch.enabled,
                        onChanged: c.locked || _busy ? null : (bool on) => _set(c.key, ch.channel, on),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: NSpace.sm),
            ],
            if (n.discreetNote.isNotEmpty) Text(n.discreetNote, style: NType.caption.copyWith(color: NColors.inkMuted)),
          ],
        ),
      ),
    );
  }
}
