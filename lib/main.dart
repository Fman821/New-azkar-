import 'package:flutter/material.dart';

import 'app.dart';
import 'notifications/azkar_reminders.dart';
import 'models/content.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await AzkarReminders.instance.initialize();
  } catch (_) {
    // Reminders are optional: the app still opens if they cannot start.
  }
  final state = await AppState.create();
  final content = await ContentRepository.load();
  runApp(AzkarApp(state: state, content: content));
}
