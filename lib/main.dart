import 'package:classico_app/classifier_cubit/classifier_cubit.dart';
import 'package:classico_app/classifier_cubit/classifier_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'ai_repository.dart';

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
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
      appBar: AppBar(
        title: const Text(
          'الكشّاف الذكي ⚽',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent, 
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: BlocBuilder<ClassifierCubit, ClassifierState>(
                builder: (context, state) {
                  if (state is ClassifierLoading) {
                    return _buildLoadingState();
                  } else if (state is ClassifierSuccess) {
                    return _buildSuccessState(state);
                  } else if (state is ClassifierError) {
                    return _buildErrorState(state);
                  }
                  return _buildInitialState();
                },
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildActionButtons(context),
    );
  }

  
  Widget _buildInitialState() {
    return Container(
      key: const ValueKey('initial'),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12, width: 2),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sports_soccer, size: 80, color: Colors.blueAccent),
          SizedBox(height: 20),
          Text(
            'جاهز للتحليل!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'ارفع صورة أو التقطها للكشف عن هوية الفريق',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Column(
      key: ValueKey('loading'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: Colors.blueAccent),
        SizedBox(height: 20),
        Text(
          'يقوم الذكاء الاصطناعي بتحليل القميص...',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildSuccessState(ClassifierSuccess state) {
    final Color confidenceColor = state.confidence > 0.8 ? Colors.green : Colors.orange;

    return SingleChildScrollView(
      key: const ValueKey('success'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.file(state.image, height: 300, width: double.infinity, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 30),
          // بطاقة النتيجة
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              children: [
                Text(
                  state.teamName.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.analytics_outlined, color: confidenceColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "نسبة التطابق: ${(state.confidence * 100).toStringAsFixed(1)}%",
                      style: TextStyle(fontSize: 18, color: confidenceColor, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildErrorState(ClassifierError state) {
    return Column(
      key: const ValueKey('error'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
        const SizedBox(height: 20),
        Text(
          state.message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, color: Colors.redAccent),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E).withOpacity(0.9),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _customButton(
            context,
            icon: Icons.photo_library_rounded,
            label: 'المعرض',
            onTap: () => context.read<ClassifierCubit>().pickAndClassifyImage(ImageSource.gallery),
          ),
          Container(width: 1, height: 30, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 15)),
          _customButton(
            context,
            icon: Icons.camera_alt_rounded,
            label: 'الكاميرا',
            onTap: () => context.read<ClassifierCubit>().pickAndClassifyImage(ImageSource.camera),
          ),
        ],
      ),
    );
  }

  Widget _customButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          children: [
            Icon(icon, color: Colors.blueAccent),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}