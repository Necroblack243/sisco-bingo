import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

final rooms = <String, Room>{};
final random = Random();

class Player {
  final WebSocket socket;
  final int id;
  final String name;

  List<int> board;
  final Set<String> completedLines = {};
  bool ready = false;

  Player(
    this.socket,
    this.id,
    this.name,
    this.board,
  );
}

class Room {
  final String code;
  final List<Player> players = [];
  final Set<int> called = {};

  // This is the PLAYER ID whose turn it is.
  int? turn;

  int? winner;
  bool gameStarted = false;

  Room(this.code);
}

// ============================================================
// BOARD
// ============================================================

List<int> newBoard() {
  final board = List<int>.generate(25, (i) => i + 1);
  board.shuffle(random);
  return board;
}

bool validBoard(List<int> board) {
  if (board.length != 25) return false;

  for (final number in board) {
    if (number < 1 || number > 25) {
      return false;
    }
  }

  return board.toSet().length == 25;
}

// ============================================================
// ROOM CODE
// ============================================================

String generateRoomCode() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  return List.generate(
    5,
    (_) => chars[random.nextInt(chars.length)],
  ).join();
}

// ============================================================
// LINES
// ============================================================

Set<String> findLines(
  List<int> board,
  Set<int> called,
) {
  final lines = <String>{};

  // Horizontal
  for (int row = 0; row < 5; row++) {
    final complete = List.generate(
      5,
      (column) {
        return called.contains(
          board[row * 5 + column],
        );
      },
    ).every((value) => value);

    if (complete) {
      lines.add('r$row');
    }
  }

  // Vertical
  for (int column = 0; column < 5; column++) {
    final complete = List.generate(
      5,
      (row) {
        return called.contains(
          board[row * 5 + column],
        );
      },
    ).every((value) => value);

    if (complete) {
      lines.add('c$column');
    }
  }

  // Top-left -> bottom-right
  final diagonal1 = List.generate(
    5,
    (i) {
      return called.contains(
        board[i * 5 + i],
      );
    },
  ).every((value) => value);

  if (diagonal1) {
    lines.add('d1');
  }

  // Top-right -> bottom-left
  final diagonal2 = List.generate(
    5,
    (i) {
      return called.contains(
        board[i * 5 + 4 - i],
      );
    },
  ).every((value) => value);

  if (diagonal2) {
    lines.add('d2');
  }

  return lines;
}

List<String> getLetters(int count) {
  const letters = [
    'S',
    'I',
    'S',
    'C',
    'O',
  ];

  final safeCount = count.clamp(0, 5);

  return letters.sublist(0, safeCount);
}

// ============================================================
// SENDING
// ============================================================

void send(
  Player player,
  Map<String, dynamic> data,
) {
  try {
    player.socket.add(
      jsonEncode(data),
    );
  } catch (_) {
    // Ignore failed sends.
  }
}

void sendError(
  WebSocket socket,
  String message,
) {
  try {
    socket.add(
      jsonEncode({
        'type': 'error',
        'message': message,
      }),
    );
  } catch (_) {}
}

// ============================================================
// BROADCAST ROOM STATE
// ============================================================

void broadcast(Room room) {
  for (final player in room.players) {
    send(
      player,
      {
        'type': 'state',

        'room': room.code,

        // This player
        'player': player.id,
        'playerName': player.name,

        // Personal board
        'board': player.board,

        // Numbers called by the room
        'called': room.called.toList(),

        // Current turn
        'turn': room.turn,

        // Players
        'players': room.players
            .map(
              (p) => {
                'id': p.id,
                'name': p.name,
                'ready': p.ready,
                'lines': p.completedLines.length,
                'letters': getLetters(
                  p.completedLines.length,
                ),
              },
            )
            .toList(),

        // Game
        'gameStarted': room.gameStarted,
        'winner': room.winner,

        // This player's lines
        'completedLines':
            player.completedLines.toList(),

        // This player's SISCO progress
        'letters': getLetters(
          player.completedLines.length,
        ),
      },
    );
  }
}

// ============================================================
// FIND PLAYER / ROOM
// ============================================================

Room? findRoomForSocket(
  WebSocket socket,
) {
  for (final room in rooms.values) {
    for (final player in room.players) {
      if (player.socket == socket) {
        return room;
      }
    }
  }

  return null;
}

Player? findPlayerForSocket(
  WebSocket socket,
) {
  for (final room in rooms.values) {
    for (final player in room.players) {
      if (player.socket == socket) {
        return player;
      }
    }
  }

  return null;
}

// ============================================================
// START GAME
// ============================================================

