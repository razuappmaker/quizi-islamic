// utils.dart

import 'package:flutter/material.dart';

Future<bool> showExitConfirmationDialog(BuildContext context) async {
  bool shouldExit = false;

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: const [
          Icon(Icons.warning, color: Colors.red),
          SizedBox(width: 10),
          Text("সতর্কতা"),
        ],
      ),
      content: const Text(
        "তুমি কি অ্যাপ থেকে সত্যি বের হতে চাও?\n\nচাইলে এই আমলের কাজের সাথে কিছুকক্ষণ থাকতে পারো।",
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // No
          },
          child: const Text("না"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Ok
          },
          child: const Text("ঠিক আছে"),
        ),
        TextButton(
          onPressed: () {
            shouldExit = true;
            Navigator.of(context).pop(); // Yes
          },
          child: const Text("হ্যাঁ"),
        ),
      ],
    ),
  );

  return shouldExit;
}