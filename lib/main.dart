import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uniconnect/app.dart';
import 'package:uniconnect/core/di/injection.dart';

void main() {
  configureDependencies();
  runApp(UniConnectApp(router: getIt<GoRouter>()));
}
