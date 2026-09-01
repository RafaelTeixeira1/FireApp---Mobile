# FireApp Mobile 🔥

Aplicativo mobile desenvolvido em Flutter para registro, geolocalização e acompanhamento de ocorrências de incêndio, com integração ao Firebase e recursos de mapas.

## Sobre o projeto

O FireApp Mobile tem como objetivo facilitar o registro de focos de incêndio por usuários em campo e apoiar a visualização de ocorrências georreferenciadas. O aplicativo reúne autenticação, localização, mapas, armazenamento de dados e recursos de notificação em uma única solução móvel.

O projeto integra o ecossistema FireApp e corresponde à versão mobile da aplicação.

## Principais funcionalidades

- Cadastro e autenticação de usuários.
- Recuperação de senha.
- Registro e consulta de ocorrências de incêndio.
- Captura e uso da localização do dispositivo.
- Visualização de pontos e ocorrências em mapa interativo.
- Compartilhamento e armazenamento de coordenadas geográficas.
- Suporte a imagens associadas às ocorrências.
- Controle de permissões do dispositivo.
- Estrutura para notificações locais.
- Navegação entre telas de alertas, informações, ajuda e mapa.

## Tecnologias

### Aplicação

- Flutter
- Dart
- Provider
- Shared Preferences

### Firebase

- Firebase Core
- Firebase Authentication
- Firebase Realtime Database
- Cloud Firestore
- Firebase Storage

### Mapas e geolocalização

- flutter_map
- OpenStreetMap
- Geolocator
- Location
- LatLong2
- Flutter Map Location Marker
- Flutter Polyline Points
- Flutter Compass

### Recursos do dispositivo

- Permission Handler
- Image Picker
- Flutter Local Notifications

## Estrutura principal

```text
FireApp---Mobile/
├── android/              # Configurações da aplicação Android
├── assets/               # Imagens e identidade visual
├── ios/                  # Configurações da aplicação iOS
├── lib/                  # Código-fonte Flutter
├── web/                  # Suporte Flutter Web
├── linux/                # Suporte Linux
├── macos/                # Suporte macOS
├── windows/              # Suporte Windows
├── FIREBASE_SETUP.md     # Instruções de configuração do Firebase
├── database.rules.json   # Regras do Firebase Realtime Database
├── pubspec.yaml          # Dependências e configuração do projeto
└── README.md
```

## Pré-requisitos

Antes de executar o projeto, tenha instalado:

- Flutter SDK compatível com Dart 3.8 ou superior.
- Android Studio ou outra IDE compatível com Flutter.
- Um dispositivo físico ou emulador configurado.
- Projeto Firebase configurado para a aplicação.

Verifique a instalação do Flutter com:

```bash
flutter doctor
```

## Como executar

Clone o repositório:

```bash
git clone https://github.com/RafaelTeixeira1/FireApp---Mobile.git
cd FireApp---Mobile
```

Instale as dependências:

```bash
flutter pub get
```

Configure o Firebase conforme as instruções disponíveis em:

```text
FIREBASE_SETUP.md
```

Execute a aplicação:

```bash
flutter run
```

Para listar os dispositivos disponíveis:

```bash
flutter devices
```

## Configuração do Firebase

O projeto utiliza serviços Firebase para autenticação, persistência e armazenamento. As credenciais e arquivos específicos de cada ambiente não devem ser versionados quando contiverem informações sensíveis.

Consulte `FIREBASE_SETUP.md` para os passos de configuração necessários.

## Estado do projeto

Projeto em desenvolvimento.

Entre as evoluções previstas estão o aprimoramento do fluxo de registro de ocorrências, recursos de alerta por proximidade, uso de informações meteorológicas e expansão das funcionalidades destinadas ao acompanhamento das ocorrências.

## Contexto acadêmico

O FireApp também é utilizado como objeto de estudo acadêmico relacionado à engenharia de requisitos, prototipagem e desenvolvimento de soluções móveis voltadas ao apoio no monitoramento de incêndios.

## Autores

- Rafael Teixeira
- Jhannyfer Biângulo
