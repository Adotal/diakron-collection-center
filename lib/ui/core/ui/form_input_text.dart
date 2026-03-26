import 'package:diakron_collection_center/ui/core/themes/colors.dart';
import 'package:flutter/material.dart';

class FormInputText extends StatelessWidget {
  const FormInputText({
    super.key,
    required this.labelText,
    required this.controller,
    this.keyboardType,
  });

  final String labelText;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.greenDiakron1),
            borderRadius: BorderRadius.circular(12),
          ),
          labelText: labelText,
          floatingLabelStyle: TextStyle(color: AppColors.black1),
          // labelStyle: ,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.greenDiakron1),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        cursorColor: AppColors.black1,
      ),
    );
  }
}
