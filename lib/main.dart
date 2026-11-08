import 'package:flutter/material.dart';
import 'package:uniconnect/app.dart';
import 'package:uniconnect/core/di/injection.dart';

void main() {
  configureDependencies();
  runApp(const UniConnectApp());
}
