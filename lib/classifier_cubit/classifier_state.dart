import 'dart:io';

abstract class ClassifierState {}
class ClassifierInitial extends ClassifierState {}
class ClassifierLoading extends ClassifierState {}
class ClassifierSuccess extends ClassifierState {
  final File image;
  final String teamName;
  final double confidence;
  ClassifierSuccess(this.image, this.teamName, this.confidence);
}
class ClassifierError extends ClassifierState {
  final String message;
  ClassifierError(this.message);
}