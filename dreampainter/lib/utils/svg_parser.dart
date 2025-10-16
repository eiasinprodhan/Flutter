import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:xml/xml.dart';

class SvgParser {
  Future<List<Path>> parseSvgFromAsset(String assetPath) async {
    try {
      final String svgString = await rootBundle.loadString(assetPath);
      final document = XmlDocument.parse(svgString);
      final paths = document.findAllElements('path');

      final List<Path> parsedPaths = [];
      for (final element in paths) {
        final dAttribute = element.getAttribute('d');

        if (dAttribute != null && dAttribute.isNotEmpty) {
          try {
            final path = parseSvgPath(dAttribute);
            parsedPaths.add(path);
          } catch (e) {
            if (kDebugMode) {
              print('--- SVG PARSING ERROR ---');
              print('Could not parse a path in asset: $assetPath');
              print('Error: $e');
              print('Problematic path data (d): "$dAttribute"');
              print('-------------------------');
            }
          }
        }
      }
      return parsedPaths;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load or parse SVG file: $assetPath. Error: $e');
      }
      return [];
    }
  }
}

parseSvgPath(String dAttribute) {
}