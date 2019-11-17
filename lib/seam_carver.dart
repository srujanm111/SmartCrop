import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as formattedImage;
import 'energy_fuctions.dart';

//class SeamCarverQuick {
//
//  formattedImage.Image _picture;
//  List<List<double>> _energy;
//  var _energyFunction;
//
//  SeamCarverQuick(this._picture) {
//    createEnergy(dualGradientEnergy);
//  }
//
//  void createEnergy(Function energyFunction) {
//    _energy = new List(_picture.height.floor());
//    _energyFunction = energyFunction;
//    for (int r = 0; r < _energy.length; r++) {
//      _energy[r] = new List(_picture.width.floor());
//      for (int c = 0; c < _picture.width.floor(); c++) {
//        _energy[r][c] = _energyFunction(c, r, _picture);
//      }
//    }
//  }
//
//  int width() {
//    return _energy[0].length;
//  }
//
//  int height() {
//    return _energy.length;
//  }
//
//  List<int> findSeam() {
//
//    List<List<double>> minEnergySums = List.generate(height(), (_) => List<double>());
//    for (int i = 0; i < height(); i++) {
//      minEnergySums[i] = new List<double>(width());
//      for (int o = 0; o < width(); o++) {
//        minEnergySums[i][o] = 0;
//      }
//    }
//    List<int> predecessors = List<int>(height() * width()); // predecessor indexed values from index(x, y)
//    minEnergySums[0] = List.from(_energy[0]); // first row of table should be same as first row energies
//    // O(h * w * 3)
//    for (int row = 1; row < height(); row++) { // go through each row of dg energies except for the already copied one
//      for (int column = 0; column < width(); column++) { // go through each energy in each column
//        for (int direction = -1; direction <= 1; direction++) { // check adjacent energy sums from previous row
//          if (column + direction < 0 || column + direction >= width()) { // avoid bounds exceptions
//            continue;
//          }
//          // min sum has not been calculated for this pixel yet
//          // or sum of this path is less than the current min energy sum of the pixel
//          if (minEnergySums[row][column] == 0 || _energy[row][column] + minEnergySums[row - 1][column + direction] < minEnergySums[row][column]) {
//            relax(minEnergySums, predecessors, row, column, direction); // change the min sum and assign the predecessor
//          }
//        }
//      }
//    }
//    // O(w)
//    int minIndex = 0;
//    for (int col = 1; col < width(); col++) { // find the smallest total energy path by finding the min sum in the bottom row
//      if (minEnergySums[height() - 1][col] < minEnergySums[height() - 1][minIndex]) {
//        minIndex = col;
//      }
//    }
//    // O(h)
//    List<int> seam = new List(height());
//    seam[height() - 1] = minIndex;
//    for (int row = seam.length-2; row >= 0; row--) { // get the predecessors
//      seam[row] = ((predecessors[index(seam[row + 1], row + 1)] - row) / height()).floor();
//    }
//
//    return seam;
//  }
//
//  void relax(List<List<double>> minEnergySums, List<int> predecessors, int row, int column, int direction) {
//    minEnergySums[row][column] = _energy[row][column] + minEnergySums[row - 1][column + direction];
//    predecessors[index(column, row)] = index(column + direction, row - 1);
//  }
//
//  void transpose(){
//    List<List<double>> transposedMatrix = new List(width());
//    for (int r = 0; r < width(); r++) {
//      transposedMatrix[r] = new List(height());
//    }
//
//    for(int x = 0; x < width(); x++) {
//      for(int y = 0; y < height(); y++) {
//        transposedMatrix[x][y] = _energy[y][x];
//      }
//    }
//
//    _energy = transposedMatrix;
//  }
//
//  int index(int x, int y) {
//    return height() * x + y;
//  }
//
//  void removeSeam(List<int> seam) {
//    int h = height();
//    int w = width();
//    List<List<double>> newEnergy = new List.generate(h, (_) => List<double>(w - 1));
//    int c2 = 0;
//
//    for (int r = 0; r < h; r++) {
//      for (int c = 0; c < w; c++) {
//        if (seam[r] != c) {
//          newEnergy[r][c2] = _energy[r][c];
//          c2++;
//        }
//      }
//      c2 = 0;
//    }
//    _energy = newEnergy;
//  }
//
//}
//
//class QuickImageScaler {
//
//  formattedImage.Image _picture;
//  List<List<int>> verticalSeams;
//  List<List<int>> horizontalSeams;
//  int maxHeight;
//  int maxWidth;
//
//  QuickImageScaler(this._picture, this.verticalSeams, this.horizontalSeams) {
//    maxHeight = _picture.height;
//    maxWidth = _picture.width;
//  }
//
//  int get height => _picture.height;
//  int get width => _picture.width;
//
//  Image get picture => Image.memory(formattedImage.encodePng(_picture));
//
//  void removeVerticalSeam() {
//    List<int> seam = verticalSeams[maxWidth - width];
//    formattedImage.Image newPicture = formattedImage.Image(width - 1, height);
//    int c2 = 0;
//    for (int r = 0; r < height; r++) {
//      for (int c = 0; c < width; c++) {
//        if (seam[r] != c) {
//          newPicture.setPixel(c2, r, _picture.getPixel(c, r));
//          c2++;
//        } else {
//          for (int i = 0; i < horizontalSeams.length; i++) {
//            if (c < horizontalSeams[i].length && horizontalSeams[i][c] == r) {
//              horizontalSeams[i] = remove(horizontalSeams[i], c);
//              break;
//            }
//          }
//        }
//      }
//      c2 = 0;
//    }
//    _picture = newPicture;
//  }
//
//  void removeHorizontalSeam() {
//    List<int> seam = horizontalSeams[maxHeight - height];
//    print(seam);
//    formattedImage.Image newPicture = formattedImage.Image(width, height - 1);
//    int r2 = 0;
//    for (int c = 0; c < width; c++) {
//      for (int r = 0; r < height; r++) {
//        if (seam[c] != r) {
//          newPicture.setPixel(c, r2, _picture.getPixel(c, r));
//          r2++;
//        } else {
//          for (int i = 0; i < verticalSeams.length; i++) {
//            if (r < verticalSeams[i].length && verticalSeams[i][r] == c) {
//              verticalSeams[i] = remove(verticalSeams[i], r);
//              break;
//            }
//          }
//        }
//      }
//      r2 = 0;
//    }
//    _picture = newPicture;
//  }
//
//}
//
//List<int> remove(List<int> list, int index) {
//  List<int> newList = List(list.length - 1);
//  int i2 = 0;
//  for (int i = 0; i < list.length; i++) {
//    if (i != index) {
//      newList[i2] = list[i];
//      i2++;
//    }
//  }
//  return newList;
//}


