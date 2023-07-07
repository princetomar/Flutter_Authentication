import 'package:flutter/material.dart';

void showToastTile(context, message, color) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: color,
      action: SnackBarAction(
        label: "OK",
        textColor: Colors.white,
        onPressed: () {},
      ),
      content: Text(
        message,
        style: TextStyle(
          fontSize: 15,
        ),
      ),
    ),
  );
}
