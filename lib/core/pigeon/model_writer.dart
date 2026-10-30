import 'dart:io';
import 'dart:convert';

import 'package:apolune/core/pigeon/constants.dart';
import 'package:apolune/core/pigeon/model.dart';
import 'package:apolune/core/tools/json.dart';
import 'package:apolune/core/tools/atomic_file.dart';

extension StartVpnRequestWriter on StartVpnRequest {
  Future<void> writeToStartFile() async {
    final data = JsonTool.encoder.convert(toJson());
    final filePath = VpnConstants.startPath;
    await Directory(File(filePath).parent.path).create(recursive: true);
    await writeBytesAtomically(File(filePath), utf8.encode(data));
  }
}