class SeamCarver {

  formattedImage.Image _picture;
  List<List<double>> _energy;
  var _energyFunction;
  String fileName;

  SeamCarver(String fileName) {
    this.fileName = fileName;
    _picture = formattedImage.decodePng(File("/Users/srujan_mupparapu/FlutterProjects/seam_carver/assets/" + fileName).readAsBytesSync());
    createEnergy(dualGradientEnergy);
  }

  void createEnergy(Function energyFunction) {
    _energy = new List(_picture.height.floor());
    _energyFunction = energyFunction;
    for (int r = 0; r < _energy.length; r++) {
      _energy[r] = new List(_picture.width.floor());
      for (int c = 0; c < _picture.width.floor(); c++) {
        _energy[r][c] = _energyFunction(c, r);
      }
    }
  }

  Image get picture => Image.memory(formattedImage.encodePng(_picture));



  Image get energyImage {
    formattedImage.Image energyImg = new formattedImage.Image(width(), height());

    double max = 0;
    for (int y = 0; y < height(); y++) {
      for (int x = 0; x < width(); x++) {
        if (_energy[y][x] > max) {
          max = _energy[y][x];
        }
      }
    }

    for (int y = 0; y < height(); y++) {
      for (int x = 0; x < width(); x++) {
        int gray = ((_energy[y][x] / max) * 255).floor();
        energyImg.setPixel(x, y, Color.fromARGB(255, gray, gray, gray).value);
      }
    }
    return Image.memory(formattedImage.encodePng(energyImg));
  }

  int width() {
    return _energy[0].length;
  }

  int height() {
    return _energy.length;
  }

  double dualGradientEnergy(int x, int y) {
    Color leftPixel = Color(_picture.getPixel(x == 0 ? width() - 1 : x - 1, y));
    Color rightPixel = Color(_picture.getPixel(x == width() - 1 ? 0 : x + 1, y));
    int xGradient = pow(leftPixel.red - rightPixel.red, 2) + pow(leftPixel.blue - rightPixel.blue, 2) + pow(leftPixel.green - rightPixel.green, 2);

    Color upPixel = Color(_picture.getPixel(x, y == 0 ? height() - 1 : y - 1));
    Color downPixel = Color(_picture.getPixel(x, y == height() - 1 ? 0 : y + 1));
    int yGradient = pow(upPixel.red - downPixel.red, 2) + pow(upPixel.blue - downPixel.blue, 2) + pow(upPixel.green - downPixel.green, 2);

    return xGradient + yGradient + 1.0;
  }

