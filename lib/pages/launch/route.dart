import 'package:apolune/pages/main/url.dart';
import 'package:apolune/service/launch/bootstrap.dart';

extension LaunchDestinationRoute on LaunchDestination {
  String get route {
    switch (this) {
      case LaunchDestination.setup:
        return RouterPath.setup;
      case LaunchDestination.connect:
        return RouterPath.connect;
    }
  }
}
