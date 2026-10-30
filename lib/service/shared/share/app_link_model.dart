import 'package:apolune/core/model/geo_data_type.dart';
import 'package:apolune/core/db/database/enum.dart';
import 'package:apolune/core/pigeon/model.dart';

enum ApoluneConfigLinkType {
  outbound('outbound'),
  custom('custom'),
  customAdvanced('custom-advanced'),
  raw('raw');

  const ApoluneConfigLinkType(this.wireName);

  final String wireName;
}

sealed class ApoluneAppLink {
  const ApoluneAppLink({required this.name});

  final String name;
}

final class ApoluneConfigLink extends ApoluneAppLink {
  const ApoluneConfigLink({
    required super.name,
    required this.type,
    required this.xrayJson,
  });

  final ApoluneConfigLinkType type;
  final String xrayJson;
}

final class ApoluneSubscriptionLink extends ApoluneAppLink {
  const ApoluneSubscriptionLink({
    required super.name,
    required this.url,
    this.ageKeyType,
    this.userAgent,
    this.panel = SubscriptionPanel.generic,
    this.mode,
  });

  final String url;
  final AgeKeyType? ageKeyType;
  final String? userAgent;
  final SubscriptionPanel panel;
  final SubscriptionMode? mode;
}

final class ApoluneGeoDataLink extends ApoluneAppLink {
  const ApoluneGeoDataLink({
    required super.name,
    required this.type,
    required this.url,
  });

  final GeoDataType type;
  final String url;
}
