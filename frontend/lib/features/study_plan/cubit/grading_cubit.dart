// file: lib/features/study_plan/cubit/grading_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/grading_scale_model.dart';
import '../../../data/models/special_grade_symbol_model.dart';
import '../../../data/services/grading_service.dart';
import '../../../data/services/base_service.dart';

abstract class GradingState {}
class GradingInitial extends GradingState {}
class GradingLoading extends GradingState {}
class GradingLoaded extends GradingState {
  GradingLoaded({required this.scales, required this.symbols});
  final List<GradingScaleModel> scales;
  final List<SpecialGradeSymbolModel> symbols;
}
class GradingError extends GradingState {
  GradingError(this.message);
  final String message;
}
class GradingSaving extends GradingState {}
class GradingSaved extends GradingState {}

class GradingCubit extends Cubit<GradingState> {
  GradingCubit({GradingService? service})
      : _service = service ?? GradingService(), super(GradingInitial());
  final GradingService _service;
  String _planId = '';

  Future<void> load(String planId) async {
    _planId = planId;
    emit(GradingLoading());
    try {
      final scales = await _service.getScalesByPlanId(planId);
      final symbols = await _service.getSymbolsByPlanId(planId);
      emit(GradingLoaded(scales: scales, symbols: symbols));
    } on ServiceException catch (e) { emit(GradingError(e.message)); }
  }

  // Scale CRUD
  Future<void> createScale(GradingScaleModel m) async {
    emit(GradingSaving());
    try { await _service.createScale(m); emit(GradingSaved()); await load(_planId);
    } on ServiceException catch (e) { emit(GradingError(e.message)); }
  }
  Future<void> updateScale(String id, GradingScaleModel m) async {
    emit(GradingSaving());
    try { await _service.updateScale(id, m); emit(GradingSaved()); await load(_planId);
    } on ServiceException catch (e) { emit(GradingError(e.message)); }
  }
  Future<void> deleteScale(String id) async {
    emit(GradingSaving());
    try { await _service.deleteScale(id); emit(GradingSaved()); await load(_planId);
    } on ServiceException catch (e) { emit(GradingError(e.message)); }
  }

  // Item CRUD
  Future<void> createItem(GradeScaleItemModel m) async {
    emit(GradingSaving());
    try { await _service.createItem(m); emit(GradingSaved()); await load(_planId);
    } on ServiceException catch (e) { emit(GradingError(e.message)); }
  }
  Future<void> updateItem(String id, GradeScaleItemModel m) async {
    emit(GradingSaving());
    try { await _service.updateItem(id, m); emit(GradingSaved()); await load(_planId);
    } on ServiceException catch (e) { emit(GradingError(e.message)); }
  }
  Future<void> deleteItem(String id) async {
    emit(GradingSaving());
    try { await _service.deleteItem(id); emit(GradingSaved()); await load(_planId);
    } on ServiceException catch (e) { emit(GradingError(e.message)); }
  }

  // Symbol CRUD
  Future<void> createSymbol(SpecialGradeSymbolModel m) async {
    emit(GradingSaving());
    try { await _service.createSymbol(m); emit(GradingSaved()); await load(_planId);
    } on ServiceException catch (e) { emit(GradingError(e.message)); }
  }
  Future<void> updateSymbol(String id, SpecialGradeSymbolModel m) async {
    emit(GradingSaving());
    try { await _service.updateSymbol(id, m); emit(GradingSaved()); await load(_planId);
    } on ServiceException catch (e) { emit(GradingError(e.message)); }
  }
  Future<void> deleteSymbol(String id) async {
    emit(GradingSaving());
    try { await _service.deleteSymbol(id); emit(GradingSaved()); await load(_planId);
    } on ServiceException catch (e) { emit(GradingError(e.message)); }
  }
}
