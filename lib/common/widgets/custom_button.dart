import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';


class CustomAppButton extends StatelessWidget {
  CustomAppButton({
    Key? key,
    this.rmButton = false,
    this.isBorder = false,
    this.title = '',
    this.height = 45,
    this.borderRadius = 10,
    this.width,
    this.bgColor,
    this.border,
    this.icon,
    this.alignment = Alignment.center,
    required this.onPressed,
    this.loader = false,
    this.titleTextStyle,
  }) : super(key: key);
  final String title;
  final bool isBorder;
  final bool rmButton;
  final TextStyle? titleTextStyle;
  final Border? border;
  final double borderRadius;
  final VoidCallback onPressed;
  final Widget? icon;
  final Color? bgColor;
  final double? height;
  final double? width;
  final Alignment alignment;
  bool loader;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (loader == false) {
          onPressed();
        }
      },
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          border: border,
          color: bgColor,
          gradient: bgColor==null?LinearGradient(
            colors: [
              ColorConstants.primary,
              ColorConstants.primary,
            ],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(1.0, 0.0),
            // stops: [0.0, 1.0],
            // tileMode: TileMode.clamp,
          ):null,
        ),
        alignment: alignment,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) icon!,
            if (icon != null)
              const SizedBox(
                width: 5,
              ),
            loader?const CircularProgressIndicator(color: Colors.white,):Text(
              title,
              style: titleTextStyle??TextStyle(color: Colors.white,fontWeight: FontWeight.w600,fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
