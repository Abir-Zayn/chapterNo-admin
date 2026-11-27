// Shared widget rendering mixed UTF-8 Bangla text and inline LaTeX ($...$).
// Uses flutter_math_fork with graceful plain-text fallback on parse errors.
import 'imports/math_preview_text_imports.dart';

class SharedMathPreviewText extends StatelessWidget {
  const SharedMathPreviewText({
    super.key,
    required this.text,
    this.fontSize = 14,
    this.maxLines,
    this.overflow,
    this.color,
    this.fontWeight,
  });

  final String text;
  final double fontSize;
  final int? maxLines;
  final TextOverflow? overflow;
  final Color? color;
  final FontWeight? fontWeight;

  static final RegExp _latexPattern = RegExp(r'\$([^$]+)\$');

  @override
  Widget build(BuildContext context) {
    final baseStyle = AppTypography.bangla(
      fontSize: fontSize,
      color: color ?? context.theme.colors.foreground,
      fontWeight: fontWeight ?? FontWeight.w400,
    );

    return Text.rich(
      TextSpan(children: _buildSpans(baseStyle)),
      softWrap: true,
      maxLines: maxLines,
      overflow: overflow ?? (maxLines != null ? TextOverflow.ellipsis : TextOverflow.clip),
    );
  }

  List<InlineSpan> _buildSpans(TextStyle baseStyle) {
    final spans = <InlineSpan>[];
    var lastEnd = 0;
    for (final match in _latexPattern.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(
          TextSpan(
            text: text.substring(lastEnd, match.start),
            style: baseStyle,
          ),
        );
      }
      final tex = match.group(1)!;
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Math.tex(
            tex,
            textStyle: TextStyle(
              fontSize: fontSize,
              color: baseStyle.color,
              fontWeight: baseStyle.fontWeight,
            ),
            onErrorFallback: (_) => Text(
              tex,
              style: baseStyle.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
      lastEnd = match.end;
    }
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd), style: baseStyle));
    }
    return spans;
  }
}
