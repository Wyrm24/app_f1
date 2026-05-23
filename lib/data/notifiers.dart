//value notifier : hold the data
//valueListenableBuilder : listen to the data (dont need the setstate)

import 'package:flutter/material.dart';

ValueNotifier<int> selectedPageNotifier = ValueNotifier(0);
ValueNotifier<bool> isDarkNotifier = ValueNotifier(false);
