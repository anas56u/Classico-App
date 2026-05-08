import 'package:classico_app/classifier_cubit/classifier_cubit.dart';
import 'package:classico_app/classifier_cubit/classifier_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'ai_repository.dart';

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData.dark(), // ثيم داكن احترافي
      debugShowCheckedModeBanner: false,
      home: BlocProvider(
        create: (context) => ClassifierCubit(AiRepository()),
        child: const SportsClassifierScreen(),
      ),
    ),
  );
}

class SportsClassifierScreen extends StatelessWidget {
  const SportsClassifierScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('كشاف الفِرَق الذكي ⚽')),
      body: Center(
        child: BlocBuilder<ClassifierCubit, ClassifierState>(
          builder: (context, state) {
            if (state is ClassifierLoading) {
              return const CircularProgressIndicator();
            } else if (state is ClassifierSuccess) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(state.image, height: 300, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "الفريق: ${state.teamName}",
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "دقة الذكاء الاصطناعي: ${(state.confidence * 100).toStringAsFixed(1)}%",
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              );
            } else if (state is ClassifierError) {
              return Text(state.message, style: const TextStyle(color: Colors.redAccent));
            }
            
            // الحالة الابتدائية
            return const Text(
              'التقط صورة أو اختر من المعرض\nلتحليل قميص الفريق',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            );
          },
        ),
      ),
      // أزرار لاختيار المصدر (كاميرا أو معرض)
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "gallery",
            onPressed: () => context.read<ClassifierCubit>().pickAndClassifyImage(ImageSource.gallery),
            child: const Icon(Icons.photo_library),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            heroTag: "camera",
            onPressed: () => context.read<ClassifierCubit>().pickAndClassifyImage(ImageSource.camera),
            child: const Icon(Icons.camera_alt),
          ),
        ],
      ),
    );
  }
}