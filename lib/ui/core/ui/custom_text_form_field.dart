import 'package:diakron_collection_center/ui/core/themes/colors.dart';
import 'package:flutter/material.dart';

class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField({
    super.key,
    required this.labelText,
    required this.controller,
    required this.validator,
    this.keyboardType,
    this.minMaxLines,
    this.maxLength,
    this.enabled = true,
    this.isPassword = false,
  });

  final bool isPassword;

  final String labelText;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? Function(String?) validator;
  final int? minMaxLines;
  final int? maxLength;
  final bool enabled;

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _passwordObscured = true;

  @override
  Widget build(BuildContext context) {
    // Define a consistent border radius
    final borderRadius = BorderRadius.circular(12);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        enabled: widget.enabled,
        minLines: widget.minMaxLines,
        maxLines: widget.isPassword ? 1 : widget.minMaxLines,
        maxLength: widget.maxLength,
        controller: widget.controller,
        validator: widget.validator,

        keyboardType: widget.keyboardType,
        obscureText: widget.isPassword ? _passwordObscured : false,
        // This ensures the input text stays dark/readable when disabled
        style: TextStyle(
          color: widget.enabled
              ? AppColors.black1
              : AppColors.black1.withOpacity(0.8),
          fontWeight: widget.enabled ? FontWeight.normal : FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: widget.labelText,
          suffixIcon: !widget.isPassword
              ? null
              : IconButton(
                  icon: Icon(
                    _passwordObscured ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _passwordObscured = !_passwordObscured;
                    });
                  },
                ),
          // Label color when the field is active
          floatingLabelStyle: TextStyle(
            color: widget.enabled ? AppColors.greenDiakron1 : AppColors.black1,
          ),
          // Label color when field is idle/disabled
          labelStyle: TextStyle(
            color: widget.enabled
                ? Colors.grey
                : AppColors.black1.withOpacity(0.7),
          ),
          // BORDER LOGIC
          border: OutlineInputBorder(borderRadius: borderRadius),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.greenDiakron1),
            borderRadius: borderRadius,
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.greenDiakron1, width: 2),
            borderRadius: borderRadius,
          ),
          // Removes the border entirely when disabled
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: borderRadius,
          ),
          // Optional: slight background fill to show it's a read-only area
          filled: !widget.enabled,
          fillColor: Colors.grey.shade100,
        ),
        cursorColor: AppColors.black1,
      ),
    );
  }
}
