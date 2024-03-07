import 'package:flutter/material.dart';

class PickerUtil {
  static Future<TimeOfDay?> openTimePicker(BuildContext context) async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    return selectedTime;
  }

  // Method to open a duration picker
  static Future<int?> openDurationPicker(BuildContext context) async {
    int? selectedDurationInMinutes;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        int duration = 0;
        return AlertDialog(
          title: const Text('Select Duration (in minutes)'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Duration (minutes)'),
                  onChanged: (value) {
                    duration = int.tryParse(value) ?? 0;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                selectedDurationInMinutes = duration;
                Navigator.of(context).pop();
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );

    return selectedDurationInMinutes;
  }
}
