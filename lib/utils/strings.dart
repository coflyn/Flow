// Flow Localization System
// Supports: English (en), Indonesian (id), Japanese (ja)
//
// Usage: AppLocalizations.of(context).library

import 'package:flutter/material.dart';

final ValueNotifier<String> languageNotifier = ValueNotifier<String>('en');

class FlowStrings {
  static String get currentLang => languageNotifier.value;
}
