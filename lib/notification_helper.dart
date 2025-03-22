import 'package:permission_handler/permission_handler.dart';

// This part was from GPT because the notification wasn't popping up
Future<void> requestNotificationPermission() async {
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
}