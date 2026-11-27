// Bijoy ANSI detector tests: real mojibake/ANSI flagged, Bangla and LaTeX pass.
import 'package:chapterno_admin/feature/bulk_import/utils/bijoy_detector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BijoyDetector.check flags legacy encodings', () {
    test('flags replacement characters from failed UTF-8 decode', () {
      expect(BijoyDetector.check('ব্যাখ\uFFFDয়া'), isNotNull);
    });

    test('flags double-encoded Bangla mojibake', () {
      // 'à¦' / 'à§' sequences are UTF-8 Bangla bytes misread as Latin-1.
      expect(BijoyDetector.check('à¦à§à¦¿à¦¬'), isNotNull);
    });

    test('flags ANSI-only Bangla text written in a legacy code page', () {
      // Legacy Bijoy ANSI bytes live in the Latin-1 Supplement range.
      expect(BijoyDetector.check('gwj eû eütÖ'), isNotNull);
    });
  });

  group('BijoyDetector.check passes legitimate text', () {
    test('passes Unicode Bangla', () {
      expect(BijoyDetector.check('ঢাকা বোর্ডের প্রশ্ন'), isNull);
    });

    test('passes plain ASCII', () {
      expect(BijoyDetector.check('Which one is correct? (A) 10'), isNull);
    });

    test('passes Physics LaTeX with backslashes and subscripts', () {
      expect(BijoyDetector.check(r'$E_k = \frac{1}{2}mv^2$'), isNull);
    });

    test('passes Chemistry LaTeX with commands and braces', () {
      expect(
        BijoyDetector.check(
          r'$\text{CaCO}_3 \xrightarrow{\Delta} \text{CaO} + \text{CO}_2$',
        ),
        isNull,
      );
    });

    test('passes whitelisted math symbols like degrees and plus-minus', () {
      expect(BijoyDetector.check('কোণ 30° এবং ±5 পার্থক্য'), isNull);
    });

    test('passes null and empty input', () {
      expect(BijoyDetector.check(null), isNull);
      expect(BijoyDetector.check(''), isNull);
    });
  });
}
