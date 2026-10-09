# SISCO v0.2 — playable multiplayer core

## Game rules implemented
- 2–5 players per room.
- Every player gets a randomized 5×5 board containing 1–25 exactly once.
- The player whose turn it is selects a number from their own board.
- That number becomes globally called and is crossed on EVERY player's board, including the caller.
- A line is 5 crossed numbers: horizontal, vertical, or either full corner-to-corner diagonal.
- Each newly completed line awards the next SISCO letter: S → I → S → C → O.
- First player to complete 5 lines wins.

## Run server
Install Dart SDK, then:
```bash
dart run server/server.dart
```
The server listens on port 8080.

## Run Flutter
Install Flutter SDK, then:
```bash
flutter pub get
flutter run
```

For LAN/Ethernet, run the server on one computer and enter that computer's LAN IP, e.g. `192.168.1.10:8080`, on every device.

For internet play, deploy the Dart server on a reachable host and use a secure WebSocket endpoint (`wss://...`) once TLS/reverse-proxy is configured.
