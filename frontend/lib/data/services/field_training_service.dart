// file: lib/data/services/field_training_service.dart
import '../models/field_training_rules_model.dart';
import 'base_service.dart';

class FieldTrainingService extends BaseService {
  Future<FieldTrainingRulesModel?> getByPlanId(String planId) async {
    return safeCall(() async {
      final data = await client.from('field_training_rules')
          .select().eq('plan_id', planId).maybeSingle();
      if (data == null) return null;
      return FieldTrainingRulesModel.fromJson(data);
    }, context: 'FieldTrainingService.getByPlanId');
  }

  Future<FieldTrainingRulesModel> upsert(
      FieldTrainingRulesModel model) async {
    return safeCall(() async {
      final data = await client.from('field_training_rules')
          .upsert(model.toInsertJson(), onConflict: 'plan_id')
          .select().single();
      return FieldTrainingRulesModel.fromJson(data);
    }, context: 'FieldTrainingService.upsert');
  }

  Future<void> delete(String id) async {
    return safeCall(() async {
      await client.from('field_training_rules').delete().eq('id', id);
    }, context: 'FieldTrainingService.delete');
  }
}
