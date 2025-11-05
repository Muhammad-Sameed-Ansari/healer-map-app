import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/constants/app_constants.dart';

class AdaptiveLoader extends StatelessWidget {
  const AdaptiveLoader({super.key, });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Theme.of(context).platform == TargetPlatform.iOS
          ? const CupertinoActivityIndicator(radius: 15) // iOS loader
          : CircularProgressIndicator(color: ColorConstants.primary), // Android loader
    );
  }
}
