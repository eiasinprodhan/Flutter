import 'dart:collection';
import 'package:image/image.dart' as img;

class Point {
  final int x;
  final int y;
  Point(this.x, this.y);

  @override
  bool operator ==(Object other) => other is Point && other.x == x && other.y == y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}

void floodFill(img.Image image, int startX, int startY, img.Color replacementColor) {
  final int width = image.width;
  final int height = image.height;

  if (startX < 0 || startX >= width || startY < 0 || startY >= height) return;

  final targetColor = image.getPixel(startX, startY);

  if (targetColor == replacementColor) return;

  final Queue<Point> queue = Queue();
  queue.add(Point(startX, startY));

  while (queue.isNotEmpty) {
    final point = queue.removeFirst();
    final int x = point.x;
    final int y = point.y;

    if (x < 0 || x >= width || y < 0 || y >= height || image.getPixel(x, y) != targetColor) {
      continue;
    }

    image.setPixel(x, y, replacementColor);

    queue.add(Point(x + 1, y));
    queue.add(Point(x - 1, y));
    queue.add(Point(x, y + 1));
    queue.add(Point(x, y - 1));
  }
}