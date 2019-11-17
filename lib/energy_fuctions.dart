import 'dart:math';
import 'package:image/image.dart' as formattedImage;
import 'package:flutter/material.dart';

int horizontalGradient(int x, int y, formattedImage.Image picture) {
  Color leftPixel = Color(picture.getPixel(x == 0 ? picture.width - 1 : x - 1, y));
  Color rightPixel = Color(picture.getPixel(x == picture.width - 1 ? 0 : x + 1, y));
  int g = sqrt(pow(leftPixel.red - rightPixel.red, 2) + pow(leftPixel.blue - rightPixel.blue, 2) + pow(leftPixel.green - rightPixel.green, 2)).floor();
  return g;
}

int verticalGradient(int x, int y, formattedImage.Image picture) {
  Color upPixel = Color(picture.getPixel(x, y == 0 ? picture.height - 1 : y - 1));
  Color downPixel = Color(picture.getPixel(x, y == picture.height - 1 ? 0 : y + 1));
  int g = sqrt(pow(upPixel.red - downPixel.red, 2) + pow(upPixel.blue - downPixel.blue, 2) + pow(upPixel.green - downPixel.green, 2)).floor();
  return g;
}

double dualGradientEnergy(int x, int y, formattedImage.Image picture) {
  return horizontalGradient(x, y, picture) + verticalGradient(x, y, picture) + 1.0;
}

int grayScale(Color color) {
  return ((color.red + color.green + color.blue) / 3).floor();
}

double sobelEnergy(int x, int y, formattedImage.Image picture) {
  Color topLeft = Color(picture.getPixel(x == 0 ? picture.width - 1 : x - 1, y == 0 ? picture.height - 1 : y - 1));
  Color top = Color(picture.getPixel(x, y == 0 ? picture.height - 1 : y - 1));
  Color topRight = Color(picture.getPixel(x == 0 ? picture.width - 1 : x - 1, y == 0 ? picture.height - 1 : y - 1));;
  Color right = Color(picture.getPixel(x == 0 ? picture.width - 1 : x - 1, y));
  Color bottomRight = Color(picture.getPixel(x == 0 ? picture.width - 1 : x - 1, y == 0 ? picture.height - 1 : y - 1));
  Color bottom = Color(picture.getPixel(x, y == 0 ? picture.height - 1 : y - 1));
  Color bottomLeft = Color(picture.getPixel(x == 0 ? picture.width - 1 : x - 1, y == 0 ? picture.height - 1 : y - 1));
  Color left = Color(picture.getPixel(x == 0 ? picture.width - 1 : x - 1, y));

  int xGradient = (grayScale(topLeft) * -1) + (grayScale(left) * -2) + (grayScale(bottomLeft) * -1) +
      (grayScale(topRight)) + (grayScale(right) * 2) + (grayScale(bottomRight));
  int yGradient = (grayScale(topLeft) * -1) + (grayScale(top) * -2) + (grayScale(topRight) * -1) +
      (grayScale(bottomLeft) * 1) + (grayScale(bottom) * 2) + (grayScale(bottomRight) * 1);
  return sqrt(pow(xGradient, 2) + pow(yGradient, 2)) + 1;
}

double laplacianEnergy(int x, int y, formattedImage.Image picture) {
  Color current = Color(picture.getPixel(x, y));
  Color top = Color(picture.getPixel(x, y == 0 ? picture.height - 1 : y - 1));
  Color right = Color(picture.getPixel(x == 0 ? picture.width - 1 : x - 1, y));
  Color bottom = Color(picture.getPixel(x, y == 0 ? picture.height - 1 : y - 1));
  Color left = Color(picture.getPixel(x == 0 ? picture.width - 1 : x - 1, y));
  int sum = (grayScale(current) * 4) + (grayScale(top) * -1) + (grayScale(right) * -1) +
      (grayScale(bottom) * -1) + (grayScale(left) * -1);
  return sum.roundToDouble() + 1;
}

double laplacianEnergyDiagonal(int x, int y, formattedImage.Image picture) {
  Color current = Color(picture.getPixel(x, y));
  Color topLeft = Color(picture.getPixel(x == 0 ? picture.width - 1 : x - 1, y == 0 ? picture.height - 1 : y - 1));
  Color top = Color(picture.getPixel(x, y == 0 ? picture.height - 1 : y - 1));
  Color topRight = Color(picture.getPixel(x == 0 ? picture.width - 1 : x - 1, y == 0 ? picture.height - 1 : y - 1));;
  Color right = Color(picture.getPixel(x == 0 ? picture.width - 1 : x - 1, y));
  Color bottomRight = Color(picture.getPixel(x == 0 ? picture.width - 1 : x - 1, y == 0 ? picture.height - 1 : y - 1));
  Color bottom = Color(picture.getPixel(x, y == 0 ? picture.height - 1 : y - 1));
  Color bottomLeft = Color(picture.getPixel(x == 0 ? picture.width - 1 : x - 1, y == 0 ? picture.height - 1 : y - 1));
  Color left = Color(picture.getPixel(x == 0 ? picture.width - 1 : x - 1, y));

  int sum = (grayScale(current) * 4) + (grayScale(topLeft) * -1) + (grayScale(top) * -1) +
      (grayScale(topRight) * -1) + (grayScale(right) * -1) + (grayScale(bottomRight) * -1) +
      (grayScale(bottom) * -1) + (grayScale(bottomLeft) * -1) + (grayScale(left) * -1);
  return sum.roundToDouble() + 1;
}