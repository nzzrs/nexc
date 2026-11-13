import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards GPLv3 Section 7 compliance: the upstream LibreFit additional terms
/// still bind this fork, and Nexc may only add terms on top of them.
void main() {
  String read(String path) => File(path).readAsStringSync();

  group('ADDITIONAL_TERMS.md', () {
    late String terms;

    setUpAll(() => terms = read('ADDITIONAL_TERMS.md'));

    test('keeps the upstream LibreFit author attribution clause', () {
      expect(terms, contains('Author Attribution - GPLv3 Section 7b'));
      expect(
        terms,
        contains(
          'at least\nas prominent as the attributions for other contributors',
        ),
      );
    });

    test('keeps the upstream LibreFit trademark and logo clause', () {
      expect(
        terms,
        contains('Trademark and Logo Usage - GPLv3 Section 7e and 7c'),
      );
      expect(
        terms,
        contains('including the "LibreFit" name and the original project logo'),
      );
      expect(
        terms,
        contains(
          'must be marked in a reasonable way as\nbeing different from the original version',
        ),
      );
    });

    test('appends a separate Nexc Section 7 section', () {
      expect(terms, contains('3. Nexc Fork Additions - GPLv3 Section 7'));
      expect(terms, contains('"Nexc" name'));
      expect(terms, contains('different from LibreFit'));
      expect(terms, contains('LibreFit author attributions'));
    });
  });

  group('TRADEMARK_POLICY.md', () {
    late String policy;

    setUpAll(() => policy = read('TRADEMARK_POLICY.md'));

    test('keeps the Nexc brand guidelines', () {
      expect(policy, contains('Nexc Brand Guidelines'));
      expect(policy, contains('Nexc name'));
    });

    test('defers the LibreFit name and logo to the upstream terms', () {
      expect(policy, contains('LibreFit'));
      expect(policy, contains('ADDITIONAL_TERMS.md'));
      expect(policy, contains('endorsement'));
    });
  });

  group('PRIVACY.md', () {
    late String privacy;

    setUpAll(() => privacy = read('PRIVACY.md'));

    test('uses a reachable contact link', () {
      expect(privacy, isNot(contains('nexc.org')));
      expect(privacy, contains('https://github.com/nzzrs/nexc/issues'));
    });
  });

  group('In-app and repository attribution', () {
    test('About screen credits LibreFit and IamDg', () {
      final about = read('lib/features/about/about_screen.dart');
      expect(
        about,
        contains('Based on LibreFit © IamDg and the LibreFit Contributors'),
      );
    });

    test('README credits LibreFit and its contributors', () {
      final readme = read('README.md');
      expect(readme, contains('LibreFit'));
      expect(readme, contains('LibreFitOrg'));
    });
  });
}
