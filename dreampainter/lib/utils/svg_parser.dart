import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:xml/xml.dart';
import 'package:flutter/material.dart';

class SvgParser {
  Future<List<Path>> parseSvgFromAsset(String assetPath) async {
    final String svgString = await rootBundle.loadString(assetPath);
    final document = XmlDocument.parse(svgString);
    final paths = <Path>[];

    final pathElements = document.findAllElements('path');

    for (var element in pathElements) {
      final dAttribute = element.getAttribute('d');
      if (dAttribute == null || dAttribute.trim().isEmpty) {
        debugPrint("⚠️ Skipping path with empty 'd' attribute.");
        continue;
      }

      try {
        final path = parseSvgPathData(dAttribute);
        paths.add(path);
      } catch (e) {
        debugPrint("❌ Failed to parse path: $e\nData: $dAttribute");
      }
    }

    return paths;
  }
}
