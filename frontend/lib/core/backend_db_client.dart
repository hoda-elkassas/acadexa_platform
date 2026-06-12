import 'dart:async';
import 'api_client.dart';

class BackendDbClient {
  final ApiClient apiClient;

  BackendDbClient(this.apiClient);

  static final BackendDbClient instance = BackendDbClient(ApiClient.instance);

  BackendQueryBuilder from(String table) {
    return BackendQueryBuilder(apiClient, table);
  }
}

class BackendQueryBuilder implements Future<List<Map<String, dynamic>>> {
  final ApiClient apiClient;
  final String table;
  String selectFields = '*';
  final List<Map<String, dynamic>> filters = [];
  int? limitValue;
  Map<String, dynamic>? updateData;
  bool isDelete = false;

  BackendQueryBuilder(this.apiClient, this.table);

  BackendQueryBuilder select([String fields = '*']) {
    selectFields = fields;
    return this;
  }

  BackendQueryBuilder eq(String column, dynamic value) {
    filters.add({
      'type': 'eq',
      'column': column,
      'value': value,
    });
    return this;
  }

  BackendQueryBuilder neq(String column, dynamic value) {
    filters.add({
      'type': 'neq',
      'column': column,
      'value': value,
    });
    return this;
  }

  BackendQueryBuilder gt(String column, dynamic value) {
    filters.add({
      'type': 'gt',
      'column': column,
      'value': value,
    });
    return this;
  }

  BackendQueryBuilder gte(String column, dynamic value) {
    filters.add({
      'type': 'gte',
      'column': column,
      'value': value,
    });
    return this;
  }

  BackendQueryBuilder lt(String column, dynamic value) {
    filters.add({
      'type': 'lt',
      'column': column,
      'value': value,
    });
    return this;
  }

  BackendQueryBuilder lte(String column, dynamic value) {
    filters.add({
      'type': 'lte',
      'column': column,
      'value': value,
    });
    return this;
  }

  BackendQueryBuilder order(String column, {bool ascending = true}) {
    filters.add({
      'type': 'order',
      'column': column,
      'desc': !ascending,
    });
    return this;
  }

  BackendQueryBuilder limit(int limit) {
    limitValue = limit;
    return this;
  }

  BackendQueryBuilder update(Map<String, dynamic> data) {
    updateData = data;
    return this;
  }

  BackendQueryBuilder delete() {
    isDelete = true;
    return this;
  }

  Future<List<Map<String, dynamic>>> insert(dynamic data) async {
    final payload = {
      'table': table,
      'data': data,
    };
    final res = await apiClient.post('/db/insert', body: payload);
    final rawData = res['data'] ?? res;
    if (rawData is List) {
      return List<Map<String, dynamic>>.from(
        rawData.map((e) => Map<String, dynamic>.from(e as Map)),
      );
    }
    if (rawData is Map) {
      return [Map<String, dynamic>.from(rawData)];
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> execute() async {
    if (isDelete) {
      final payload = {
        'table': table,
        'filters': filters,
      };
      final res = await apiClient.post('/db/delete', body: payload);
      final rawData = res['data'] ?? res;
      if (rawData is List) {
        return List<Map<String, dynamic>>.from(
          rawData.map((e) => Map<String, dynamic>.from(e as Map)),
        );
      }
      if (rawData is Map) {
        return [Map<String, dynamic>.from(rawData)];
      }
      return [];
    }

    if (updateData != null) {
      final payload = {
        'table': table,
        'filters': filters,
        'data': updateData!,
      };
      final res = await apiClient.post('/db/update', body: payload);
      final rawData = res['data'] ?? res;
      if (rawData is List) {
        return List<Map<String, dynamic>>.from(
          rawData.map((e) => Map<String, dynamic>.from(e as Map)),
        );
      }
      if (rawData is Map) {
        return [Map<String, dynamic>.from(rawData)];
      }
      return [];
    }

    final payload = {
      'table': table,
      'select': selectFields,
      'filters': filters,
      if (limitValue != null) 'limit': limitValue,
    };
    final res = await apiClient.post('/db/query', body: payload);
    final rawData = res['data'] ?? res;
    if (rawData is List) {
      return List<Map<String, dynamic>>.from(
        rawData.map((e) => Map<String, dynamic>.from(e as Map)),
      );
    }
    if (rawData is Map) {
      return [Map<String, dynamic>.from(rawData)];
    }
    return [];
  }

  Future<Map<String, dynamic>?> maybeSingle() async {
    final list = await execute();
    return list.isNotEmpty ? list.first : null;
  }

  Future<Map<String, dynamic>> single() async {
    final list = await execute();
    if (list.isEmpty) {
      throw Exception('No records found');
    }
    return list.first;
  }

  // Future implementation
  @override
  Future<List<Map<String, dynamic>>> timeout(Duration timeLimit, {FutureOr<List<Map<String, dynamic>>> Function()? onTimeout}) {
    return execute().timeout(timeLimit, onTimeout: onTimeout);
  }

  @override
  Future<List<Map<String, dynamic>>> catchError(Function onError, {bool Function(Object error)? test}) {
    return execute().catchError(onError, test: test);
  }

  @override
  Future<R> then<R>(FutureOr<R> Function(List<Map<String, dynamic>> value) onValue, {Function? onError}) {
    return execute().then(onValue, onError: onError);
  }

  @override
  Future<List<Map<String, dynamic>>> whenComplete(FutureOr<void> Function() action) {
    return execute().whenComplete(action);
  }

  @override
  Stream<List<Map<String, dynamic>>> asStream() {
    return execute().asStream();
  }
}
