import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

class CustomDropdownFormField<T> extends StatelessWidget {
  final String title;
  final bool isForm;
  final bool isRequired;
  final String? info;
  final String? hintText;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? focusBorderColor;

  const CustomDropdownFormField({
    super.key,
    this.title = '',
    this.isForm = false,
    this.isRequired = false,
    this.info,
    this.hintText,
    required this.value,
    required this.items,
    required this.onChanged,
    this.borderRadius = 10,
    this.backgroundColor,
    this.borderColor,
    this.focusBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: isForm
          ? const EdgeInsets.only(bottom: 10, top: 10)
          : const EdgeInsets.only(bottom: 13.0, top: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isForm)
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF131517),
                        ),
                  ),
                  if (isRequired)
                    Text(
                      " *",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFBF0C0C),
                          ),
                    ),
                  if (info != null)
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(info!),
                              ),
                            );
                          },
                        );
                      },
                      icon: Image.asset(
                        "resources/icons/info.png",
                        height: 17,
                        width: 17,
                      ),
                    ),
                ],
              ),
            ),
          DropdownButtonFormField<T>(
            value: value,
            // Wrap items to enhance visuals in the open menu
            items: items.map(
                  (e) => DropdownMenuItem<T>(
                    value: e.value,
                    enabled: e.enabled,
                    onTap: e.onTap,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 6,
                      ),
                      child: Row(
                        children: [
                          // Expanded child to keep original content
                          Expanded(
                            child: DefaultTextStyle.merge(
                              style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: const Color(0xFF131517),
                                        fontSize: 12,
                                      ) ??
                                  const TextStyle(
                                    color: Color(0xFF131517),
                                    fontSize: 14,
                                  ),
                              child: e.child,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).toList(),
            onChanged: onChanged,
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            isExpanded: true,
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
            itemHeight: 48,
            menuMaxHeight: 320,
            selectedItemBuilder: (context) {
              return items.map((e) {
                // Try to render a safe, truncated representation for the selected item
                String? label;
                if (e.child is Text) {
                  label = (e.child as Text).data;
                }
                label ??= e.value?.toString();
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label ?? '',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black,
                        ),
                  ),
                );
              }).toList();
            },
            decoration: InputDecoration(
              filled: backgroundColor != null ? true : false,
              fillColor: backgroundColor ?? Colors.transparent,
              contentPadding: const EdgeInsets.all(15),
              isDense: true,
              hintText: hintText,
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: ColorConstants.secondary2,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(
                  width: 1,
                  color: borderColor ?? ColorConstants.borderTextFormField,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(
                  width: 1,
                  color: focusBorderColor ?? ColorConstants.borderTextFormField,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(
                  width: 1,
                  color: borderColor ?? ColorConstants.borderTextFormField,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
