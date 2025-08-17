import 'package:flutter/material.dart';
import 'dart:ui';

class UpdatableGlassTextFormField extends StatefulWidget {
  final String hintText;
  bool enabled = true;
  final Widget prefixIcon;
  final Color borderColor;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  

  UpdatableGlassTextFormField({
    
    Key? key,
    this.enabled = true,
    required this.hintText,
    required this.prefixIcon,
    required this.borderColor,
    required this.controller,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<UpdatableGlassTextFormField> createState() =>
      _UpdatableGlassTextFormFieldState();
}

class _UpdatableGlassTextFormFieldState
    extends State<UpdatableGlassTextFormField> {
  String _currentText = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(color: widget.borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: TextFormField(
            controller: widget.controller,
            onChanged: (value) {
              setState(() {
                _currentText = value;
              });
              if (widget.onChanged != null) {
                widget.onChanged!(value);
              }
            },
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              enabled: widget.enabled,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: Colors.black.withOpacity(0.6),
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
              prefixIcon: widget.prefixIcon,
              prefixIconColor: Colors.grey,
              fillColor: Colors.transparent,
              filled: true,
            ),
            cursorColor: Colors.white.withOpacity(0.8),
          ),
        ),
      ),
    );
  }
}
