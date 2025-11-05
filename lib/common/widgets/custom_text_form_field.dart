import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_constants.dart';
import 'package:dashed_outline/dashed_outline.dart';
import 'package:country_picker/country_picker.dart';

class CustomTextFormField extends StatefulWidget {
  final TextEditingController? controller;
  final int? maxLines;
  final String? hintText;
  final String title;
  final bool? isFilterScreen;
  final bool obscureText;
  final bool isRequired;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Function(String)? onChanged;
  final Function()? onClick;
  final Function(String)? onFieldSubmitted;
  final double titleSpacing;
  final double? fontSize;
  final Color? backgroundColor;
  final Color? borderColor;
  final String? info;
  final Color? focusBorderColor;
  final double? hintFontSize;
  final FontWeight? fontWeight;
  final TextInputType? textInputType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final TextStyle? titleTextStyle;
  final bool noHeight;
  final bool readOnly;
  final TextFormFieldType? textFormFieldType;
  final Border? border;
  final bool bottomPadding;
  final double borderRadius;
  final TextStyle? style;
  final bool multiLine;
  final TextStyle? hintTextStyle;
  final bool isForm;
  final bool isVoice;

  const CustomTextFormField({
    super.key,
    this.title = '',
    this.border,
    this.hintText,
    this.isFilterScreen = false,
    this.maxLines = 1,
    this.hintTextStyle,
    this.borderColor,
    this.focusBorderColor,
    this.onClick,
    this.style,
    this.info,
    this.onFieldSubmitted,
    this.bottomPadding = true,
    this.hintFontSize,
    this.controller,
    this.noHeight = false,
    this.readOnly = false,
    this.backgroundColor,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.validator,
    this.textFormFieldType = TextFormFieldType.text,
    this.titleSpacing = 2,
    this.titleTextStyle,
    this.fontSize,
    this.fontWeight,
    this.textInputType,
    this.multiLine = false,
    this.borderRadius = 10,
    this.inputFormatters,
    this.isForm = false,
    this.isVoice = false,
    this.isRequired = false,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  final FocusNode _focusNode = FocusNode();
  bool isShowText = true;
  Country _selectedCountry = Country(
    countryCode: 'DE',
    phoneCode: '49',
    name: 'Germany',
    e164Sc: 0,
    geographic: true,
    level: 1,
    example: '1512 3456789',
    displayName: 'Germany',
    displayNameNoCountryCode: 'Germany',
    e164Key: '',
  );

  // Detect if a TextInputType corresponds to a numeric keyboard
  bool _isNumericKeyboard(TextInputType? type) {
    if (type == null) return false;
    return type==TextInputType.number;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  // Helper method to get country-specific phone number length limits
  int _getCountryMaxLength(Country country) {
    // Get the example number length as base
    final exampleDigits = country.example.replaceAll(RegExp(r'[^0-9]'), '');
    final baseLength = exampleDigits.length;

    // Add some flexibility (allow +2 digits)
    return baseLength + 2;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          widget.isForm
              ? const EdgeInsets.only(bottom: 5, top: 5)
              : const EdgeInsets.only(bottom: 13.0, top: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.isForm)
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                children: [
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF131517),
                    ),
                  ),
                  if (widget.isRequired)
                    Text(
                      " *",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFBF0C0C),
                      ),
                    ),
                  if (widget.info != null)
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              // title: Text(widget.title),
                              content: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(widget.info!),
                              ),
                              // actions: [
                              //   TextButton(
                              //     onPressed: () => Navigator.of(context).pop(),
                              //     child: const Text('Schließen'),
                              //   ),
                              // ],
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
          Stack(
            alignment: AlignmentDirectional.bottomStart,
            children: [
              if (widget.title.isNotEmpty)
                SizedBox(height: widget.titleSpacing),
              widget.readOnly
                  ? DashedOutline(
                    borderType: BorderType.rRect,
                    radius: widget.borderRadius,
                    dashPattern: const [6, 4],
                    color: ColorConstants.borderTextFormField,
                    strokeWidth: 1,
                    child: _buildTextFormField(),
                  )
                  : _buildTextFormField(),
              if (widget.title.isNotEmpty && widget.isForm != true)
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  margin: const EdgeInsets.only(
                    bottom: 43,
                    left: 15,
                    right: 15,
                  ),
                  child: Text(
                    widget.title,
                    style:
                        widget.titleTextStyle ??
                        Theme.of(context).textTheme.titleMedium?.copyWith(
                          // color: Colors.black,
                          fontWeight: FontWeight.w300,
                          fontSize: 13,
                        ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField() {
    Widget textField;
    if (widget.textFormFieldType == TextFormFieldType.phone) {
      textField = GestureDetector(
        onTap: widget.onClick,
        child: TextFormField(
          onFieldSubmitted: widget.onFieldSubmitted,
          maxLines: 1,
          controller: widget.controller,
          focusNode: _focusNode,
          onChanged: (value) {
            // Auto-format phone number with spaces
            if (value != null && value.isNotEmpty) {
              // Remove all non-digit characters
              String digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');

              // Get country-specific max length
              int maxLength = _getCountryMaxLength(_selectedCountry);

              // Limit to country-specific max length
              if (digitsOnly.length > maxLength) {
                digitsOnly = digitsOnly.substring(0, maxLength);
              }

              // Format with spaces based on length
              String formatted = '';
              if (digitsOnly.length <= 4) {
                formatted = digitsOnly;
              } else if (digitsOnly.length <= 8) {
                formatted =
                    '${digitsOnly.substring(0, 4)} ${digitsOnly.substring(4)}';
              } else {
                formatted =
                    '${digitsOnly.substring(0, 4)} ${digitsOnly.substring(4, 8)} ${digitsOnly.substring(8)}';
              }

              // Update controller if formatting changed
              if (formatted != value) {
                widget.controller?.value = TextEditingValue(
                  text: formatted,
                  selection: TextSelection.collapsed(offset: formatted.length),
                );
              }
            }

            // Call original onChanged if provided
            if (widget.onChanged != null) {
              widget.onChanged!(value);
            }
          },
          style:
              widget.style ??
              Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.black),
          keyboardType: TextInputType.phone,
          inputFormatters: [
            ...?widget.inputFormatters,
            // Allow only digits and spaces
            FilteringTextInputFormatter.allow(RegExp(r'[0-9\s]')),
          ],
          readOnly: widget.readOnly,
          validator: (value) {
            if ((widget.isRequired ||
                    (widget.title.endsWith("*") && widget.validator == null)) &&
                (value == null || value.isEmpty)) {
              _focusNode.requestFocus();
              return "Bitte geben Sie eine Telefonnummer ein";
            }
            // Remove spaces and non-digit characters for validation
            final digitsOnly = value?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
            // Use the example number length as a guide for min/max
            final exampleDigits = _selectedCountry.example.replaceAll(
              RegExp(r'[^0-9]'),
              '',
            );
            final minLen = exampleDigits.length;
            final maxLen =
                exampleDigits.length + 2; // allow a little flexibility
            if (digitsOnly.isNotEmpty && digitsOnly.length < minLen) {
              _focusNode.requestFocus();
              return "Telefonnummer ist zu kurz für ${_selectedCountry.name}";
            }
            if (digitsOnly.length > maxLen) {
              _focusNode.requestFocus();
              return "Telefonnummer ist zu lang für ${_selectedCountry.name}";
            }
            return null;
          },
          obscureText:
              widget.textFormFieldType == TextFormFieldType.securedPassword
                  ? isShowText
                  : widget.obscureText,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            filled:
                widget.backgroundColor != null
                    ? true
                    : widget.readOnly
                    ? true
                    : false,
            fillColor:
                widget.backgroundColor ??
                (widget.readOnly
                    ? const Color(0xFFE3F2FD)
                    : Colors.transparent),
            contentPadding: const EdgeInsets.all(15),
            isDense: true,
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 4),
              child: GestureDetector(
                onTap: () {
                  showCountryPicker(
                    context: context,
                    showPhoneCode: true,
                    onSelect: (Country country) {
                      setState(() {
                        _selectedCountry = country;
                      });

                      // Re-format existing phone number with new country limits
                      if (widget.controller?.text.isNotEmpty == true) {
                        String currentDigits = widget.controller!.text
                            .replaceAll(RegExp(r'[^0-9]'), '');
                        int maxLength = _getCountryMaxLength(country);

                        if (currentDigits.length > maxLength) {
                          currentDigits = currentDigits.substring(0, maxLength);
                        }

                        // Re-format with spaces
                        String formatted = '';
                        if (currentDigits.length <= 4) {
                          formatted = currentDigits;
                        } else if (currentDigits.length <= 8) {
                          formatted =
                              '${currentDigits.substring(0, 4)} ${currentDigits.substring(4)}';
                        } else {
                          formatted =
                              '${currentDigits.substring(0, 4)} ${currentDigits.substring(4, 8)} ${currentDigits.substring(8)}';
                        }

                        widget.controller?.value = TextEditingValue(
                          text: formatted,
                          selection: TextSelection.collapsed(
                            offset: formatted.length,
                          ),
                        );
                      }
                    },
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedCountry.flagEmoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down, color: Color(0xFF1A2B48)),
                    const SizedBox(width: 4),
                    Text(
                      ' +${_selectedCountry.phoneCode} ',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A2B48),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            suffixIcon:
                widget.suffixIcon == null
                    ? null
                    : GestureDetector(
                      onTap: widget.onClick,
                      child: widget.suffixIcon,
                    ),
            hintText: widget.hintText ?? _selectedCountry.example,
            hintStyle:
                widget.hintTextStyle ??
                Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: ColorConstants.secondary2,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
            border:
                widget.readOnly
                    ? InputBorder.none
                    : OutlineInputBorder(
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      borderSide: const BorderSide(
                        width: 1,
                        color: ColorConstants.borderTextFormField,
                      ),
                    ),
            focusedBorder:
                widget.readOnly
                    ? InputBorder.none
                    : OutlineInputBorder(
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      borderSide: BorderSide(
                        width: 1,
                        color:
                            widget.focusBorderColor ??
                            ColorConstants.borderTextFormField,
                      ),
                    ),
            enabledBorder:
                widget.readOnly
                    ? InputBorder.none
                    : OutlineInputBorder(
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      borderSide: BorderSide(
                        width: 1,
                        color:
                            widget.borderColor ??
                            ColorConstants.borderTextFormField,
                      ),
                    ),
          ),
        ),
      );
      if (widget.readOnly) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: textField,
        );
      }
      return textField;
    }
    textField = GestureDetector(
      onTap: widget.onClick,
      child: TextFormField(
        onFieldSubmitted: widget.onFieldSubmitted,
        maxLines: widget.maxLines,
        controller: widget.controller,
        focusNode: _focusNode,
        onChanged: (value) {
          final effectiveType =
              (widget.textFormFieldType == TextFormFieldType.text &&
                      _isNumericKeyboard(widget.textInputType))
                  ? TextFormFieldType.germanNumber
                  : widget.textFormFieldType;
          if (effectiveType == TextFormFieldType.germanNumber) {
            // Allow digits and both decimal separators, but always normalize to German decimal comma
            String sanitized = value.replaceAll(RegExp(r"[^0-9\.,]"), '');
            // Convert all dots to commas for German format
            sanitized = sanitized.replaceAll('.', ',');
            // Keep only the first comma as decimal separator; remove subsequent commas
            int firstComma = sanitized.indexOf(',');
            if (firstComma != -1) {
              String before = sanitized.substring(
                0,
                firstComma + 1,
              ); // includes the first comma
              String after = sanitized
                  .substring(firstComma + 1)
                  .replaceAll(',', '');
              sanitized = before + after;
            }

            if (sanitized != value) {
              widget.controller?.value = TextEditingValue(
                text: sanitized,
                selection: TextSelection.collapsed(offset: sanitized.length),
              );
            }

            // Forward to consumer callback with sanitized value
            if (widget.onChanged != null)
              widget.onChanged!(widget.controller?.text ?? sanitized);
            return;
          }
          // Default forwarding
          if (widget.onChanged != null) widget.onChanged!(value);
        },
        style:
            widget.style ??
            Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.black),
        validator:
            widget.isRequired ||
                    (widget.title.endsWith("*") && widget.validator == null)
                ? (value) {
                  if (value == null || value.isEmpty) {
                    _focusNode.requestFocus();
                    return "Bitte geben Sie einen Wert ein";
                  }
                  if (widget.textFormFieldType == TextFormFieldType.email) {
                    final emailRegex = RegExp(
                      r"^[a-zA-Z0-9.!#\$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
                      r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
                      r"{0,253}[a-zA-Z0-9])?)*$",
                    );
                    if (!emailRegex.hasMatch(value.trim())) {
                      _focusNode.requestFocus();
                      return "Bitte geben Sie eine gültige E-Mail Adresse ein"; // Prompt for invalid email
                    }
                  }
                  return null;
                }
                : widget.validator,
        obscureText:
            widget.textFormFieldType == TextFormFieldType.securedPassword
                ? isShowText
                : widget.obscureText,
        textAlignVertical: TextAlignVertical.center,
        keyboardType:
            _isNumericKeyboard(widget.textInputType)
                ? const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: false,
                ) : (widget.textFormFieldType == TextFormFieldType.germanNumber
                    ? const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: false,
                    )
                    : widget.textInputType),
        inputFormatters: [
          ...?widget.inputFormatters,
          if ((widget.textFormFieldType == TextFormFieldType.text &&
                  _isNumericKeyboard(widget.textInputType)) ||
              widget.textFormFieldType == TextFormFieldType.germanNumber)
            // Allow digits, dot, and comma
            FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]')),
        ],
        readOnly: widget.readOnly,
        decoration: InputDecoration(
          filled:
              widget.backgroundColor != null
                  ? true
                  : widget.readOnly
                  ? true
                  : false,
          fillColor:
              widget.backgroundColor ??
              (widget.readOnly ? const Color(0xFFE3F2FD) : Colors.transparent),
          contentPadding: const EdgeInsets.all(15),
          isDense: true,
          prefixIcon: widget.prefixIcon,
          suffixIcon:
              widget.textFormFieldType == TextFormFieldType.securedPassword
                  ? GestureDetector(
                    onTap: () {
                      setState(() {
                        isShowText = !isShowText;
                      });
                    },
                    child: Icon(
                      isShowText ? Icons.visibility_off : Icons.remove_red_eye,
                      color: ColorConstants.black,
                      size: 20,
                    ),
                  )
                  : widget.suffixIcon == null
                  ? null
                  : GestureDetector(
                    onTap: widget.onClick,
                    child: widget.suffixIcon,
                  ),
          hintText: widget.hintText,
          hintStyle:
              widget.hintTextStyle ??
              Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: ColorConstants.secondary2,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
          border:
              widget.readOnly
                  ? InputBorder.none
                  : OutlineInputBorder(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    borderSide: const BorderSide(
                      width: 1,
                      color: ColorConstants.borderTextFormField,
                    ),
                  ),
          focusedBorder:
              widget.readOnly
                  ? InputBorder.none
                  : OutlineInputBorder(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    borderSide: BorderSide(
                      width: 1,
                      color:
                          widget.focusBorderColor ??
                          ColorConstants.borderTextFormField,
                    ),
                  ),
          enabledBorder:
              widget.readOnly
                  ? InputBorder.none
                  : OutlineInputBorder(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    borderSide: BorderSide(
                      width: 1,
                      color:
                          widget.borderColor ??
                          ColorConstants.borderTextFormField,
                    ),
                  ),
        ),
      ),
    );
    if (widget.readOnly) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: textField,
      );
    }
    return textField;
  }
}

enum TextFormFieldType {
  text,
  email,
  germanNumber,
  password,
  securedPassword,
  phone,
}
