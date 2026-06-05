// file: lib/data/services/academic_rules_service.dart
import '../models/academic_load_rules_model.dart';
import '../models/graduation_requirements_model.dart';
import 'base_service.dart';

class AcademicRulesService extends BaseService {
  // ─── Academic Load Rules ────────────────────────────────────────────
  Future<AcademicLoadRulesModel?> getLoadRules(String planId) async {
    return safeCall(() async {
      final data = await client.from('academic_load_rules')
          .select().eq('plan_id', planId).maybeSingle();
      if (data == null) return null;
      return AcademicLoadRulesModel.fromJson(data);
    }, context: 'AcademicRulesService.getLoadRules');
  }

  Future<AcademicLoadRulesModel> upsertLoadRules(
      AcademicLoadRulesModel model) async {
    return safeCall(() async {
      final data = await client.from('academic_load_rules')
          .upsert(model.toInsertJson(), onConflict: 'plan_id')
          .select().single();
      return AcademicLoadRulesModel.fromJson(data);
    }, context: 'AcademicRulesService.upsertLoadRules');
  }

  Future<void> deleteLoadRules(String id) async {
    return safeCall(() async {
      await client.from('academic_load_rules').delete().eq('id', id);
    }, context: 'AcademicRulesService.deleteLoadRules');
  }

  // ─── Graduation Requirements ────────────────────────────────────────
  Future<GraduationRequirementsModel?> getGradReqs(String planId) async {
    return safeCall(() async {
      final data = await client.from('graduation_requirements')
          .select().eq('plan_id', planId).maybeSingle();
      if (data == null) return null;
      return GraduationRequirementsModel.fromJson(data);
    }, context: 'AcademicRulesService.getGradReqs');
  }

  Future<GraduationRequirementsModel> upsertGradReqs(
      GraduationRequirementsModel model) async {
    return safeCall(() async {
      final data = await client.from('graduation_requirements')
          .upsert(model.toInsertJson(), onConflict: 'plan_id')
          .select().single();
      return GraduationRequirementsModel.fromJson(data);
    }, context: 'AcademicRulesService.upsertGradReqs');
  }
}
