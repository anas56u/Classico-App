import 'dart:io';

import 'package:tflite_v2/tflite_v2.dart';

class AiRepository {
  Future<void> initModel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
  }

  Future<List?> classifyImage(File image) async {
    return await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2, 
      threshold: 0.5, 
      
      imageMean: 127.5, 
      imageStd: 127.5,
    );
  }

  void dispose() {
    Tflite.close(); 
  }
}