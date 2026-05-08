import 'dart:io';
import 'package:classico_app/ai_repository.dart';
import 'package:classico_app/classifier_cubit/classifier_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

// 1. تعريف الحالات التي سيمر بها التطبيق


// 2. الكيوبت
class ClassifierCubit extends Cubit<ClassifierState> {
  final AiRepository _repository;
  final ImagePicker _picker = ImagePicker();

  // حقن الاعتماديات (Dependency Injection) يسهل اختبار الكود مستقبلاً
  ClassifierCubit(this._repository) : super(ClassifierInitial()) {
    _initAI();
  }

  Future<void> _initAI() async {
    await _repository.initModel();
  }

  // أضفنا خيار تحديد مصدر الصورة (كاميرا أو معرض)
  Future<void> pickAndClassifyImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null) return;

      final imageFile = File(pickedFile.path);
      emit(ClassifierLoading()); // إخبار الواجهة بعرض مؤشر التحميل

      final results = await _repository.classifyImage(imageFile);

      if (results != null && results.isNotEmpty) {
        final label = results[0]['label']; // اسم الفريق
        final confidence = results[0]['confidence']; // نسبة التأكد
        
        emit(ClassifierSuccess(imageFile, label, confidence));
      } else {
        emit(ClassifierError("لم يتم التعرف على الفريق"));
      }
    } catch (e) {
      emit(ClassifierError("حدث خطأ تقني: $e"));
    }
  }

  @override
  Future<void> close() {
    _repository.dispose();
    return super.close();
  }
}