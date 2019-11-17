import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as formattedImage;
import 'energy_fuctions.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

class ContentAwareScaler {

  formattedImage.Image _picture;
  List<List<double>> _energy;
  File imageFile;

  int maxHeight;
  int maxWidth;

  int removecache = 0;
  int showSeams = 0;

  bool isSobel;
  bool isDgr;
  bool isGaussianSobel;

  List<List<double>> minEnergySums;
  List<int> predecessors;

  bool recalculate;

  // energy block
  int x1, y1;
  int x2, y2;
  static const double BLOCK = 12345678.9;

  void setBlock(int xPos, int width, int yPos, int height) {
    x1 = xPos;
    x2 = width + x1;
    y1 = yPos;
    y2 = height + y1;
    createEnergy();
  }

  set picture(formattedImage.Image value) {
    _picture = value;
  }

  List<List<double>> get energy => _energy;

  ContentAwareScaler(this.imageFile) {
    _picture = formattedImage.decodeNamedImage(imageFile.readAsBytesSync(), imageFile.path);
    x1 = x2 = y1 = y2 = 0;
    recalculate = false;
    isGaussianSobel = false;
    isSobel = false;
    isDgr = true;
    createEnergy();
    maxHeight = _picture.height;
    maxWidth = _picture.width;
  }

  void changeImage(File newFile) {
    _picture = formattedImage.decodeImage(newFile.readAsBytesSync());
    x1 = x2 = y1 = y2 = 0;
    recalculate = false;
    isGaussianSobel = false;
    isSobel = false;
    isDgr = true;
    createEnergy();
    maxHeight = _picture.height;
    maxWidth = _picture.width;
  }

  Future<File> editedImageFile() async {
    final byteData = formattedImage.encodeNamedImage(_picture, imageFile.path);

    final file = File('${(await getTemporaryDirectory()).path}/test.png');
    file.writeAsBytesSync(byteData);

    return file;
  }

  void setEnergyFunction(bool dgr, bool gaussianSobel, bool sobel) {
    isDgr = dgr;
    isGaussianSobel = gaussianSobel;
    isSobel = sobel;
    createEnergy();
  }
  void createEnergy() {
    if (isDgr) {
      _energy = new List(_picture.height.floor());
      for (int r = 0; r < _energy.length; r++) {
        _energy[r] = new List(_picture.width.floor());
        for (int c = 0; c < _picture.width.floor(); c++) {
          if (c >= x1 && c <= x2 && r >= y1 && r <= y2) {
            _energy[r][c] = BLOCK;
          } else {
            _energy[r][c] = dualGradientEnergy(c, r, _picture);
          }
        }
      }
    } else if (isSobel) {
      formattedImage.Image sobelImage = formattedImage.sobel(_picture.clone());
      _energy = new List(_picture.height.floor());
      for (int r = 0; r < _energy.length; r++) {
        _energy[r] = new List(_picture.width.floor());
        for (int c = 0; c < _picture.width.floor(); c++) {
          if (c >= x1 && c <= x2 && r >= y1 && r <= y2) {
            _energy[r][c] = BLOCK;
          } else {
            _energy[r][c] = sobelImage.getPixel(c, r).roundToDouble();
          }
        }
      }
    } else if (isGaussianSobel) {
      formattedImage.Image gaussianSobelImage = formattedImage.sobel(formattedImage.gaussianBlur(_picture.clone(), 5));
      _energy = new List(_picture.height.floor());
      for (int r = 0; r < _energy.length; r++) {
        _energy[r] = new List(_picture.width.floor());
        for (int c = 0; c < _picture.width.floor(); c++) {
          if (c >= x1 && c <= x2 && r >= y1 && r <= y2) {
            _energy[r][c] = BLOCK;
          } else {
            _energy[r][c] = gaussianSobelImage.getPixel(c, r).roundToDouble();
          }
        }
      }
    }
  }

  formattedImage.Image get picture => _picture;

