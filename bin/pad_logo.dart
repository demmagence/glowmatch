import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final bytes = File('assets/logo.png').readAsBytesSync();
  final image = img.decodeImage(bytes);
  if (image == null) {
    print('Failed to decode image');
    return;
  }
  
  int targetSize = 512;
  final newImage = img.Image(width: targetSize, height: targetSize);
  
  // Fill the canvas with white color
  img.fill(newImage, color: img.ColorRgba8(255, 255, 255, 255));
  
  // Scale the original image so it fits within the safe area of the adaptive icon (approx. 60% of total size)
  int newWidth, newHeight;
  if (image.width > image.height) {
    newWidth = 300;
    newHeight = (image.height * (300 / image.width)).round();
  } else {
    newHeight = 300;
    newWidth = (image.width * (300 / image.height)).round();
  }
  
  final resizedLogo = img.copyResize(
    image,
    width: newWidth,
    height: newHeight,
    interpolation: img.Interpolation.average,
  );
  
  // Center the scaled image in the canvas
  int destX = ((targetSize - newWidth) / 2).round();
  int destY = ((targetSize - newHeight) / 2).round();
  
  img.compositeImage(newImage, resizedLogo, dstX: destX, dstY: destY);
  
  final pngBytes = img.encodePng(newImage);
  File('assets/logo_padded.png').writeAsBytesSync(pngBytes);
  print('Successfully saved padded logo to assets/logo_padded.png');
}
