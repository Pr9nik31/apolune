import 'package:apolune/core/db/database/database.dart';
import 'package:apolune/service/shared/share/app_link_generator.dart';

typedef ApoluneGeoDataLookup = Future<GeoDataData?> Function(String name);

final class ApoluneAppLinkShareService {
  ApoluneAppLinkShareService({ApoluneGeoDataLookup? geoDataLookup})
    : _geoDataLookup =
          geoDataLookup ?? AppDatabase().geoDataDao.searchRowByName;

  final ApoluneGeoDataLookup _geoDataLookup;

  Future<String?> config(CoreConfigData config) async {
    final configUri = ApoluneAppLinkGenerator.config(config);
    if (configUri == null) {
      return null;
    }

    final links = <String>[];
    final names = ApoluneAppLinkGenerator.referencedGeoDataNames(
      config,
    ).toList()..sort();
    for (final name in names) {
      final geoData = await _geoDataLookup(name);
      if (geoData == null) {
        continue;
      }
      final uri = ApoluneAppLinkGenerator.geoData(geoData);
      if (uri != null) {
        links.add(uri.toString());
      }
    }
    links.add(configUri.toString());
    return links.join('\n');
  }

  String? subscription(SubscriptionData subscription) {
    return ApoluneAppLinkGenerator.subscription(subscription)?.toString();
  }

  String? geoData(GeoDataData geoData) {
    return ApoluneAppLinkGenerator.geoData(geoData)?.toString();
  }
}
