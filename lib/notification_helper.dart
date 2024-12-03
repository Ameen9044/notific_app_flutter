import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

var india = tz.getLocation('Asia/Kolkata');
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> zonNotification(
    BuildContext context,
    DateTime? date,
    TimeOfDay? selectedTime,
    TextEditingController titleController,
    TextEditingController subtitleController) async {
  try {
    if (date == null || selectedTime == null) {
      throw Exception("Date and time must be provided");
    }
    var _scheduledDate = DateTime(date!.year, date.month, date.day,
        selectedTime!.hour, selectedTime.minute);
    if (_scheduledDate.isBefore(DateTime.now())) {
      // If in the past, show an error or adjust to the next day
      //_scheduledDate = _scheduledDate.add(const Duration(days: 1));
      debugPrint("Scheduled time is in the past. Adjusting to the next day.");
    } else {
      AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails("channelId", "channelName");

      NotificationDetails(android: androidNotificationDetails);
      await flutterLocalNotificationsPlugin.zonedSchedule(
          1,
          titleController.text,
          subtitleController.text,
          tz.TZDateTime.from(_scheduledDate, india),
          NotificationDetails(
              android: AndroidNotificationDetails(
                  "your_channel_id", "your_channel_name")),
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          androidScheduleMode: AndroidScheduleMode.exact);
    }
  } catch (e, stackTrace) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Failed to schedule notification: $e",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }
}
