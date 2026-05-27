import 'package:flutter/material.dart';

void dismissAuthKeyboard() {
  FocusManager.instance.primaryFocus?.unfocus();
}
