import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';

class GraceSliderRow extends StatelessWidget {
  const GraceSliderRow({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.display,
    this.divisions,
    this.bipolar = false,
    this.onChangeStart,
    this.onChangeEnd,
    this.trailing,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final String display;
  final int? divisions;
  final bool bipolar;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChangeEnd;

  /// Commande placée à droite du libellé (par exemple un haut-parleur).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final p = context.grace;
    return Semantics(
      label: label,
      value: display,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: GraceType.body)),
              ?trailing,
              const SizedBox(width: 4),
              Text(display, style: GraceType.body.copyWith(color: p.secondary)),
            ],
          ),
          SizedBox(
            height: 36,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 4,
                  right: 4,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: p.active,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (bipolar)
                  Center(
                    child: Container(width: 2, height: 14, color: p.outline),
                  ),
                Positioned.fill(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      activeTrackColor: Colors.transparent,
                      inactiveTrackColor: Colors.transparent,
                      thumbColor: p.text,
                      overlayShape: SliderComponentShape.noOverlay,
                      trackShape: _InvisibleTrackShape(),
                    ),
                    child: Slider(
                      value: value.clamp(min, max),
                      min: min,
                      max: max,
                      divisions: divisions,
                      onChanged: onChanged,
                      onChangeStart: onChangeStart,
                      onChangeEnd: onChangeEnd,
                      semanticFormatterCallback: (_) => display,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InvisibleTrackShape extends SliderTrackShape with BaseSliderTrackShape {
  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
  }) {}
}

/// Piste remplie depuis le centre pour les réglages bipolaires.
class GraceBipolarTrack extends StatelessWidget {
  const GraceBipolarTrack({
    super.key,
    required this.value,
    required this.color,
  });
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _BipolarPainter(value: value, color: color),
    child: const SizedBox(height: 8, width: double.infinity),
  );
}

class _BipolarPainter extends CustomPainter {
  _BipolarPainter({required this.value, required this.color});
  final double value;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.width / 2;
    final target = center + (size.width / 2 - 8) * value.clamp(-1.0, 1.0);
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(math.min(center, target), size.height / 2),
      Offset(math.max(center, target), size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(_BipolarPainter old) =>
      old.value != value || old.color != color;
}

class GraceSegment {
  const GraceSegment({required this.label, this.icon});
  final String label;
  final IconData? icon;
}

class GraceSegmented extends StatelessWidget {
  const GraceSegmented({
    super.key,
    required this.segments,
    required this.selected,
    required this.onSelected,
    this.height = 48,
  });

  final List<GraceSegment> segments;
  final int selected;
  final ValueChanged<int> onSelected;
  final double height;

  @override
  Widget build(BuildContext context) {
    final p = context.grace;
    return Container(
      height: height,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: Row(
        children: [
          for (var i = 0; i < segments.length; i++)
            Expanded(
              child: Semantics(
                button: true,
                selected: i == selected,
                label: segments[i].label,
                excludeSemantics: true,
                child: GestureDetector(
                  onTap: () => onSelected(i),
                  child: Container(
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: i == selected ? p.button : Colors.transparent,
                      borderRadius: BorderRadius.circular(height / 2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (i == selected) ...[
                          Icon(Icons.check, size: 16, color: p.onButton),
                          const SizedBox(width: 4),
                        ],
                        Flexible(
                          child: Text(
                            segments[i].label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GraceType.secondaryMedium.copyWith(
                              color: i == selected ? p.onButton : p.text,
                              fontWeight: i == selected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CheckDisc extends StatelessWidget {
  const CheckDisc({super.key, required this.selected, this.size = 22});
  final bool selected;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = context.grace;
    return Semantics(
      checked: selected,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? p.text : Colors.transparent,
          border: Border.all(color: selected ? p.text : p.outline, width: 2),
        ),
        child: selected
            ? Icon(Icons.check, size: size * 0.65, color: p.background)
            : null,
      ),
    );
  }
}

class GraceProgressBar extends StatelessWidget {
  const GraceProgressBar({
    super.key,
    required this.value,
    this.height = 8,
    this.indeterminate = false,
    this.semanticLabel,
  });

  final double? value;
  final double height;
  final bool indeterminate;

  /// Libellé traduit pour le lecteur d'écran (jamais de texte en dur ici).
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final p = context.grace;
    return Semantics(
      label: semanticLabel,
      value: value == null ? null : '${(value! * 100).round()} %',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height / 2),
        child: SizedBox(
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(color: p.active),
              if (!indeterminate)
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (value ?? 0).clamp(0.0, 1.0),
                  child: ColoredBox(color: p.text),
                )
              else
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 72,
                    height: height,
                    color: p.text.withValues(alpha: 0.5),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ColorDot extends StatelessWidget {
  const ColorDot({
    super.key,
    required this.color,
    required this.selected,
    required this.semanticLabel,
    required this.onTap,
    this.borderColor,
  });

  final Color color;
  final bool selected;
  final String semanticLabel;
  final VoidCallback onTap;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final p = context.grace;
    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 52,
          height: 52,
          child: Center(
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      borderColor ??
                      (color.computeLuminance() > 0.85
                          ? p.outline
                          : Colors.transparent),
                  width: 1,
                ),
              ),
              child: selected
                  ? Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: p.text, width: 2.5),
                      ),
                      child: Icon(
                        Icons.check,
                        size: 17,
                        color: color.computeLuminance() > 0.55
                            ? GraceColors.ink
                            : GraceColors.ivory,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

class GraceField extends StatelessWidget {
  const GraceField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.maxLength,
    this.maxLines = 1,
    this.focusNode,
    this.onChanged,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final int? maxLength;
  final int maxLines;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      maxLength: maxLength,
      maxLines: maxLines,
      onChanged: onChanged,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      style: GraceType.body,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        counterText: maxLength == null ? null : '',
      ),
    );
  }
}

class DashedSlot extends StatelessWidget {
  const DashedSlot({
    super.key,
    required this.onTap,
    required this.label,
    this.height = 168,
    this.icon = Icons.add,
  });

  final VoidCallback onTap;
  final String label;
  final double height;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final p = context.grace;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(GraceRadius.card),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(
            painter: _DashPainter(color: p.outline, radius: GraceRadius.card),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: p.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 24, color: p.text),
                ),
                if (label.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(label, style: GraceType.bodyMedium),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashPainter extends CustomPainter {
  _DashPainter({required this.color, required this.radius});
  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 6), paint);
        distance += 12;
      }
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) =>
      old.color != color || old.radius != radius;
}

class GraceDivider extends StatelessWidget {
  const GraceDivider({super.key});
  @override
  Widget build(BuildContext context) =>
      Divider(height: 1, thickness: 1, color: context.grace.surface);
}
