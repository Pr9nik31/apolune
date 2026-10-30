import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:apolune/core/model/geo_data_type.dart';
import 'package:apolune/core/db/database/enum.dart';
import 'package:apolune/core/pigeon/model.dart';
import 'package:apolune/service/shared/share/app_link_model.dart';
import 'package:apolune/service/shared/share/app_link_parser.dart';

void main() {
  group('config links', () {
    for (final entry in const <String, ApoluneConfigLinkType>{
      'outbound': ApoluneConfigLinkType.outbound,
      'raw': ApoluneConfigLinkType.raw,
    }.entries) {
      test('parses ${entry.key}', () {
        const json = '{"name":"Example"}';
        final uri = Uri(
          scheme: 'apolune',
          host: 'apolune.dev',
          path: '/config/add',
          queryParameters: {
            'type': entry.key,
            'data': base64Encode(utf8.encode(json)),
          },
          fragment: 'Imported Profile',
        );

        final result = ApoluneAppLinkParser.parse(uri);

        expect(result, isA<ApoluneConfigLink>());
        final link = result! as ApoluneConfigLink;
        expect(link.type, entry.value);
        expect(link.xrayJson, json);
        expect(link.name, 'Imported Profile');
      });
    }

    for (final type in ['setting', 'profile', 'full', 'unknown']) {
      test('rejects retired or unsupported config type $type', () {
        expect(ApoluneAppLinkParser.parse(_configUri(type: type)), isNull);
      });
    }

    test('rejects duplicate and unknown query parameters', () {
      final data = Uri.encodeQueryComponent(
        base64Encode(utf8.encode('{"name":"Example"}')),
      );
      final duplicate = Uri.parse(
        'apolune://apolune.dev/config/add?type=raw&type=full&data=$data',
      );
      final unknown = _configUri(extra: const {'backup': 'true'});

      expect(ApoluneAppLinkParser.parse(duplicate), isNull);
      expect(ApoluneAppLinkParser.parse(unknown), isNull);
    });
  });

  group('subscription links', () {
    test('parses a plain HTTPS subscription and removes its fragment', () {
      final uri = _subscriptionUri(
        url: 'https://example.com/subscription#provider-fragment',
        name: 'Provider',
      );

      final result = ApoluneAppLinkParser.parse(uri);

      expect(result, isA<ApoluneSubscriptionLink>());
      final link = result! as ApoluneSubscriptionLink;
      expect(link.url, 'https://example.com/subscription');
      expect(link.name, 'Provider');
      expect(link.ageKeyType, isNull);
      expect(link.panel, SubscriptionPanel.generic);
      expect(link.mode, isNull);
    });

    test('parses X25519 and hybrid age modes', () {
      final x25519 = ApoluneAppLinkParser.parse(
        _subscriptionUri(url: 'https://example.com/sub', age: 'x25519'),
      );
      final hybrid = ApoluneAppLinkParser.parse(
        _subscriptionUri(url: 'https://example.com/sub', age: 'hybrid'),
      );

      expect(
        (x25519! as ApoluneSubscriptionLink).ageKeyType,
        AgeKeyType.x25519,
      );
      expect(
        (hybrid! as ApoluneSubscriptionLink).ageKeyType,
        AgeKeyType.hybrid,
      );
    });

    test('rejects unknown age modes and non-HTTPS URLs', () {
      final unknownAge = _subscriptionUri(
        url: 'https://example.com/sub',
        age: 'future',
      );
      final insecure = _subscriptionUri(url: 'http://example.com/sub');

      expect(ApoluneAppLinkParser.parse(unknownAge), isNull);
      expect(ApoluneAppLinkParser.parse(insecure), isNull);
    });

    test(
      'parses explicit panel and mode and rejects ambiguous policy parameters',
      () {
        final result =
            ApoluneAppLinkParser.parse(
                  _subscriptionUri(
                    url: 'https://example.com/sub',
                    panel: 'remnawave',
                    mode: 'providerManaged',
                  ),
                )!
                as ApoluneSubscriptionLink;
        expect(result.panel, SubscriptionPanel.remnawave);
        expect(result.mode, SubscriptionMode.providerManaged);
        final base = Uri(
          scheme: 'apolune',
          host: 'apolune.dev',
          path: '/sub/add',
          queryParameters: {'url': 'https://example.com/sub'},
        ).toString();
        for (final query in [
          'panel=future',
          'mode=future',
          'panel=',
          'mode=',
          'panel=generic&panel=remnawave',
          'mode=appManaged&mode=providerManaged',
          'age=x25519&age=hybrid',
          'userAgent=Example%2Ftest&userAgent=Another%2Ftest',
          'userAgent=',
          'userAgent=Example%0D%0AX-Test%3Avalue',
        ]) {
          expect(
            ApoluneAppLinkParser.parse(Uri.parse('$base&$query')),
            isNull,
            reason: query,
          );
        }
      },
    );
  });

  group('GeoData links', () {
    test('parses domain and IP GeoData', () {
      final domain = ApoluneAppLinkParser.parse(
        _geoDataUri(type: 'domain', name: 'community-domain'),
      );
      final ip = ApoluneAppLinkParser.parse(
        _geoDataUri(type: 'ip', name: 'community-ip'),
      );

      expect((domain! as ApoluneGeoDataLink).type, GeoDataType.domain);
      expect(domain.name, 'community-domain');
      expect((ip! as ApoluneGeoDataLink).type, GeoDataType.ip);
    });

    test('rejects unsupported types and non-HTTPS URLs', () {
      expect(ApoluneAppLinkParser.parse(_geoDataUri(type: 'other')), isNull);
      expect(
        ApoluneAppLinkParser.parse(
          _geoDataUri(type: 'domain', url: 'file:///tmp/geosite.dat'),
        ),
        isNull,
      );
    });
  });

  test('requires the exact scheme, host, and supported path', () {
    final wrongScheme = _configUri(scheme: 'https');
    final wrongHost = _configUri(host: 'example.com');
    final spoofedHost = _configUri(host: 'apolune.dev.example.com');
    final wrongPath = _configUri(path: '/backup/add');

    expect(ApoluneAppLinkParser.parse(wrongScheme), isNull);
    expect(ApoluneAppLinkParser.parse(wrongHost), isNull);
    expect(ApoluneAppLinkParser.parse(spoofedHost), isNull);
    expect(ApoluneAppLinkParser.parse(wrongPath), isNull);
  });
}

Uri _configUri({
  String scheme = 'apolune',
  String host = 'apolune.dev',
  String path = '/config/add',
  String type = 'raw',
  Map<String, String> extra = const {},
}) {
  return Uri(
    scheme: scheme,
    host: host,
    path: path,
    queryParameters: {
      'type': type,
      'data': base64Encode(utf8.encode('{"name":"Example"}')),
      ...extra,
    },
  );
}

Uri _subscriptionUri({
  required String url,
  String? age,
  String name = '',
  String? panel,
  String? mode,
}) {
  return Uri(
    scheme: 'apolune',
    host: 'apolune.dev',
    path: '/sub/add',
    queryParameters: {'url': url, 'age': ?age, 'panel': ?panel, 'mode': ?mode},
    fragment: name,
  );
}

Uri _geoDataUri({
  required String type,
  String url = 'https://example.com/geodata.dat',
  String name = '',
}) {
  return Uri(
    scheme: 'apolune',
    host: 'apolune.dev',
    path: '/dat/add',
    queryParameters: {'type': type, 'url': url},
    fragment: name,
  );
}
