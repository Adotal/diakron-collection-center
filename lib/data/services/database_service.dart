import 'dart:io';

import 'package:diakron_collection_center/models/user/collection_center.dart';
import 'package:diakron_collection_center/utils/result.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final _logger = Logger();

  Future<ValidationStatus> getValidationStatus(String userId) async {
    _logger.w('User id: $userId');
    try {
      // 1. Consultamos solo la columna necesaria para ahorrar ancho de banda
      final data = await _supabase
          .from('collection_centers')
          .select('validation_status')
          .eq('id', userId)
          .single();

      // 2. Mapeamos el String de la DB al Enum que creaste
      final String statusRaw = data['validation_status'] ?? 'UPLOADING';
      _logger.w(data['validation_status']);

      // Usamos el método estático que ya tienes en tu modelo
      return CollectionCenter.parseStatus(statusRaw);
    } catch (e) {
      _logger.e('User id: $userId');
      // Si hay error (ej. no existe el registro), asumimos que debe subir archivos
      return ValidationStatus.uploading;
    }
  }

  /// Obtiene un registro único por ID de cualquier tabla
  Future<Map<String, dynamic>> getRecordById({
    required String table,
    required String id,
  }) async {
    return await _supabase
        .from(table)
        .select()
        .eq('id', id)
        .single(); // Trae un solo objeto, no una lista
  }

  /// Actualiza datos en una tabla específica
  Future<Result<void>> uploadUserData({
    required String table,
    required String id,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _supabase.from(table).update(data).eq('id', id);
      return Result.ok(null);
    } catch (e) {
      // This will catch if the table doesn't exist or a constraint is violated
      return Result.error(e as Exception);
    }
  }

  // --- Operaciones de Storage (Archivos) ---

  /// Sube un archivo y retorna la ruta interna (path)
  Future<String?> uploadFile({
    required String id,
    required String fileName,
    required File file,
  }) async {
    try {
      // The path MUST start with the userId for the RLS to pass
      final String path = '$id/$fileName';
      // Usamos 'upsert: true' por si el usuario reintenta una subida fallida
      final String fullPath = await _supabase.storage
          .from('diakron_storage_private')
          .upload(path, file, fileOptions: const FileOptions(upsert: true));

      return fullPath; // Retornamos el path para guardarlo en la DB
    } catch (e) {
      _logger.e("Upload failed: $e");
      return null;
    }
  }

  /// (Opcional) Escucha cambios en tiempo real de un registro
  Stream<Map<String, dynamic>> subscribeToRecord({
    required String table,
    required String id,
  }) {
    return _supabase
        .from(table)
        .stream(primaryKey: ['id'])
        .eq('id', id)
        .map((list) => list.first);
  }
}
