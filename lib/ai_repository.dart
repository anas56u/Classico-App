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
      numResults: 2, // عدد الفِرَق (برشلونة وريال مدريد)
      threshold: 0.5, // 50% كحد أدنى للثقة لاعتماد النتيجة
      // لماذا 127.5؟ لأننا نقوم بعملية Normalization للبيانات 
      // لتصبح قيم البيكسلات بين -1 و 1 بدلاً من 0 إلى 255 ليفهمها المودل
      imageMean: 127.5, 
      imageStd: 127.5,
    );
  }

  void dispose() {
    Tflite.close(); // تفريغ الذاكرة لمنع Memory Leaks
  }
}