

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:saber/components/canvas/_editor_image.dart';
import 'package:worker_manager/worker_manager.dart';

void main() {
  test('Test resized image dimensions', () {
    Size resized;

    resized = EditorImage.resize(const Size(100, 100), const Size(100, 100));
    expect(resized.width, 100);
    expect(resized.height, 100);

    resized = EditorImage.resize(const Size(100, 100), const Size(200, 200));
    expect(resized.width, 100);
    expect(resized.height, 100);

    resized = EditorImage.resize(const Size(100, 100), const Size(50, 50));
    expect(resized.width, 50);
    expect(resized.height, 50);

    resized = EditorImage.resize(const Size(100, 100), const Size(50, 100));
    expect(resized.width, 50);
    expect(resized.height, 50);

    resized = EditorImage.resize(const Size(100, 100), const Size(100, 50));
    expect(resized.width, 50);
    expect(resized.height, 50);

    resized = EditorImage.resize(const Size(100, 100), const Size(200, 50));
    expect(resized.width, 50);
    expect(resized.height, 50);

    resized = EditorImage.resize(const Size(100, 100), Size.zero);
    expect(resized.width, 0);
    expect(resized.height, 0);

    resized = EditorImage.resize(const Size(10, 1000), const Size(100, 100));
    expect(resized.width, 1);
    expect(resized.height, 100);
  });

  test('Test resized image bytes', () async {
    WidgetsFlutterBinding.ensureInitialized();

    /// 128x128 icon png
    final Uint8List original = (await rootBundle.load('assets/icon/resized/icon-128x128.png')).buffer.asUint8List();

    // expect size to be 128x128
    image.Image? parsedImage = image.decodePng(original);
    expect(parsedImage, isNotNull);
    expect(parsedImage!.width, 128);
    expect(parsedImage.height, 128);

    await _testImageResizeIsolate(original, const Size(100, 100), '.png');
    await _testImageResizeIsolate(original, const Size(3000, 3000), '.png');
  });
}

Future _testImageResizeIsolate(Uint8List original, Size resized, String extension) async {
  Uint8List? bytes = await workerManager.execute(
    () => EditorImage.resizeImageIsolate(original, resized, extension),
  );
  image.Image? parsedImage = image.decodePng(bytes!);
  expect(parsedImage, isNotNull);
  expect(parsedImage!.width, resized.width);
  expect(parsedImage.height, resized.height);
}
