/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexc_flutter/core/db/enums.dart';
import 'package:nexc_flutter/core/l10n/l10n.dart';
import 'package:nexc_flutter/l10n/app_localizations.dart';
import 'package:nexc_flutter/l10n/app_localizations_en.dart';

const String _arbDir = 'lib/l10n';
const String _templateLocale = 'en';

/// Locales that must ship a bundle, as listed in the i18n plan.
const List<String> _translationLocales = <String>[
  'ar',
  'ca',
  'cs',
  'de',
  'es',
  'fr',
  'gl',
  'hi',
  'id',
  'it',
  'ko',
  'nl',
  'pl',
  'pt',
  'pt_BR',
  'ru',
  'sv',
  'uk',
  'ur',
  'zh_CN',
];

/// Every ARB file the generator reads: the template, the translations and the
/// base `zh` fallback that Flutter requires for `zh_CN`.
List<String> get _allArbLocales => <String>[
  _templateLocale,
  ..._translationLocales,
  'zh',
];

Map<String, dynamic> _readArb(String locale) {
  final File file = File('$_arbDir/app_$locale.arb');
  expect(file.existsSync(), isTrue, reason: 'Missing ARB file for $locale');
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

/// Message keys only, ignoring ARB metadata such as `@@locale` and `@key`.
Set<String> _messageKeys(Map<String, dynamic> arb) =>
    arb.keys.where((String key) => !key.startsWith('@')).toSet();

void main() {
  group('ARB files', () {
    test('every locale ARB parses and declares its locale', () {
      for (final String locale in _allArbLocales) {
        final Map<String, dynamic> arb = _readArb(locale);
        expect(
          arb['@@locale'],
          locale,
          reason: '$locale ARB must declare @@locale: $locale',
        );
      }
    });

    test('every locale has the same message keys as app_en.arb', () {
      final Set<String> templateKeys = _messageKeys(_readArb(_templateLocale));

      for (final String locale in _allArbLocales) {
        final Set<String> keys = _messageKeys(_readArb(locale));
        expect(
          keys.difference(templateKeys),
          isEmpty,
          reason: '$locale has keys that are missing from app_en.arb',
        );
        expect(
          templateKeys.difference(keys),
          isEmpty,
          reason: '$locale is missing keys from app_en.arb',
        );
      }
    });

    test('no locale contains an empty message', () {
      for (final String locale in _allArbLocales) {
        final Map<String, dynamic> arb = _readArb(locale);
        for (final String key in _messageKeys(arb)) {
          final Object? value = arb[key];
          expect(value, isA<String>(), reason: '$locale.$key must be a string');
          expect(
            (value as String).trim(),
            isNotEmpty,
            reason: '$locale.$key must not be empty',
          );
        }
      }
    });

    test('no ARB file declares a duplicate key', () {
      for (final String locale in _allArbLocales) {
        final String contents = File(
          '$_arbDir/app_$locale.arb',
        ).readAsStringSync();
        final RegExp keyPattern = RegExp(
          r'^  "([^"@][^"]*)"\s*:',
          multiLine: true,
        );
        final List<String> keys = keyPattern
            .allMatches(contents)
            .map((RegExpMatch match) => match.group(1)!)
            .toList();
        expect(
          keys.toSet().length,
          keys.length,
          reason: '$locale has duplicate keys',
        );
      }
    });

    test('the template keeps the English strings tests rely on', () {
      final AppLocalizations en = AppLocalizationsEn();

      expect(en.cancel, 'Cancel');
      expect(en.settingsTitle, 'Settings');
      expect(en.aboutTitle, 'About');
      expect(en.startEmptyWorkout, 'Start empty workout');
      expect(en.restTimeLabel, 'Rest time: ');
      expect(en.plateCalculator, 'Plate calculator');
      expect(en.newDayStartsAt('05'), 'New day starts at 05:00');
      expect(
        en.cannotHitExactly('2.5 kg'),
        'Cannot hit exactly — 2.5 kg left over per side',
      );
      expect(en.plateCount(3), '× 3');
      expect(
        en.madeWithLove,
        'Made with ❤️ — built on the shoulders of giants.',
      );
      expect(en.elapsedTime('01:30'), 'Elapsed time: 01:30');
    });
  });

  group('generated localizations', () {
    test('supported locales cover every shipped ARB', () {
      final Set<String> supported = AppLocalizations.supportedLocales
          .map((Locale locale) => locale.toLanguageTag().replaceAll('-', '_'))
          .toSet();

      for (final String locale in <String>[
        ..._translationLocales,
        _templateLocale,
      ]) {
        expect(
          supported,
          contains(locale),
          reason: 'AppLocalizations.supportedLocales lacks $locale',
        );
      }
    });

    test('the delegate resolves a non-English locale', () async {
      final AppLocalizations spanish = await AppLocalizations.delegate.load(
        const Locale('es'),
      );
      expect(spanish.localeName, 'es');

      final AppLocalizations arabic = await AppLocalizations.delegate.load(
        const Locale('ar'),
      );
      expect(arabic.localeName, 'ar');
    });

    testWidgets('context.l10n falls back to English without delegates', (
      WidgetTester tester,
    ) async {
      late AppLocalizations? installed;
      late AppLocalizations resolved;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              installed = AppLocalizations.of(context);
              resolved = context.l10n;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(installed, isNull);
      expect(resolved, isA<AppLocalizationsEn>());
      expect(resolved.settingsTitle, 'Settings');
      expect(resolved.tabWorkout, 'Workout');
    });

    testWidgets('switching the app locale resolves the matching bundle', (
      WidgetTester tester,
    ) async {
      late AppLocalizations? installed;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (BuildContext context) {
              installed = AppLocalizations.of(context);
              return Text(context.l10n.settingsTitle);
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(installed, isNotNull);
      expect(installed!.localeName, 'es');
      // Phase A ships English placeholders, so the text is unchanged.
      expect(find.text('Settings'), findsOneWidget);
    });
  });

  group('Language', () {
    test('maps every non-system language to a Locale', () {
      expect(Language.system.locale, isNull);

      for (final Language language in Language.values) {
        if (language == Language.system) continue;
        expect(
          language.locale,
          isNotNull,
          reason: '${language.name} has no Locale',
        );
        expect(
          language.locale!.languageCode,
          language.code!.split('_').first,
          reason: '${language.name} language code mismatch',
        );
      }

      expect(Language.portugueseBrazil.locale, const Locale('pt', 'BR'));
      expect(Language.simplifiedChinese.locale, const Locale('zh', 'CN'));
    });

    test('has a bundle for every non-system language', () {
      final Set<String> locales = _allArbLocales.toSet();
      for (final Language language in Language.values) {
        final String? code = language.code;
        if (code == null) continue;
        expect(
          locales,
          contains(code),
          reason: '${language.name} has no ARB file',
        );
      }
    });

    test('parses stored and legacy codes', () {
      expect(Language.fromCode(null), Language.system);
      expect(Language.fromCode(''), Language.system);
      expect(Language.fromCode('en'), Language.english);
      expect(Language.fromCode('it'), Language.italian);
      expect(Language.fromCode('de'), Language.german);
      expect(Language.fromCode('nl'), Language.dutch);
      expect(Language.fromCode('cs'), Language.czech);
      expect(Language.fromCode('es'), Language.spanish);
      expect(Language.fromCode('zh-rCN'), Language.simplifiedChinese);
      expect(Language.fromCode('zh_CN'), Language.simplifiedChinese);
      expect(Language.fromCode('pt_BR'), Language.portugueseBrazil);
      expect(Language.fromCode('unknown'), Language.system);
    });
  });
}
