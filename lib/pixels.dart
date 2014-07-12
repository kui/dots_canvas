library pixel_canvas.pixels;

import 'dart:math';
import 'dart:async';
import 'dart:convert';

/**
 * Model
 */
class Pixels {
  static const JSON_PARSER = const JsonDecoder();

  final List<List<String>> _colors;
  final StreamController<ColorChangeEvent> _colorChangeController =
      new StreamController.broadcast();

  Pixels(int verticalPixels, int horizontalPixels) :
    this._colors = createMatrix(verticalPixels, horizontalPixels);

  static List<List<String>> createMatrix(
      int verticalPixels, int horizontalPixels) {
    if (verticalPixels == null)
      throw new ArgumentError('Expected verticalPixels to be non-null');
    if (horizontalPixels == null)
      throw new ArgumentError('Expected horizontalPixels to be non-null');
    return new List<List<String>>.generate(
          verticalPixels,
          (i) => new List<String>.filled(horizontalPixels, null));
  }

  factory Pixels.generate(
      int verticalPixels,
      int horizontalPixels,
      String colorGenerator(int x, int y)) {
    var px = new Pixels(verticalPixels, horizontalPixels);
    px.eachColorWithIndex(
        (c, x, y) => px._set(x, y, colorGenerator(x, y)));
    return px;
  }

  factory Pixels.fromColorMatrix(
      List<List<String>> colors, int verticalPixels, int horizontalPixels) {
    if (colors == null)
      throw new ArgumentError('Expected 1st arg to be non-null');

    return new Pixels.generate(verticalPixels, horizontalPixels, (x, y) {
      if (y >= colors.length) return null;

      var row = colors[y];
      if (row == null) {
        return null;
      } else if(x >= row.length){
        return null;
      } else {
        return row[x];
      }
    });
  }

  factory Pixels.fromJson(
      String json, int verticalPixels, int horizontalPixels) {
    List<List<String>> matrix = JSON_PARSER.convert(json);

    if (matrix == null) {
      return new Pixels(verticalPixels, horizontalPixels);
    } else {
      return new Pixels.fromColorMatrix(matrix, verticalPixels, horizontalPixels);
    }
  }

  factory Pixels.fromPixels(Pixels oldPixels, int verticalPixels, int horizontalPixels) {
    if (oldPixels == null)
      throw new ArgumentError('Expected 1st arg to be non-null');

    return new Pixels.fromColorMatrix(
        oldPixels._colors, verticalPixels, horizontalPixels);
  }

  //

  int get verticalPixels => _colors.length;
  int get horizontalPixels => _colors.first.length;
  Stream<ColorChangeEvent> get colorChange => _colorChangeController.stream;

  void eachColorWithIndex(void f(String color, int x, int y)) {
    var maxColLength = horizontalPixels;
    var maxRowLength = verticalPixels;
    for(int i = 0; i < maxColLength; i++) {
      for(int j = 0; j < maxRowLength; j++) {
        f(get(j, i), j, i);
      }
    }
  }

  void setByPoint(Point<int> p, String color) => set(p.x, p.y, color);

  void set(int x, int y, String color) {
    String old = get(x, y);
    _set(x, y, color);
    notifyColorChange(x, y, old, color);
  }

  String getByPoint(Point<int> p) => get(p.x, p.y);

  String get(int x, int y) => _colors[y][x];

  void _set(int x, int y, String color) {
    _colors[y][x] = color;
  }

  void notifyColorChange(int x, int y, String oldColor, String newColor) {
    if (oldColor == newColor) return;
    _colorChangeController.add(new ColorChangeEvent(x, y, oldColor, newColor));
  }
}

class ColorChangeEvent {
  final int x, y;
  final String oldColor, newColor;
  ColorChangeEvent(this.x, this.y, this.oldColor, this.newColor);
}