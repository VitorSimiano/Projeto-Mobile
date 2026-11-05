# CineFinder

Aplicativo Flutter para descobrir e consultar filmes e séries, desenvolvido como trabalho acadêmico sobre **consumo de API REST**. Os dados vêm da API do [TMDB (The Movie Database)](https://developer.themoviedb.org/).

O projeto demonstra requisições HTTP reais, interpretação de JSON, métodos assíncronos (`async`/`await`), apresentação de dados em interface mobile e tratamento de erros e estados de carregamento.

> Este produto usa a API do TMDB, mas não é endossado nem certificado pelo TMDB.

## Funcionalidades

A tela inicial reúne o logo, a barra de pesquisa, um banner de destaque e carrosséis de filmes populares, filmes mais bem avaliados e séries populares. As abas **Filmes** (populares, mais bem avaliados, em cartaz) e **Séries** (populares, mais bem avaliadas) exibem grades com rolagem infinita, buscando a próxima página da API conforme o usuário rola.

A pesquisa consulta a API a cada busca (com debounce de 500 ms), permite alternar entre filmes e séries e abre os detalhes ao tocar em um resultado. A tela de detalhes mostra pôster, imagem de fundo, título, nota, data, gêneros, sinopse e idioma original, além da duração (filmes) ou do número de temporadas e episódios (séries). Os favoritos são salvos com `shared_preferences` e continuam disponíveis depois que o app é fechado.

## Como executar

Você precisa do Flutter 3.24 ou superior (Dart 3.3+).

### 1. Obter a chave do TMDB

Crie uma conta gratuita em https://www.themoviedb.org/, abra **Configurações > API** e solicite uma chave (uso pessoal/educacional). O app aceita tanto a **Chave da API (v3)** quanto o **Token de Leitura da API (v4)**.

### 2. Gerar os arquivos de plataforma

O repositório traz o código-fonte (`lib/`). As pastas `android/`, `ios/` etc. são geradas pelo próprio Flutter:

```bash
flutter create . --project-name cinefinder --org com.cinefinder
flutter pub get
```

### 3. Configurar a chave localmente

```bash
cp .env.example .env
```

Abra o `.env` e substitua `sua_chave_aqui` pela sua chave:

```text
TMDB_API_KEY=cole_sua_chave_aqui
```

O `.env` está no `.gitignore`, então a chave não vai para o GitHub. Apenas o `.env.example` (sem credenciais) é versionado. O arquivo precisa existir antes de rodar, porque o `pubspec.yaml` o declara como asset.

### 4. Permissão de internet (Android)

Builds de debug já têm acesso à internet. Para gerar um APK de release, confirme que o arquivo `android/app/src/main/AndroidManifest.xml` contém, dentro de `<manifest>`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

### 5. Rodar

```bash
flutter run
```

Para rodar os testes: `flutter test`.

## Estrutura do projeto

```text
lib/
├── main.dart                    # inicialização (.env, favoritos) e navegação inferior
├── models/
│   ├── media_item.dart          # base comum de filmes e séries
│   ├── movie.dart               # modelo de filme (fromJson/toJson)
│   └── tv_show.dart             # modelo de série (fromJson/toJson)
├── services/
│   ├── tmdb_service.dart        # requisições HTTP à API do TMDB
│   └── favorites_service.dart   # favoritos com shared_preferences
├── screens/
│   ├── home_screen.dart
│   ├── movies_screen.dart
│   ├── series_screen.dart
│   ├── search_screen.dart
│   ├── details_screen.dart
│   └── favorites_screen.dart
├── widgets/                     # componentes reutilizáveis (card, grade paginada, busca...)
└── utils/                       # constantes, tema e formatadores
```

## Conceitos demonstrados

**Requisições HTTP e REST.** O `TmdbService` usa o pacote `http` para fazer chamadas `GET` aos endpoints `/movie/popular`, `/movie/top_rated`, `/movie/now_playing`, `/tv/popular`, `/tv/top_rated`, `/search/movie`, `/search/tv`, `/movie/{id}` e `/tv/{id}`, sempre com `language=pt-BR`.

**JSON.** A resposta é decodificada com `dart:convert` (`json.decode`) e convertida em objetos tipados pelos construtores `fromJson` de `Movie` e `TvShow`.

**Assíncrono.** Todos os métodos do serviço retornam `Future` e usam `async`/`await`. A tela inicial dispara três requisições em paralelo com `Future.wait`, e as telas exibem o resultado com `FutureBuilder` ou com controle manual de estado.

**Erros e carregamento.** Falhas de rede, timeout (15 s), chave inválida (401), conteúdo inexistente (404) e excesso de requisições (429) viram mensagens em português, exibidas em uma tela de erro com botão "Tentar novamente". Enquanto os dados carregam, um indicador de progresso é mostrado.

## Segurança da chave

A chave fica em um `.env` local, fora do controle de versão. Como o arquivo é empacotado como asset do app, ela pode ser extraída de um APK distribuído. Para uso acadêmico isso é suficiente; em um produto real, o ideal é intermediar as chamadas por um backend próprio.
