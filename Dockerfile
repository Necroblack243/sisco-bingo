FROM dart:stable

WORKDIR /app

COPY server/ ./server/

CMD ["dart", "server/server.dart"]