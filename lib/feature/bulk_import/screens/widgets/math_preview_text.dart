// Renders text mixing UTF-8 Bangla and inline LaTeX ($...$) segments.
// Uses flutter_math_fork for equations with a raw-text parse fallback.
import 'imports/math_preview_text_imports.dart';

class MathPreviewText extends StatelessWidget {
  const MathPreviewText({super.key, required this.text, this.fontSize = 14});

  final String text;
  final double fontSize;

  static final RegExp _latexPattern = RegExp(r'\$([^$]+)\$');

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final baseStyle = AppTypography.bangla(
      fontSize: fontSize,
      color: colors.foreground,
    );

    return Text.rich(
      TextSpan(children: _buildSpans(baseStyle)),
      softWrap: true,
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
            textStyle: TextStyle(fontSize: fontSize),
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
