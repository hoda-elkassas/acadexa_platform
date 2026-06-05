// file: lib/data/services/department_service.dart
import '../models/department_model.dart';
import '../models/program_model.dart';
import 'base_service.dart';

class DepartmentService extends BaseService {
  // ─── Departments ────────────────────────────────────────────────────

  Future<({List<DepartmentModel> data, int count})> getAllDepartments({
    int page = 1,
    int pageSize = 20,
    String? searchQuery,
  }) async {
    return safeCall(() async {
      final range = pageRange(page, pageSize);
      var query = client.from('departments').select();

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
            'name_ar.ilike.%$searchQuery%,code.ilike.%$searchQuery%');
      }

      final data = await query
          .order('name_ar')
          .range(range.from, range.to);

      var countQuery = client.from('departments').select('id');
      if (searchQuery != null && searchQuery.isNotEmpty) {
        countQuery = countQuery.or(
            'name_ar.ilike.%$searchQuery%,code.ilike.%$searchQuery%');
      }
      final countResult = await countQuery;

      return (
        data: (data as List)
            .map((e) =>
                DepartmentModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        count: (countResult as List).length,
      );
    }, context: 'DepartmentService.getAllDepartments');
  }

  /// All departments (no pagination — for dropdowns).
  Future<List<DepartmentModel>> getAllDepartmentsList() async {
    return safeCall(() async {
      final data = await client
          .from('departments')
          .select()
          .eq('is_active', true)
          .order('name_ar');
      return (data as List)
          .map((e) =>
              DepartmentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }, context: 'DepartmentService.getAllDepartmentsList');
  }

  Future<DepartmentModel> createDepartment(DepartmentModel model) async {
    return safeCall(() async {
      final data = await client
          .from('departments')
          .insert(model.toInsertJson())
          .select()
          .single();
      return DepartmentModel.fromJson(data);
    }, context: 'DepartmentService.createDepartment');
  }

  Future<DepartmentModel> updateDepartment(
      String id, DepartmentModel model) async {
    return safeCall(() async {
      final data = await client
          .from('departments')
          .update(model.toUpdateJson())
          .eq('id', id)
          .select()
          .single();
      return DepartmentModel.fromJson(data);
    }, context: 'DepartmentService.updateDepartment');
  }

  Future<void> deleteDepartment(String id) async {
    return safeCall(() async {
      await client.from('departments').delete().eq('id', id);
    }, context: 'DepartmentService.deleteDepartment');
  }

  // ─── Programs ───────────────────────────────────────────────────────

  Future<List<ProgramModel>> getAllProgramsList({
    String? departmentId,
  }) async {
    return safeCall(() async {
      var query = client
          .from('programs')
          .select()
          .eq('is_active', true);
      if (departmentId != null && departmentId.isNotEmpty) {
        query = query.eq('department_id', departmentId);
      }
      final data = await query.order('name_ar');
      return (data as List)
          .map((e) => ProgramModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }, context: 'DepartmentService.getAllProgramsList');
  }

  Future<ProgramModel> createProgram(ProgramModel model) async {
    return safeCall(() async {
      final data = await client
          .from('programs')
          .insert(model.toInsertJson())
          .select()
          .single();
      return ProgramModel.fromJson(data);
    }, context: 'DepartmentService.createProgram');
  }

  Future<ProgramModel> updateProgram(String id, ProgramModel model) async {
    return safeCall(() async {
      final data = await client
          .from('programs')
          .update(model.toUpdateJson())
          .eq('id', id)
          .select()
          .single();
      return ProgramModel.fromJson(data);
    }, context: 'DepartmentService.updateProgram');
  }

  Future<void> deleteProgram(String id) async {
    return safeCall(() async {
      await client.from('programs').delete().eq('id', id);
    }, context: 'DepartmentService.deleteProgram');
  }
}
