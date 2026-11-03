import 'package:apna_shop/app/app.dart';
import 'package:apna_shop/app/setup_required_app.dart';
import 'package:apna_shop/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on Object catch (error) {
    // Log only the error type: messages can contain project details.
    debugPrint('Firebase initialization failed: ${error.runtimeType}');
    runApp(const SetupRequiredApp());
    return;
  }

  runApp(const ProviderScope(child: ApnaShopApp()));
}