void startGameIfReady(Room room) {
  if (room.gameStarted) {
    return;
  }

  // Need at least 2 players.
  if (room.players.length < 2) {
    return;
  }

  final everyoneReady = room.players.every(
    (player) => player.ready,
  );

  if (!everyoneReady) {
    return;
  }

  room.gameStarted = true;

  room.called.clear();
  room.winner = null;

  // First player starts.
  room.turn = room.players.first.id;

  for (final player in room.players) {
    player.completedLines.clear();
  }

  broadcast(room);
}

// ============================================================
// NEXT TURN
// ============================================================

void moveToNextTurn(Room room) {
  if (room.players.isEmpty) {
    room.turn = null;
    return;
  }

  final currentIndex = room.players.indexWhere(
    (player) => player.id == room.turn,
  );

  if (currentIndex == -1) {
    room.turn = room.players.first.id;
    return;
  }

  final nextIndex =
      (currentIndex + 1) % room.players.length;

  room.turn = room.players[nextIndex].id;
}

// ============================================================
// MAIN SERVER
// ============================================================

Future<void> main() async {
  final server = await HttpServer.bind(
    InternetAddress.anyIPv4,
  int.parse(Platform.environment['PORT'] ?? '8080'),
  );

  print(
    'SISCO server listening on ws://0.0.0.0:${server.port}',
  );

  await for (final request in server) {
    if (WebSocketTransformer.isUpgradeRequest(
      request,
    )) {
      final socket =
          await WebSocketTransformer.upgrade(
        request,
      );

      handle(socket);
    }
  }
}

// ============================================================
// SOCKET HANDLER
// ============================================================

