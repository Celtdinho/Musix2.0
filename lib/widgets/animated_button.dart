import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum ShadowDegree { light, dark }

class AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isLoading;
  final Color color;
  final Color disabledColor;
  final double height;
  final double width;
  final int duration;
  final double borderRadius;
  final ShadowDegree shadowDegree;
  final Color textColor;
  final Color? iconColor;

  const AnimatedButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.color = Colors.white,
    this.disabledColor = Colors.grey,
    this.height = 50,
    this.width = double.infinity,
    this.duration = 70,
    this.borderRadius = 30,
    this.shadowDegree = ShadowDegree.light,
    this.textColor = Colors.black87,
    this.iconColor,
  }) : super(key: key);

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool enabled = !widget.isLoading;
    final Color backgroundColor = enabled ? widget.color : widget.disabledColor;
    final Color shadowColor = darken(backgroundColor, widget.shadowDegree);

    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: enabled ? (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      } : null,
      onTapCancel: enabled ? () => setState(() => _isPressed = false) : null,
      child: AnimatedContainer(
        duration: Duration(milliseconds: widget.duration),
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: _isPressed ? shadowColor : backgroundColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: _isPressed
              ? []
              : [
            BoxShadow(
              color: shadowColor,
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Center(
          child: widget.isLoading
              ? SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: widget.textColor,
            ),
          )
              : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  size: 20,
                  color: widget.iconColor ?? widget.textColor,
                ),
                const SizedBox(width: 12),
              ],
              Flexible(
                child: Text(
                  widget.text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: widget.textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ).animate().scale(duration: 200.ms),
    );
  }
}

Color darken(Color color, ShadowDegree degree) {
  double amount = degree == ShadowDegree.dark ? 0.3 : 0.12;
  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
  return hslDark.toColor();
}