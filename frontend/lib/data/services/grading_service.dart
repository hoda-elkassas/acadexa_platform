// file: lib/data/services/grading_service.dart
import '../models/grading_scale_model.dart';
import '../models/special_grade_symbol_model.dart';
import 'base_service.dart';

class GradingService extends BaseService {
  // ─── Grading Scales ─────────────────────────────────────────────────
  Future<List<GradingScaleModel>> getScalesByPlanId(String planId) async {
    return safeCall(() async {
      final data = await client.from('grading_scales')
          .select('*, grade_scale_items(*)')
          .eq('plan_id', planId).order('name_ar');
      return (data as List).map((e) =>
          GradingScaleModel.fromJson(e as Map<String, dynamic>)).toList();
    }, context: 'GradingService.getScalesByPlanId');
  }

  Future<GradingScaleModel> createScale(GradingScaleModel model) async {
    return safeCall(() async {
      final data = await client.from('grading_scales')
          .insert(model.toInsertJson()).select('*, grade_scale_items(*)').single();
      return GradingScaleModel.fromJson(data);
    }, context: 'GradingService.createScale');
  }

  Future<GradingScaleModel> updateScale(String id, GradingScaleModel model) async {
    return safeCall(() async {
      final data = await client.from('grading_scales')
          .update(model.toUpdateJson()).eq('id', id)
          .select('*, grade_scale_items(*)').single();
      return GradingScaleModel.fromJson(data);
    }, context: 'GradingService.updateScale');
  }

  Future<void> deleteScale(String id) async {
    return safeCall(() async {
      await client.from('grade_scale_items').delete().eq('grade_scale_id', id);
      await client.from('grading_scales').delete().eq('id', id);
    }, context: 'GradingService.deleteScale');
  }

  // ─── Grade Scale Items ──────────────────────────────────────────────
  Future<GradeScaleItemModel> createItem(GradeScaleItemModel model) async {
    return safeCall(() async {
      final data = await client.from('grade_scale_items')
          .insert(model.toInsertJson()).select().single();
      return GradeScaleItemModel.fromJson(data);
    }, context: 'GradingService.createItem');
  }

  Future<GradeScaleItemModel> updateItem(String id, GradeScaleItemModel model) async {
    return safeCall(() async {
      final data = await client.from('grade_scale_items')
          .update(model.toUpdateJson()).eq('id', id).select().single();
      return GradeScaleItemModel.fromJson(data);
    }, context: 'GradingService.updateItem');
  }

  Future<void> deleteItem(String id) async {
    return safeCall(() async {
      await client.from('grade_scale_items').delete().eq('id', id);
    }, context: 'GradingService.deleteItem');
  }

  // ─── Special Grade Symbols ──────────────────────────────────────────
  Future<List<SpecialGradeSymbolModel>> getSymbolsByPlanId(String planId) async {
    return safeCall(() async {
      final data = await client.from('special_grade_symbols')
          .select().eq('plan_id', planId).order('symbol');
      return (data as List).map((e) =>
          SpecialGradeSymbolModel.fromJson(e as Map<String, dynamic>)).toList();
    }, context: 'GradingService.getSymbolsByPlanId');
  }

  Future<SpecialGradeSymbolModel> createSymbol(SpecialGradeSymbolModel model) async {
    return safeCall(() async {
      final data = await client.from('special_grade_symbols')
          .insert(model.toInsertJson()).select().single();
      return SpecialGradeSymbolModel.fromJson(data);
    }, context: 'GradingService.createSymbol');
  }

  Future<SpecialGradeSymbolModel> updateSymbol(
      String id, SpecialGradeSymbolModel model) async {
    return safeCall(() async {
      final data = await client.from('special_grade_symbols')
          .update(model.toUpdateJson()).eq('id', id).select().single();
      return SpecialGradeSymbolModel.fromJson(data);
    }, context: 'GradingService.updateSymbol');
  }

  Future<void> deleteSymbol(String id) async {
    return safeCall(() async {
      await client.from('special_grade_symbols').delete().eq('id', id);
    }, context: 'GradingService.deleteSymbol');
  }
}