  List<int> findHorizontalSeam() {
    transpose();
    List<int> seam = dpSolution();
    transpose();
    return seam;
  }

  List<int> findVerticalSeam() {
    return dpSolution();
  }

  List<int> dpSolution() {

    List<List<double>> minEnergySums = List.generate(height(), (_) => List<double>());
    for (int i = 0; i < height(); i++) {
      minEnergySums[i] = new List<double>(width());
      for (int o = 0; o < width(); o++) {
        minEnergySums[i][o] = 0;
      }
    }
    List<int> predecessors = List<int>(height() * width()); // predecessor indexed values from index(x, y)
    minEnergySums[0] = List.from(_energy[0]); // first row of table should be same as first row energies
    // O(h * w * 3)
    for (int row = 1; row < height(); row++) { // go through each row of dg energies except for the already copied one
      for (int column = 0; column < width(); column++) { // go through each energy in each column
        for (int direction = -1; direction <= 1; direction++) { // check adjacent energy sums from previous row
          if (column + direction < 0 || column + direction >= width()) { // avoid bounds exceptions
            continue;
          }
          // min sum has not been calculated for this pixel yet
          // or sum of this path is less than the current min energy sum of the pixel
          if (minEnergySums[row][column] == 0 || _energy[row][column] + minEnergySums[row - 1][column + direction] < minEnergySums[row][column]) {
            relax(minEnergySums, predecessors, row, column, direction); // change the min sum and assign the predecessor
          }
        }
      }
    }
    // O(w)
    int minIndex = 0;
    for (int col = 1; col < width(); col++) { // find the smallest total energy path by finding the min sum in the bottom row
      if (minEnergySums[height() - 1][col] < minEnergySums[height() - 1][minIndex]) {
        minIndex = col;
      }
    }
    // O(h)
    List<int> seam = new List(height());
    seam[height() - 1] = minIndex;
    for (int row = seam.length-2; row >= 0; row--) { // get the predecessors
      seam[row] = ((predecessors[index(seam[row + 1], row + 1)] - row) / height()).floor();
    }

    return seam;
  }

  void relax(List<List<double>> minEnergySums, List<int> predecessors, int row, int column, int direction) {
    minEnergySums[row][column] = _energy[row][column] + minEnergySums[row - 1][column + direction];
    predecessors[index(column, row)] = index(column + direction, row - 1);
  }

  void transpose(){
    List<List<double>> transposedMatrix = new List(width());
    for (int r = 0; r < width(); r++) {
      transposedMatrix[r] = new List(height());
    }

    for(int x = 0; x < width(); x++) {
      for(int y = 0; y < height(); y++) {
        transposedMatrix[x][y] = _energy[y][x];
      }
    }

    _energy = transposedMatrix;
  }

  int index(int x, int y) {
    return height() * x + y;
  }

  void removeHorizontalSeam(List<int> seam) {
    int h = height();
    int w = width();
    formattedImage.Image newPicture = formattedImage.Image(w, h - 1);
    List<List<double>> newEnergy = new List.generate(h - 1, (_) => List<double>(w));
    int r2 = 0;

    for (int c = 0; c < w; c++) {
      for (int r = 0; r < h; r++) {
        if (seam[c] != r) {
          newPicture.setPixel(c, r2, _picture.getPixel(c, r));
          newEnergy[r2][c] = _energy[r][c];
          r2++;
        }
      }
      r2 = 0;
    }

    _picture = newPicture;
    _energy = newEnergy;
  }

  void removeVerticalSeam(List<int> seam) {
    int h = height();
    int w = width();
    formattedImage.Image newPicture = formattedImage.Image(w - 1, h);
    List<List<double>> newEnergy = new List.generate(h, (_) => List<double>(w - 1));
    int c2 = 0;
    for (int r = 0; r < h; r++) {
      for (int c = 0; c < w; c++) {
        if (seam[r] != c) {
          newPicture.setPixel(c2, r, _picture.getPixel(c, r));
          newEnergy[r][c2] = _energy[r][c];
          c2++;
        }
      }
      c2 = 0;
    }
    _picture = newPicture;
    _energy = newEnergy;
  }

}