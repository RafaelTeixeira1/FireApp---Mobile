import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../model/incendio_model.dart';

class IncendioService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Nó de incêndios no Realtime Database
  static const String collection = 'incendios';

  /// Salvar novo incêndio
  Future<String> salvarIncendio(IncendioModel incendio) async {
    try {
      final usuarioId = _auth.currentUser?.uid;
      debugPrint('🔥 Salvando incêndio - Usuário ID: $usuarioId');

      if (usuarioId == null) {
        throw Exception(
          'Usuário não autenticado. Faça login antes de registrar um incêndio.',
        );
      }

      debugPrint('📤 Enviando para Realtime Database no nó "$collection"...');

      final docData = {
        'descricao': incendio.descricao,
        'nivelRisco': incendio.nivelRisco,
        'areaPoligono': incendio.areaPoligono
            .map((e) => {'latitude': e.latitude, 'longitude': e.longitude})
            .toList(),
        'latitude': incendio.latitude ?? 0.0,
        'longitude': incendio.longitude ?? 0.0,
        'direcao': incendio.direcao,
        'distanciaMetros': incendio.distanciaMetros,
        'criadoPor': usuarioId,
        'criadoEm': ServerValue.timestamp,
        'fotoUrl': incendio.fotoUrl,
      };

      debugPrint('📋 Dados a enviar: $docData');

      final ref = _database.ref(collection).push();
      await ref.set(docData);
      final id = ref.key ?? '';
      debugPrint('✅ Incêndio salvo com sucesso! ID: $id');
      return id;
    } catch (e) {
      debugPrint('❌ Erro ao salvar incêndio: $e');
      rethrow;
    }
  }

  /// Listar todos os incêndios (sem ordenação para evitar erro de índice)
  Future<List<IncendioModel>> listarIncendios() async {
    try {
      final snapshot = await _database.ref(collection).get();
      final list = _mapSnapshotToList(snapshot);
      // Ordenar em memória por data (mais recente primeiro)
      list.sort((a, b) => b.criadoEm.compareTo(a.criadoEm));
      return list;
    } catch (e) {
      debugPrint('❌ Erro ao listar incêndios: $e');
      throw Exception('Erro ao listar incêndios: $e');
    }
  }

  /// Listar incêndios em tempo real (stream) - SEM ORDENAÇÃO para evitar erro
  Stream<List<IncendioModel>> streamIncendios() {
    debugPrint('📡 [IncendioService] Stream aberto para nó "incendios" (RTDB)');
    return _database
        .ref(collection)
        .onValue
        .map((event) {
          final list = _mapSnapshotToList(event.snapshot);
          // Ordenar em memória por data (mais recente primeiro)
          list.sort((a, b) => b.criadoEm.compareTo(a.criadoEm));
          debugPrint(
            '📊 [IncendioService] Snapshot recebido com ${list.length} incêndios',
          );
          for (final inc in list) {
            debugPrint(
              '   📍 ${inc.descricao} | Risco: ${inc.nivelRisco} | Polígono: ${inc.areaPoligono.length} pts',
            );
          }
          return list;
        })
        .handleError((e) {
          debugPrint('❌ [IncendioService] ERRO no stream: $e');
        });
  }

  /// Obter incêndio por ID
  Future<IncendioModel?> obterIncendio(String id) async {
    try {
      final doc = await _database.ref('$collection/$id').get();
      if (!doc.exists) return null;
      final data = _normalizeMap(doc.value);
      return IncendioModel.fromMap(doc.key ?? '', data);
    } catch (e) {
      throw Exception('Erro ao obter incêndio: $e');
    }
  }

  /// Atualizar incêndio
  Future<void> atualizarIncendio(String id, IncendioModel incendio) async {
    try {
      await _database.ref('$collection/$id').update({
        'descricao': incendio.descricao,
        'nivelRisco': incendio.nivelRisco,
        'areaPoligono': incendio.areaPoligono
            .map((e) => {'latitude': e.latitude, 'longitude': e.longitude})
            .toList(),
        'latitude': incendio.latitude ?? 0.0,
        'longitude': incendio.longitude ?? 0.0,
        'direcao': incendio.direcao,
        'distanciaMetros': incendio.distanciaMetros,
        'atualizado': ServerValue.timestamp,
        'fotoUrl': incendio.fotoUrl,
      });
    } catch (e) {
      throw Exception('Erro ao atualizar incêndio: $e');
    }
  }

  /// Deletar incêndio
  Future<void> deletarIncendio(String id) async {
    try {
      await _database.ref('$collection/$id').remove();
    } catch (e) {
      throw Exception('Erro ao deletar incêndio: $e');
    }
  }

  /// Listar incêndios do usuário atual
  Future<List<IncendioModel>> listarMeusIncendios() async {
    try {
      final usuarioId = _auth.currentUser?.uid;
      if (usuarioId == null) {
        throw Exception('Usuário não autenticado');
      }

      final snapshot = await _database.ref(collection).get();
      final list = _mapSnapshotToList(
        snapshot,
      ).where((inc) => inc.criadoPor == usuarioId).toList();
      list.sort((a, b) => b.criadoEm.compareTo(a.criadoEm));
      return list;
    } catch (e) {
      debugPrint('❌ Erro ao listar meus incêndios: $e');
      throw Exception('Erro ao listar meus incêndios: $e');
    }
  }

  /// Stream de incêndios do usuário atual
  Stream<List<IncendioModel>> streamMeusIncendios() {
    final usuarioId = _auth.currentUser?.uid;
    debugPrint('👤 Stream Meus Alertas - Usuário ID: $usuarioId');

    if (usuarioId == null) {
      debugPrint('⚠️ Usuário não autenticado para stream');
      return Stream.error('Usuário não autenticado');
    }

    return _database
        .ref(collection)
        .onValue
        .map((event) {
          final allIncendios = _mapSnapshotToList(event.snapshot);
          final meusList = allIncendios
              .where((inc) => inc.criadoPor == usuarioId)
              .toList();
          meusList.sort((a, b) => b.criadoEm.compareTo(a.criadoEm));
          debugPrint('📊 [IncendioService] Meus incêndios: ${meusList.length}');
          return meusList;
        })
        .handleError((e) {
          debugPrint('❌ Erro no stream de meus incêndios: $e');
        });
  }

  /// Converter snapshot para lista de IncendioModel
  List<IncendioModel> _mapSnapshotToList(DataSnapshot snapshot) {
    final list = <IncendioModel>[];
    for (var child in snapshot.children) {
      try {
        final data = _normalizeMap(child.value);

        // Log da foto se existir
        if (data['fotoUrl'] != null) {
          final fotoSize = (data['fotoUrl'] as String).length;
          debugPrint(
            '📸 [IncendioService] Incêndio ${child.key}: Foto encontrada (${(fotoSize / 1024).toStringAsFixed(2)} KB)',
          );
        } else {
          debugPrint(
            '📸 [IncendioService] Incêndio ${child.key}: Sem foto (null)',
          );
        }

        final incendio = IncendioModel.fromMap(child.key ?? '', data);
        list.add(incendio);
      } catch (e) {
        debugPrint(
          '⚠️ [IncendioService] Erro ao parsear incêndio ${child.key}: $e',
        );
      }
    }
    return list;
  }

  /// Normalizar map do Firebase (converte Object para `Map<String, dynamic>`)
  Map<String, dynamic> _normalizeMap(dynamic raw) {
    if (raw is Map) {
      return raw.map((key, value) => MapEntry(key.toString(), value));
    }
    return {};
  }
}