  Future<Image> getImage() async {
    await Future.delayed(Duration(milliseconds: 1));
    return Image.memory(formattedImage.encodeNamedImage(_picture, imageFile.path));
  }
  Image getImageSync() {
    return Image.memory(formattedImage.encodeNamedImage(_picture, imageFile.path));
  }
  Image blockImage() {
    return Image.memory(formattedImage.encodeNamedImage(formattedImage.fillRect(_picture.clone(), x1, y1, x2, y2, Colors.white60.value), imageFile.path));
  }
  Image energyImage(int seams) {
    if (isDgr) {
      formattedImage.Image energyImg = new formattedImage.Image(
          width(), height());

      double max = 0;
      for (int y = 0; y < height(); y++) {
        for (int x = 0; x < width(); x++) {
          if (_energy[y][x] > max && _energy[y][x] != BLOCK) {
            max = _energy[y][x];
          }
        }
      }

      for (int y = 0; y < height(); y++) {
        for (int x = 0; x < width(); x++) {
          double n = (_energy[y][x] / max) * 255;
          int gray = n.floor();
          energyImg.setPixel(x, y, Color
              .fromARGB(255, gray, gray, gray)
              .value);
        }
      }
      seamOverlay(energyImg, seams);
      return Image.memory(formattedImage.encodePng(energyImg));
    } else if (isSobel) {
      formattedImage.Image i = formattedImage.sobel(_picture.clone());
      seamOverlay(i, seams);
      return Image.memory(formattedImage.encodePng(i));
    } else if (isGaussianSobel) {
      formattedImage.Image i = formattedImage.sobel(formattedImage.gaussianBlur(_picture.clone(), 5));
      seamOverlay(i, seams);
      return Image.memory(formattedImage.encodePng(i));
    }
  }

  void seamOverlay(formattedImage.Image image, int numSeams) {
    SeamFinder seamFinder = new SeamFinder(_energy);
    for (int i = 0; i < numSeams; i++) {
      List<int> seam = seamFinder.dpSolution();
      seamFinder.removeVerticalSeam(seam);
      for (int r = 0; r < seam.length; r++) {
        image.setPixelRgba(seam[r], r, 255, 0, 0);
      }
    }

  }

  int width() {
    return _energy[0].length;
  }

  int height() {
    return _energy.length;
  }

  List<int> findHorizontalSeam() {
    createEnergy();
    transpose();
    List<int> seam = dpSolution();
    transpose();
    return seam;
  }
  List<int> findVerticalSeam() {
    if (recalculate && isDgr) {
      createEnergy();
    }
    return dpSolution();
  }

