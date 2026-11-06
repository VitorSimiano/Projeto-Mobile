# ---------- Etapa 1: compila o app para web ----------
FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app

COPY . .

# Chave do TMDB recebida no build (vira o .env que o app lê como asset)
ARG TMDB_API_KEY
RUN test -n "$TMDB_API_KEY" || (echo "ERRO: defina TMDB_API_KEY" && false)
RUN printf 'TMDB_API_KEY=%s\n' "$TMDB_API_KEY" > .env

RUN flutter config --enable-web
# Gera a pasta web/ (e não mexe nos arquivos que já existem)
RUN flutter create . --platforms web --project-name cinefinder --org com.cinefinder
RUN flutter pub get
RUN flutter build web --release

# ---------- Etapa 2: serve com nginx ----------
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80