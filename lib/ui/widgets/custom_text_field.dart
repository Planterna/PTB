import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:styled_widget/styled_widget.dart';
import '../../core/constants/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final String? Function(String?) validator;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool isPassword;
  final IconData? prefixIcon;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.validator,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.isPassword = false,
    this.prefixIcon,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;
  bool _hasInteracted = false;
  bool _isValid = false;
  String? _realtimeError;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_validateInRealtime);
    if (widget.controller.text.isNotEmpty) {
      _validateInRealtime();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_validateInRealtime);
    super.dispose();
  }

  void _validateInRealtime() {
    final text = widget.controller.text;
    if (text.isEmpty && !_hasInteracted) {
      if (_isValid || _realtimeError != null) {
        setState(() {
          _isValid = false;
          _realtimeError = null;
        });
      }
      return;
    }

    _hasInteracted = true;
    final error = widget.validator(text);
    final isValid = error == null && text.trim().isNotEmpty;

    if (_isValid != isValid || _realtimeError != error) {
      setState(() {
        _isValid = isValid;
        _realtimeError = error;
      });
    }
  }

  Color _getCurrentBorderColor() {
    if (!_hasInteracted || widget.controller.text.isEmpty) {
      return Colors.transparent;
    }
    if (_isValid) {
      return AppColors.accent; // Color acento/verde cuando el dato es válido
    }
    return AppColors.danger; // Color rojo cuando el dato es inválido
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _getCurrentBorderColor();
    final isBorderActive = borderColor != Colors.transparent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label)
            .textColor(AppColors.textMuted)
            .fontSize(14)
            .padding(bottom: 8),
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          obscureText: widget.isPassword ? _obscureText : false,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: _isValid
                        ? AppColors.accent
                        : (_hasInteracted && _realtimeError != null
                            ? AppColors.danger
                            : AppColors.textMuted),
                    size: 20,
                  )
                : null,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: isBorderActive
                  ? BorderSide(color: borderColor, width: 1.5)
                  : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isBorderActive ? borderColor : AppColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
            ),
            suffixIcon: widget.isPassword
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isValid)
                        const Padding(
                          padding: EdgeInsets.only(right: 4.0),
                          child: Icon(
                            Icons.check_circle_outline,
                            color: AppColors.accent,
                            size: 18,
                          ),
                        ),
                      IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    ],
                  )
                : (_isValid
                    ? const Icon(
                        Icons.check_circle_outline,
                        color: AppColors.accent,
                        size: 20,
                      )
                    : (_hasInteracted && _realtimeError != null
                        ? const Icon(
                            Icons.error_outline,
                            color: AppColors.danger,
                            size: 20,
                          )
                        : null)),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