  List<int> dpSolution() {
    minEnergySums = List.generate(height(), (_) => List<double>());
    for (int i = 0; i < height(); i++) {
      minEnergySums[i] = new List<double>(width());
      for (int o = 0; o < width(); o++) {
        minEnergySums[i][o] = 0;
      }
    }
    predecessors = List<int>(height() * width()); // predecessor indexed values from index(x, y)
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

  void removeHorizontalSeamRecalculate(List<int> seam) {
    int h = height();
    int w = width();
    formattedImage.Image newPicture = formattedImage.Image(w, h - 1);
    int r2 = 0;

    for (int c = 0; c < w; c++) {
      for (int r = 0; r < h; r++) {
        if (seam[c] != r) {
          newPicture.setPixel(c, r2, _picture.getPixel(c, r));
          r2++;
        }
      }
      r2 = 0;
    }

    _picture = newPicture;
  }
  void removeVerticalSeamRecalculate(List<int> seam) {
    int h = height();
    int w = width();
    formattedImage.Image newPicture = formattedImage.Image(w - 1, h);
    int c2 = 0;
    for (int r = 0; r < h; r++) {
      for (int c = 0; c < w; c++) {
        if (seam[r] != c) {
          newPicture.setPixel(c2, r, _picture.getPixel(c, r));
          c2++;
        }
      }
      c2 = 0;
    }
    _picture = newPicture;
  }

  set energy(List<List<double>> value) {
    _energy = value;
  }

  void removeHorizontalSeam(List<int> seam) {
    int h = height();
    int w = width();
    formattedImage.Image newPicture = formattedImage.Image(w, h - 1);
    List<List<double>> newEnergy = new List.generate(
        h - 1, (_) => List<double>(w));

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
    List<List<double>> newEnergy = new List.generate(
        h, (_) => List<double>(w - 1));

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

class SeamFinder {
  List<List<double>> _energy;

  SeamFinder(this._energy);

  int height() => _energy.length;
  int width() => _energy[0].length;

  List<int> dpSolution() {
    var minEnergySums = List.generate(height(), (_) => List<double>());
    for (int i = 0; i < height(); i++) {
      minEnergySums[i] = new List<double>(width());
      for (int o = 0; o < width(); o++) {
        minEnergySums[i][o] = 0;
      }
    }
    var predecessors = List<int>(height() * width()); // predecessor indexed values from index(x, y)
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

  int index(int x, int y) {
    return height() * x + y;
  }

  void removeVerticalSeam(List<int> seam) {
    int h = _energy.length;
    int w = _energy[0].length;
    List<List<double>> newEnergy = new List.generate(
        h, (_) => List<double>(w - 1));

    int c2 = 0;
    for (int r = 0; r < h; r++) {
      for (int c = 0; c < w; c++) {
        if (seam[r] != c) {
          newEnergy[r][c2] = _energy[r][c];
          c2++;
        }
      }
      c2 = 0;
    }
    _energy = newEnergy;
  }

}








//class SeamCarver extends ContentAwareScaler {
//
//  int verticalSeamsRemoved = -1;
//  int horizontalSeamsRemoved = -1;
//
//  SeamCarver(String fileName) {
//    super.fileName = fileName;
//    _picture = formattedImage.decodePng(File(
//        "/Users/srujan_mupparapu/FlutterProjects/seam_carver/assets/" +
//            fileName).readAsBytesSync());
//    createEnergy(dualGradientEnergy);
//  }
//
//  List<int> findHorizontalSeam() {
//    transpose();
//    List<int> seam = dpSolution();
//    transpose();
//    return seam;
//  }
//
//  List<int> findVerticalSeam() {
//    return dpSolution();
//  }
//
//  List<int> dpSolution() {
//
//    List<List<double>> minEnergySums = List.generate(
//        height(), (_) => List<double>());
//    for (int i = 0; i < height(); i++) {
//      minEnergySums[i] = new List<double>(width());
//      for (int o = 0; o < width(); o++) {
//        minEnergySums[i][o] = 0;
//      }
//    }
//    List<int> predecessors = List<int>(
//        height() * width()); // predecessor indexed values from index(x, y)
//    minEnergySums[0] = List.from(
//        _energy[0]); // first row of table should be same as first row energies
//    // O(h * w * 3)
//    for (int row = 1; row <
//        height(); row++) { // go through each row of dg energies except for the already copied one
//      for (int column = 0; column <
//          width(); column++) { // go through each energy in each column
//        for (int direction = -1; direction <=
//            1; direction++) { // check adjacent energy sums from previous row
//          if (column + direction < 0 ||
//              column + direction >= width()) { // avoid bounds exceptions
//            continue;
//          }
//          // min sum has not been calculated for this pixel yet
//          // or sum of this path is less than the current min energy sum of the pixel
//          if (minEnergySums[row][column] == 0 || _energy[row][column] +
//              minEnergySums[row - 1][column + direction] <
//              minEnergySums[row][column]) {
//            relax(minEnergySums, predecessors, row, column,
//                direction); // change the min sum and assign the predecessor
//          }
//        }
//      }
//    }
//    // O(w)
//    int minIndex = 0;
//    for (int col = 1; col <
//        width(); col++) { // find the smallest total energy path by finding the min sum in the bottom row
//      if (minEnergySums[height() - 1][col] <
//          minEnergySums[height() - 1][minIndex]) {
//        minIndex = col;
//      }
//    }
//    // O(h)
//    List<int> seam = new List(height());
//    seam[height() - 1] = minIndex;
//    for (int row = seam.length - 2; row >= 0; row--) { // get the predecessors
//      seam[row] =
//          ((predecessors[index(seam[row + 1], row + 1)] - row) / height())
//              .floor();
//    }
//
//    return seam;
//  }
//
//  void relax(List<List<double>> minEnergySums, List<int> predecessors, int row,
//      int column, int direction) {
//    minEnergySums[row][column] =
//        _energy[row][column] + minEnergySums[row - 1][column + direction];
//    predecessors[index(column, row)] = index(column + direction, row - 1);
//  }
//
//  void transpose() {
//    List<List<double>> transposedMatrix = new List(width());
//    for (int r = 0; r < width(); r++) {
//      transposedMatrix[r] = new List(height());
//    }
//
//    for (int x = 0; x < width(); x++) {
//      for (int y = 0; y < height(); y++) {
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
//  void removeHorizontalSeam(List<int> seam) {
//    int h = height();
//    int w = width();
//    formattedImage.Image newPicture = formattedImage.Image(w, h - 1);
//    List<List<double>> newEnergy = new List.generate(
//        h - 1, (_) => List<double>(w));
//
//    int r2 = 0;
//    for (int c = 0; c < w; c++) {
//      for (int r = 0; r < h; r++) {
//        if (seam[c] != r) {
//          newPicture.setPixel(c, r2, _picture.getPixel(c, r));
//          newEnergy[r2][c] = _energy[r][c];
//          r2++;
//        }
//      }
//      r2 = 0;
//    }
//
//    _picture = newPicture;
//    _energy = newEnergy;
//  }
//
//  void removeVerticalSeam(List<int> seam) {
//    int h = height();
//    int w = width();
//    formattedImage.Image newPicture = formattedImage.Image(w - 1, h);
//    List<List<double>> newEnergy = new List.generate(
//        h, (_) => List<double>(w - 1));
//
//    int c2 = 0;
//    for (int r = 0; r < h; r++) {
//      for (int c = 0; c < w; c++) {
//        if (seam[r] != c) {
//          newPicture.setPixel(c2, r, _picture.getPixel(c, r));
//          newEnergy[r][c2] = _energy[r][c];
//          c2++;
//        }
//      }
//      c2 = 0;
//    }
//    _picture = newPicture;
//    _energy = newEnergy;
//  }
//
//}