void handle(WebSocket socket) {
  socket.listen(
    (raw) {
      try {
        final decoded = jsonDecode(
          raw.toString(),
        );

        if (decoded is! Map<String, dynamic>) {
          sendError(
            socket,
            'Invalid request.',
          );
          return;
        }

        final message = decoded;
        final type = message['type'];

        // ==================================================
        // CREATE ROOM
        // Supports both:
        // create
        // create_room
        // ==================================================

        if (type == 'create' ||
            type == 'create_room') {
          String roomCode;

          do {
            roomCode = generateRoomCode();
          } while (rooms.containsKey(roomCode));

          final room = Room(roomCode);

          final playerName =
              (message['name'] ??
                      message['playerName'] ??
                      'Player')
                  .toString();

          final player = Player(
            socket,
            1,
            playerName,
            newBoard(),
          );

          room.players.add(player);
          rooms[roomCode] = room;

          // Tell creator specifically that the room exists.
          send(
            player,
            {
              'type': 'room_created',
              'room': room.code,
              'player': player.id,
              'playerName': player.name,
            },
          );

          broadcast(room);

          return;
        }

        // ==================================================
        // JOIN ROOM
        // Supports both:
        // join
        // join_room
        // ==================================================

        if (type == 'join' ||
            type == 'join_room') {
          final roomCode =
              (message['room'] ?? '')
                  .toString()
                  .trim()
                  .toUpperCase();

          if (roomCode.isEmpty) {
            sendError(
              socket,
              'Enter a room code.',
            );
            return;
          }

          final room = rooms[roomCode];

          if (room == null) {
            sendError(
              socket,
              'Room not found.',
            );
            return;
          }

          if (room.players.length >= 5) {
            sendError(
              socket,
              'Room is full. Maximum 5 players.',
            );
            return;
          }

          if (room.gameStarted) {
            sendError(
              socket,
              'Game already started.',
            );
            return;
          }

          final playerName =
              (message['name'] ??
                      message['playerName'] ??
                      'Player')
                  .toString();

          // Generate the next available player ID.
          final usedIds =
              room.players.map((p) => p.id).toSet();

          int id = 1;

          while (usedIds.contains(id)) {
            id++;
          }

          final player = Player(
            socket,
            id,
            playerName,
            newBoard(),
          );

          room.players.add(player);

          send(
            player,
            {
              'type': 'room_joined',
              'room': room.code,
              'player': player.id,
              'playerName': player.name,
            },
          );

          broadcast(room);

          return;
        }

        // ==================================================
        // SET CUSTOM BOARD
        // ==================================================

        if (type == 'set_board') {
          final room =
              findRoomForSocket(socket);

          final player =
              findPlayerForSocket(socket);

          if (room == null ||
              player == null) {
            sendError(
              socket,
              'You are not in a room.',
            );
            return;
          }

          if (room.gameStarted) {
            sendError(
              socket,
              'The game has already started.',
            );
            return;
          }

          final rawBoard = message['board'];

          if (rawBoard is! List) {
            sendError(
              socket,
              'Invalid board.',
            );
            return;
          }

          final board = <int>[];

          try {
            for (final value in rawBoard) {
              if (value is int) {
                board.add(value);
              } else {
                board.add(
                  int.parse(
                    value.toString(),
                  ),
                );
              }
            }
          } catch (_) {
            sendError(
              socket,
              'Board contains invalid numbers.',
            );
            return;
          }

          if (!validBoard(board)) {
            sendError(
              socket,
              'Board must contain every number from 1 to 25 exactly once.',
            );
            return;
          }

          player.board =
              List<int>.from(board);

          // Changing the board removes READY status.
          player.ready = false;

          broadcast(room);

          return;
        }

        // ==================================================
        // READY
        // ==================================================

        if (type == 'ready') {
          final room =
              findRoomForSocket(socket);

          final player =
              findPlayerForSocket(socket);

          if (room == null ||
              player == null) {
            sendError(
              socket,
              'You are not in a room.',
            );
            return;
          }

          if (room.gameStarted) {
            sendError(
              socket,
              'Game has already started.',
            );
            return;
          }

          if (!validBoard(player.board)) {
            sendError(
              socket,
              'Set a valid board before pressing READY.',
            );
            return;
          }

          player.ready = true;

          broadcast(room);

          startGameIfReady(room);

          return;
        }

        // ==================================================
        // CALL NUMBER
        // ==================================================

        if (type == 'call') {
          final room =
              findRoomForSocket(socket);

          final caller =
              findPlayerForSocket(socket);

          if (room == null ||
              caller == null) {
            sendError(
              socket,
              'You are not in a room.',
            );
            return;
          }

          if (!room.gameStarted) {
            sendError(
              socket,
              'The game has not started yet.',
            );
            return;
          }

          if (room.winner != null) {
            sendError(
              socket,
              'The game is already over.',
            );
            return;
          }

          if (caller.id != room.turn) {
            sendError(
              socket,
              'It is not your turn.',
            );
            return;
          }

          final number = message['number'];

          if (number is! int) {
            sendError(
              socket,
              'Invalid number.',
            );
            return;
          }

          if (number < 1 || number > 25) {
            sendError(
              socket,
              'Number must be between 1 and 25.',
            );
            return;
          }

          if (room.called.contains(number)) {
            sendError(
              socket,
              'That number has already been called.',
            );
            return;
          }

          // Every board contains 1–25, but we still
          // validate the caller's board.
          if (!caller.board.contains(number)) {
            sendError(
              socket,
              'That number is not on your board.',
            );
            return;
          }

          // -----------------------------------------------
          // CALL ACCEPTED
          // -----------------------------------------------

          room.called.add(number);

          // Check EVERY player's board.
          for (final player in room.players) {
            final newLines = findLines(
              player.board,
              room.called,
            );

            player.completedLines.addAll(
              newLines,
            );

            if (player.completedLines.length >= 5 &&
                room.winner == null) {
              room.winner = player.id;
            }
          }

          // Move turn if nobody has won.
          if (room.winner == null) {
            moveToNextTurn(room);
          }

          broadcast(room);

          return;
        }

        // ==================================================
        // UNKNOWN REQUEST
        // ==================================================

        sendError(
          socket,
          'Unknown request type.',
        );
      } catch (e) {
        sendError(
          socket,
          'Invalid request.',
        );
      }
    },
    onDone: () {
      removeSocket(socket);
    },
    onError: (_) {
      removeSocket(socket);
    },
  );
}

// ============================================================
// REMOVE PLAYER
// ============================================================

void removeSocket(WebSocket socket) {
  for (final entry in rooms.entries.toList()) {
    final room = entry.value;

    final leavingPlayers = room.players
        .where(
          (player) => player.socket == socket,
        )
        .toList();

    if (leavingPlayers.isEmpty) {
      continue;
    }

    final leavingId =
        leavingPlayers.first.id;

    room.players.removeWhere(
      (player) => player.socket == socket,
    );

    // No players left.
    if (room.players.isEmpty) {
      rooms.remove(entry.key);
      continue;
    }

    // If the player whose turn it was left,
    // give the turn to the next available player.
    if (room.turn == leavingId) {
      final index = room.players.indexWhere(
        (player) => player.id > leavingId,
      );

      if (index != -1) {
        room.turn = room.players[index].id;
      } else {
        room.turn = room.players.first.id;
      }
    }

    // If fewer than 2 players remain,
    // stop the multiplayer game.
    if (room.gameStarted &&
        room.players.length < 2) {
      room.gameStarted = false;
      room.called.clear();
      room.winner = null;
      room.turn = null;

      for (final player in room.players) {
        player.ready = false;
        player.completedLines.clear();
      }
    }

    // If game hasn't started, the remaining players
    // must still be ready together.
    if (!room.gameStarted) {
      for (final player in room.players) {
        player.ready = false;
      }
    }

    broadcast(room);

    break;
  }
}