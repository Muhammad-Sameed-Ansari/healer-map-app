import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healer_map_flutter/app/app.dart';
import 'package:healer_map_flutter/core/utils/shared_pref_instance.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreference.instance.init();
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
