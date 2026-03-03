import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../model/user_profile_model.dart';

/// Serviço para gerenciar o perfil do usuário no Firebase
class UserProfileService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Nó de usuários no Realtime Database
  static const String collection = 'usuarios';

  /// Obter ou criar perfil do usuário atual
  Future<UserProfileModel> obterPerfil() async {
    try {
      final usuarioId = _auth.currentUser?.uid;
      final email = _auth.currentUser?.email;

      debugPrint('👤 Obtendo perfil do usuário: $usuarioId');

      if (usuarioId == null || email == null) {
        throw Exception('Usuário não autenticado');
      }

      final ref = _database.ref('$collection/$usuarioId');
      
      try {
        final snapshot = await ref.get();

        if (snapshot.exists && snapshot.value != null) {
          debugPrint('✅ Perfil encontrado no Firebase');
          
          // Validar que o valor é um Map
          final value = snapshot.value;
          if (value is Map) {
            try {
              final map = Map<String, dynamic>.from(value as Map);
              return UserProfileModel.fromMap(map);
            } catch (e) {
              debugPrint('⚠️ Erro ao converter dados: $e');
              // Criar novo perfil se conversão falhar
            }
          } else {
            debugPrint('⚠️ Dados no Firebase não são um Map: ${value.runtimeType}');
            // Limpar dados inválidos
            await ref.remove();
          }
        }
      } catch (e) {
        debugPrint('⚠️ Erro ao buscar dados (pode ser permissão): $e');
        // Se houver erro de permissão ou outro, tentamos criar o perfil
      }

      // Criar novo perfil (primeira vez ou após limpar dados corrompidos)
      debugPrint('📝 Criando novo perfil para o usuário');
      final novoPerfil = UserProfileModel(
        uid: usuarioId,
        email: email,
        dataCriacao: DateTime.now(),
        dataUltimaAtualizacao: DateTime.now(),
      );

      try {
        await _database.ref('$collection/$usuarioId').set(novoPerfil.toMap());
        debugPrint('✅ Novo perfil criado com sucesso');
      } catch (e) {
        debugPrint('❌ Erro ao criar perfil no Firebase: $e');
        debugPrint('💡 Verifique as regras do Firebase Realtime Database');
        // Mesmo com erro no Firebase, retornar o perfil local
      }

      return novoPerfil;
    } catch (e) {
      debugPrint('❌ Erro ao obter perfil: $e');
      rethrow;
    }
  }

  /// Atualizar perfil do usuário
  Future<void> atualizarPerfil(UserProfileModel perfil) async {
    try {
      final usuarioId = _auth.currentUser?.uid;

      debugPrint('🔄 Atualizando perfil do usuário: $usuarioId');

      if (usuarioId == null) {
        throw Exception('Usuário não autenticado');
      }

      final perfilAtualizado = perfil.copyWith(
        dataUltimaAtualizacao: DateTime.now(),
      );

      await _database
          .ref('$collection/$usuarioId')
          .update(perfilAtualizado.toMap());

      debugPrint('✅ Perfil atualizado com sucesso');
    } catch (e) {
      debugPrint('❌ Erro ao atualizar perfil: $e');
      if (e.toString().contains('permission') || e.toString().contains('Permission')) {
        throw Exception('Sem permissão para atualizar dados. Verifique as regras do Firebase.');
      }
      rethrow;
    }
  }

  /// Atualizar apenas o nome do usuário
  Future<void> atualizarNome(String nome) async {
    try {
      final usuarioId = _auth.currentUser?.uid;

      debugPrint('📝 Atualizando nome do usuário: $nome');

      if (usuarioId == null) {
        throw Exception('Usuário não autenticado');
      }

      await _database.ref('$collection/$usuarioId/nome').set(nome);
      await _database
          .ref('$collection/$usuarioId/dataUltimaAtualizacao')
          .set(DateTime.now().toIso8601String());

      debugPrint('✅ Nome atualizado com sucesso');
    } catch (e) {
      debugPrint('❌ Erro ao atualizar nome: $e');
      rethrow;
    }
  }

  /// Atualizar telefone
  Future<void> atualizarTelefone(String telefone) async {
    try {
      final usuarioId = _auth.currentUser?.uid;

      if (usuarioId == null) {
        throw Exception('Usuário não autenticado');
      }

      await _database.ref('$collection/$usuarioId/telefone').set(telefone);
      await _database
          .ref('$collection/$usuarioId/dataUltimaAtualizacao')
          .set(DateTime.now().toIso8601String());

      debugPrint('✅ Telefone atualizado com sucesso');
    } catch (e) {
      debugPrint('❌ Erro ao atualizar telefone: $e');
      rethrow;
    }
  }

  /// Atualizar localização
  Future<void> atualizarLocalizacao(String localizacao) async {
    try {
      final usuarioId = _auth.currentUser?.uid;

      if (usuarioId == null) {
        throw Exception('Usuário não autenticado');
      }

      await _database
          .ref('$collection/$usuarioId/localizacao')
          .set(localizacao);
      await _database
          .ref('$collection/$usuarioId/dataUltimaAtualizacao')
          .set(DateTime.now().toIso8601String());

      debugPrint('✅ Localização atualizada com sucesso');
    } catch (e) {
      debugPrint('❌ Erro ao atualizar localização: $e');
      rethrow;
    }
  }

  /// Atualizar preferência de notificações
  Future<void> atualizarPreferenciaNotificacoes(bool ativo) async {
    try {
      final usuarioId = _auth.currentUser?.uid;

      if (usuarioId == null) {
        throw Exception('Usuário não autenticado');
      }

      await _database.ref('$collection/$usuarioId').update({
        'receberNotificacoes': ativo,
        'dataUltimaAtualizacao': DateTime.now().toIso8601String(),
      });

      debugPrint('✅ Preferência de notificações atualizada');
    } catch (e) {
      debugPrint('❌ Erro ao atualizar preferência: $e');
      if (e.toString().contains('permission') || e.toString().contains('Permission')) {
        throw Exception('Sem permissão. Configure as regras do Firebase.');
      }
      rethrow;
    }
  }

  /// Atualizar preferência de alertas
  Future<void> atualizarPreferenciaAlertas(bool ativo) async {
    try {
      final usuarioId = _auth.currentUser?.uid;

      if (usuarioId == null) {
        throw Exception('Usuário não autenticado');
      }

      await _database.ref('$collection/$usuarioId').update({
        'receberAlertas': ativo,
        'dataUltimaAtualizacao': DateTime.now().toIso8601String(),
      });

      debugPrint('✅ Preferência de alertas atualizada');
    } catch (e) {
      debugPrint('❌ Erro ao atualizar preferência: $e');
      if (e.toString().contains('permission') || e.toString().contains('Permission')) {
        throw Exception('Sem permissão. Configure as regras do Firebase.');
      }
      rethrow;
    }
  }

  /// Logout seguro
  Future<void> logout() async {
    try {
      debugPrint('👋 Realizando logout');
      await _auth.signOut();
      debugPrint('✅ Logout realizado com sucesso');
    } catch (e) {
      debugPrint('❌ Erro ao fazer logout: $e');
      rethrow;
    }
  }

  /// Deletar conta (com cuidado!)
  Future<void> deletarConta() async {
    try {
      final usuarioId = _auth.currentUser?.uid;

      debugPrint('⚠️ Deletando conta do usuário: $usuarioId');

      if (usuarioId == null) {
        throw Exception('Usuário não autenticado');
      }

      // Deletar dados do usuario no Realtime Database
      await _database.ref('$collection/$usuarioId').remove();

      // Deletar conta do firebase
      await _auth.currentUser?.delete();

      debugPrint('✅ Conta deletada com sucesso');
    } catch (e) {
      debugPrint('❌ Erro ao deletar conta: $e');
      rethrow;
    }
  }
}
