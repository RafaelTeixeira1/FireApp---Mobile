/// Modelo de dados para o perfil do usuário
class UserProfileModel {
  final String uid;
  final String email;
  final String? nome;
  final String? fotoPerfil;
  final String? telefone;
  final String? localizacao;
  final bool receberNotificacoes;
  final bool receberAlertas;
  final DateTime? dataCriacao;
  final DateTime? dataUltimaAtualizacao;

  UserProfileModel({
    required this.uid,
    required this.email,
    this.nome,
    this.fotoPerfil,
    this.telefone,
    this.localizacao,
    this.receberNotificacoes = true,
    this.receberAlertas = true,
    this.dataCriacao,
    this.dataUltimaAtualizacao,
  });

  /// Converter para Map para salvar no Firebase
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'nome': nome,
      'fotoPerfil': fotoPerfil,
      'telefone': telefone,
      'localizacao': localizacao,
      'receberNotificacoes': receberNotificacoes,
      'receberAlertas': receberAlertas,
      'dataCriacao': dataCriacao?.toIso8601String(),
      'dataUltimaAtualizacao': dataUltimaAtualizacao?.toIso8601String(),
    };
  }

  /// Criar instância a partir de Map (Firebase)
  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      nome: map['nome'],
      fotoPerfil: map['fotoPerfil'],
      telefone: map['telefone'],
      localizacao: map['localizacao'],
      receberNotificacoes: map['receberNotificacoes'] ?? true,
      receberAlertas: map['receberAlertas'] ?? true,
      dataCriacao: map['dataCriacao'] != null
          ? DateTime.parse(map['dataCriacao'] as String)
          : null,
      dataUltimaAtualizacao: map['dataUltimaAtualizacao'] != null
          ? DateTime.parse(map['dataUltimaAtualizacao'] as String)
          : null,
    );
  }

  /// Copiar modelo com alterações
  UserProfileModel copyWith({
    String? uid,
    String? email,
    String? nome,
    String? fotoPerfil,
    String? telefone,
    String? localizacao,
    bool? receberNotificacoes,
    bool? receberAlertas,
    DateTime? dataCriacao,
    DateTime? dataUltimaAtualizacao,
  }) {
    return UserProfileModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      nome: nome ?? this.nome,
      fotoPerfil: fotoPerfil ?? this.fotoPerfil,
      telefone: telefone ?? this.telefone,
      localizacao: localizacao ?? this.localizacao,
      receberNotificacoes: receberNotificacoes ?? this.receberNotificacoes,
      receberAlertas: receberAlertas ?? this.receberAlertas,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataUltimaAtualizacao:
          dataUltimaAtualizacao ?? this.dataUltimaAtualizacao,
    );
  }
}
