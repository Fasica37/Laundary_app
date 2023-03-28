import 'package:flutter/material.dart';
import 'package:laundary_app/contacts.dart';
import 'package:laundary_app/main_screen.dart';

class Routes {
  static Map<String, WidgetBuilder> getRoute() {
    return <String, WidgetBuilder>{
      '/': (context) => const MainScreen(),
      Contacts.route: (context) => const Contacts(),
    };
  }
}
