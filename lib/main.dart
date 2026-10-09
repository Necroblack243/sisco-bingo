import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const SiscoApp());

const siscoBlue = Color(0xFF1677D2);
const siscoDarkBlue = Color(0xFF145DA0);
const siscoRed = Color(0xFFE53935);
const siscoPaleBlue = Color(0xFFF1F8FF);
const siscoMint = Color(0xFFAEE8D0);

class SiscoApp extends StatelessWidget {
  const SiscoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SISCO BINGO',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: siscoBlue,
          primary: siscoBlue,
          secondary: siscoRed,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: siscoPaleBlue,
        appBarTheme: const AppBarTheme(
          backgroundColor: siscoPaleBlue,
          foregroundColor: siscoDarkBlue,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: siscoPaleBlue,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFDCEBFA)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: siscoBlue, width: 2),
          ),
        ),
      ),
      home: const LoginPage(),
    );
  }
}

Widget siscoBall(String number, Color color, {double size = 54}) {
  return Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white, color],
      ),
      border: Border.all(color: Colors.white, width: 2.5),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.28),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Text(
      number,
      style: TextStyle(
        fontSize: size * 0.32,
        fontWeight: FontWeight.w900,
        color: siscoDarkBlue,
      ),
    ),
  );
}

Widget siscoSectionCard({required Widget child, EdgeInsets padding = const EdgeInsets.all(20)}) {
  return Container(
    width: double.infinity,
    padding: padding,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: const Color(0xFFDCEBFA)),
      boxShadow: [
        BoxShadow(
          color: siscoBlue.withOpacity(0.08),
          blurRadius: 20,
          offset: const Offset(0, 7),
        ),
      ],
    ),
    child: child,
  );
}

Widget siscoBackdrop({required Widget child}) {
  return Container(
    color: siscoPaleBlue,
    child: Stack(
      children: [
        Positioned(top: 22, left: 18, child: siscoBall('7', const Color(0xFF9BCFFF), size: 46)),
        Positioned(top: 105, right: 20, child: Icon(Icons.close_rounded, size: 42, color: siscoRed.withOpacity(0.18))),
        Positioned(bottom: 35, left: 20, child: Icon(Icons.close_rounded, size: 54, color: siscoRed.withOpacity(0.14))),
        Positioned(bottom: 65, right: 18, child: siscoBall('21', const Color(0xFFFFC6C6), size: 52)),
        child,
      ],
    ),
  );
}

// ============================================================
// LOGIN
// ============================================================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool hidePassword = true;

  void login() {
    final name = usernameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a username first.')),
      );
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LobbyPage(playerName: name)),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: siscoPaleBlue,
      body: SafeArea(
        child: siscoBackdrop(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Column(
                  children: [
                    const Icon(Icons.grid_view_rounded, size: 70, color: siscoBlue),
                    const SizedBox(height: 12),
                    const Text(
                      'SISCO BINGO',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: siscoDarkBlue, letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'CROSS THE NUMBERS. CLAIM THE WIN!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, letterSpacing: 1.1, color: Color(0xFF56728D), fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 28),
                    siscoSectionCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('WELCOME, PLAYER!', textAlign: TextAlign.center, style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: siscoDarkBlue)),
                          const SizedBox(height: 8),
                          const Text('Enter your details to get started', textAlign: TextAlign.center, style: TextStyle(color: Colors.blueGrey)),
                          const SizedBox(height: 24),
                          TextField(
                            controller: usernameController,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(labelText: 'Username', prefixIcon: Icon(Icons.person_outline)),
                            onSubmitted: (_) => login(),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: passwordController,
                            obscureText: hidePassword,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                onPressed: () => setState(() => hidePassword = !hidePassword),
                                icon: Icon(hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                              ),
                            ),
                            onSubmitted: (_) => login(),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 54,
                            child: ElevatedButton(
                              onPressed: login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: siscoRed,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                              child: const Text('PLAY NOW  →', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: 1)),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text('Ready to play SISCO?', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF56728D))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// LOBBY
// ============================================================

class LobbyPage extends StatefulWidget {
  final String playerName;
  const LobbyPage({super.key, required this.playerName});

  @override
  State<LobbyPage> createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  final roomController = TextEditingController();
  final ipController = TextEditingController(text: '127.0.0.1');
  SiscoClient? client;
  String status = 'Choose a game mode';

  @override
  void dispose() {
    roomController.dispose();
    ipController.dispose();
    client?.dispose();
    super.dispose();
  }

  void practice() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BoardSetupPage(playerName: widget.playerName, practiceMode: true)),
    );
  }

  Future<void> createRoom() async {
    await connectAndSend({'type': 'create_room', 'playerName': widget.playerName});
  }

  Future<void> joinRoom() async {
    final room = roomController.text.trim();
    if (room.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a room code first.')));
      return;
    }
    await connectAndSend({'type': 'join_room', 'room': room, 'playerName': widget.playerName});
  }

  Future<void> connectAndSend(Map<String, dynamic> message) async {
    setState(() => status = 'Connecting...');
    client?.dispose();
    final c = SiscoClient(
      onMessage: handleServerMessage,
      onError: (error) {
        if (!mounted) return;
        setState(() => status = 'Connection error: $error');
      },
      onDone: () {
        if (!mounted) return;
        setState(() => status = 'Disconnected');
      },
    );
    client = c;
    try {
      await c.connect(ipController.text.trim());
      c.send(message);
    } catch (e) {
      if (!mounted) return;
      setState(() => status = 'Could not connect: $e');
    }
  }

  void handleServerMessage(Map<String, dynamic> data) {
    if (!mounted) return;
    final type = data['type'];
    if (type == 'room_created' || type == 'room_joined') {
      final room = data['room']?.toString() ?? '';
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BoardSetupPage(
            playerName: widget.playerName,
            practiceMode: false,
            roomName: room,
            client: client,
          ),
        ),
      );
      return;
    }
    if (type == 'error') {
      setState(() => status = data['message']?.toString() ?? 'Server error');
      return;
    }
    setState(() => status = data.toString());
  }

  InputDecoration fieldDecoration(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: siscoBlue),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: siscoPaleBlue,
      appBar: AppBar(
        title: const Text('SISCO BINGO', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: CircleAvatar(
                backgroundColor: siscoBlue,
                foregroundColor: Colors.white,
                child: Text(widget.playerName.isEmpty ? '?' : widget.playerName[0].toUpperCase()),
              ),
            ),
          ),
        ],
      ),
      body: siscoBackdrop(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        siscoBall('5', const Color(0xFF9BCFFF), size: 50),
                        const SizedBox(width: 10),
                        siscoBall('12', const Color(0xFFFFC6C6), size: 62),
                        const SizedBox(width: 10),
                        siscoBall('23', siscoMint, size: 50),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('SISCO BINGO', textAlign: TextAlign.center, style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: siscoDarkBlue, letterSpacing: 1.4)),
                    const SizedBox(height: 6),
                    const Text('CROSS THE NUMBERS. CLAIM THE WIN!', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, letterSpacing: 1.1, color: Color(0xFF56728D), fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    siscoSectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('WELCOME, ${widget.playerName.toUpperCase()}!', textAlign: TextAlign.center, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: siscoDarkBlue)),
                          const SizedBox(height: 7),
                          const Text('Ready to play? Choose your game mode.', textAlign: TextAlign.center, style: TextStyle(color: Colors.blueGrey)),
                          const SizedBox(height: 22),
                          SizedBox(
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: practice,
                              icon: const Icon(Icons.sports_esports_rounded),
                              label: const Text('PLAY PRACTICE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
                              style: ElevatedButton.styleFrom(backgroundColor: siscoRed, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Row(
                            children: [
                              Expanded(child: Divider()),
                              Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('MULTIPLAYER', style: TextStyle(color: siscoDarkBlue, fontWeight: FontWeight.w900, letterSpacing: 1))),
                              Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: 18),
                          TextField(controller: ipController, decoration: fieldDecoration('Server IP', Icons.wifi_rounded)),
                          const SizedBox(height: 13),
                          TextField(controller: roomController, textCapitalization: TextCapitalization.characters, decoration: fieldDecoration('Room code', Icons.meeting_room_rounded)),
                          const SizedBox(height: 10),
                          const Text('Create a room to get a code, or enter a friend’s code to join.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF56728D), fontSize: 12)),
                          const SizedBox(height: 17),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: createRoom,
                                    style: ElevatedButton.styleFrom(backgroundColor: siscoBlue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))),
                                    child: const Text('CREATE ROOM', style: TextStyle(fontWeight: FontWeight.w900)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: SizedBox(
                                  height: 48,
                                  child: OutlinedButton(
                                    onPressed: joinRoom,
                                    style: OutlinedButton.styleFrom(foregroundColor: siscoBlue, side: const BorderSide(color: siscoBlue, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))),
                                    child: const Text('JOIN ROOM', style: TextStyle(fontWeight: FontWeight.w900)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: siscoPaleBlue, borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline, color: siscoBlue),
                                const SizedBox(width: 10),
                                Expanded(child: Text(status, style: const TextStyle(color: siscoDarkBlue, fontWeight: FontWeight.w600))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('GOOD LUCK, PLAYER!', style: TextStyle(color: Color(0xFF7894AD), fontWeight: FontWeight.bold, letterSpacing: 1.3)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// WEBSOCKET CLIENT
// ============================================================

class SiscoClient {
  WebSocket? socket;
  void Function(Map<String, dynamic>) onMessage;
  void Function(Object) onError;
  VoidCallback onDone;

  SiscoClient({required this.onMessage, required this.onError, required this.onDone});

  Future<void> connect(String ip) async {
    final cleanIp = ip.trim();
    if (cleanIp.isEmpty) throw Exception('Server IP is empty.');
    socket = await WebSocket.connect('ws://$cleanIp:8080');
    socket!.listen(
      (data) {
        try {
          final decoded = jsonDecode(data.toString());
          if (decoded is Map<String, dynamic>) onMessage(decoded);
        } catch (e) {
          onError(e);
        }
      },
      onError: onError,
      onDone: onDone,
    );
  }

  void send(Map<String, dynamic> data) {
    if (socket == null) return;
    try {
      socket!.add(jsonEncode(data));
    } catch (e) {
      onError(e);
    }
  }

  void dispose() {
    socket?.close();
    socket = null;
  }
}

// ============================================================
// BOARD SETUP
// ============================================================

class BoardSetupPage extends StatefulWidget {
  final String playerName;
  final bool practiceMode;
  final String? roomName;
  final SiscoClient? client;

  const BoardSetupPage({
    super.key,
    required this.playerName,
    required this.practiceMode,
    this.roomName,
    this.client,
  });

  @override
  State<BoardSetupPage> createState() => _BoardSetupPageState();
}

class _BoardSetupPageState extends State<BoardSetupPage> {
  final List<TextEditingController> controllers = List.generate(25, (_) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(25, (_) => FocusNode());
  int activeIndex = 0;
  bool ready = false;
  bool gameStarted = false;
  bool navigatingToGame = false;
  List<Map<String, dynamic>> players = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < focusNodes.length; i++) {
      final index = i;
      focusNodes[index].onKeyEvent = (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        activeIndex = index;
        if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          moveLeft();
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
          moveRight();
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          moveUp();
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
          moveDown();
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.numpadEnter) {
          moveNext();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      };
    }
    if (!widget.practiceMode && widget.client != null) {
      widget.client!.onMessage = handleServerMessage;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) focusCell(0);
      });
    });
  }

  @override
  void dispose() {
    for (final controller in controllers) {
      controller.dispose();
    }
    for (final node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void handleServerMessage(Map<String, dynamic> data) {
    if (!mounted) return;
    final type = data['type'];
    if (type == 'error') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message']?.toString() ?? 'Server error')),
      );
      return;
    }
    if (type != 'state') return;
    final rawPlayers = data['players'];
    final newPlayers = <Map<String, dynamic>>[];
    if (rawPlayers is List) {
      for (final item in rawPlayers) {
        if (item is Map) newPlayers.add(Map<String, dynamic>.from(item));
      }
    }
    final started = data['gameStarted'] == true;
    setState(() {
      players = newPlayers;
      gameStarted = started;
      final me = newPlayers.where((p) => p['name'] == widget.playerName).toList();
      if (me.isNotEmpty) ready = me.first['ready'] == true;
    });
    if (started && !navigatingToGame) {
      navigatingToGame = true;
      final board = getBoard();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MultiplayerGamePage(
            playerName: widget.playerName,
            board: board,
            client: widget.client!,
            initialState: data,
          ),
        ),
      );
    }
  }

  void focusCell(int index) {
    if (index < 0 || index >= 25) return;
    activeIndex = index;
    focusNodes[index].requestFocus();
    final text = controllers[index].text;
    controllers[index].selection = TextSelection(baseOffset: 0, extentOffset: text.length);
    if (mounted) setState(() {});
  }

  void moveLeft() {
    if (activeIndex % 5 != 0) focusCell(activeIndex - 1);
  }

  void moveRight() {
    if (activeIndex % 5 != 4) focusCell(activeIndex + 1);
  }

  void moveUp() {
    if (activeIndex >= 5) focusCell(activeIndex - 5);
  }

  void moveDown() {
    if (activeIndex < 20) focusCell(activeIndex + 5);
  }

  void moveNext() {
    if (activeIndex < 24) focusCell(activeIndex + 1);
  }

  void numberChanged(int index, String value) {
    activeIndex = index;
    if (value.length >= 2) moveNext();
    setState(() {});
  }

  Widget buildCell(int index) {
    final selected = activeIndex == index;
    return SizedBox(
      width: 72,
      height: 72,
      child: TextField(
        controller: controllers[index],
        focusNode: focusNodes[index],
        autofocus: index == 0,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        textAlign: TextAlign.center,
        maxLength: 2,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: siscoDarkBlue),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: selected ? const Color(0xFFD3E9FF) : siscoPaleBlue,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: selected ? siscoBlue : const Color(0xFFDCEBFA), width: selected ? 2 : 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: siscoBlue, width: 2),
          ),
        ),
        onChanged: (value) => numberChanged(index, value),
        onTap: () {
          activeIndex = index;
          setState(() {});
        },
        onSubmitted: (_) => moveNext(),
      ),
    );
  }

  List<int> getBoard() => controllers.map((controller) => int.tryParse(controller.text.trim()) ?? 0).toList();

  bool validateBoard() {
    final values = getBoard();
    if (values.any((number) => number < 1 || number > 25)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Every box must contain a number from 1 to 25.')),
      );
      return false;
    }
    if (values.toSet().length != 25) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Every number from 1 to 25 must be used exactly once.')),
      );
      return false;
    }
    return true;
  }

  void randomize() {
    final numbers = List.generate(25, (index) => index + 1)..shuffle(Random());
    for (int i = 0; i < 25; i++) {
      controllers[i].text = numbers[i].toString();
    }
    focusCell(0);
  }

  void continueGame() {
    if (!validateBoard()) return;
    if (widget.practiceMode) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => PracticeGamePage(playerName: widget.playerName, board: getBoard())),
      );
      return;
    }
    if (widget.client == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No multiplayer connection.')));
      return;
    }
    final board = getBoard();
    widget.client!.send({'type': 'set_board', 'board': board});
    widget.client!.send({'type': 'ready'});
    setState(() => ready = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('READY! Waiting for the other players...')),
    );
  }

  Widget buildWaitingRoom() {
    if (widget.practiceMode) return const SizedBox();
    return siscoSectionCard(
      child: Column(
        children: [
          Text(
            ready ? '✅ YOU ARE READY' : 'Set your board and press READY',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: siscoDarkBlue),
          ),
          const SizedBox(height: 16),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Players in room', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: siscoDarkBlue)),
          ),
          const SizedBox(height: 10),
          if (players.isEmpty) const Text('Waiting for room information...', style: TextStyle(color: siscoDarkBlue)),
          ...players.map((player) {
            final name = player['name']?.toString() ?? 'Player';
            final isReady = player['ready'] == true;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(backgroundColor: siscoBlue, foregroundColor: Colors.white, child: Text(name.isEmpty ? '?' : name[0].toUpperCase())),
              title: Text(name, style: const TextStyle(color: siscoDarkBlue)),
              trailing: Chip(
                backgroundColor: isReady ? const Color(0xFFD9F5E7) : const Color(0xFFFFE5E5),
                label: Text(isReady ? 'READY' : 'NOT READY'),
              ),
            );
          }),
          const SizedBox(height: 8),
          const Text('The game starts automatically when at least 2 players are ready.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF56728D))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: siscoPaleBlue,
      appBar: AppBar(
        title: Text(
          widget.practiceMode ? 'Practice — Set Your Board' : 'Room ${widget.roomName ?? ''} — Set Your Board',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: siscoBackdrop(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
                    siscoSectionCard(
                      child: Column(
                        children: [
                          const Text('SET YOUR BINGO BOARD', textAlign: TextAlign.center, style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: siscoDarkBlue)),
                          const SizedBox(height: 8),
                          const Text('Use every number from 1 to 25 exactly once.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF56728D))),
                          const SizedBox(height: 8),
                          const Text('Type a number and it moves automatically. Use ← ↑ ↓ → to move around.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF56728D))),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: 430,
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 5,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 1,
                              ),
                              itemCount: 25,
                              itemBuilder: (context, index) => buildCell(index),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 12,
                            runSpacing: 10,
                            children: [
                              OutlinedButton.icon(
                                onPressed: randomize,
                                icon: const Icon(Icons.shuffle),
                                label: const Text('RANDOMIZE'),
                              ),
                              FilledButton.icon(
                                onPressed: ready ? null : continueGame,
                                icon: const Icon(Icons.play_arrow),
                                style: FilledButton.styleFrom(backgroundColor: siscoBlue, foregroundColor: Colors.white),
                                label: Text(widget.practiceMode ? 'START PRACTICE' : ready ? 'READY ✓' : 'READY'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (!widget.practiceMode) ...[
                      const SizedBox(height: 20),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: buildWaitingRoom(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// MULTIPLAYER GAME
// ============================================================

class MultiplayerGamePage extends StatefulWidget {
  final String playerName;
  final List<int> board;
  final SiscoClient client;
  final Map<String, dynamic> initialState;

  const MultiplayerGamePage({
    super.key,
    required this.playerName,
    required this.board,
    required this.client,
    required this.initialState,
  });

  @override
  State<MultiplayerGamePage> createState() => _MultiplayerGamePageState();
}

class _MultiplayerGamePageState extends State<MultiplayerGamePage> {
  late List<int> board;
  Set<int> calledNumbers = {};
  Set<String> completedLines = {};
  List<Map<String, dynamic>> players = [];
  int? myId;
  int? turn;
  int? winner;
  bool gameStarted = true;
  bool winnerDialogShown = false;

  @override
  void initState() {
    super.initState();
    board = List<int>.from(widget.board);
    widget.client.onMessage = handleServerMessage;
    handleServerMessage(widget.initialState);
  }

  void handleServerMessage(Map<String, dynamic> data) {
    if (!mounted) return;
    if (data['type'] == 'error') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message']?.toString() ?? 'Server error')),
      );
      return;
    }
    if (data['type'] != 'state') return;

    final rawBoard = data['board'];
    final rawCalled = data['called'];
    final rawLines = data['completedLines'];
    final rawPlayers = data['players'];

    final newBoard = <int>[];
    if (rawBoard is List) {
      for (final value in rawBoard) {
        final number = int.tryParse(value.toString());
        if (number != null) newBoard.add(number);
      }
    }

    final newCalled = <int>{};
    if (rawCalled is List) {
      for (final value in rawCalled) {
        final number = int.tryParse(value.toString());
        if (number != null) newCalled.add(number);
      }
    }

    final newLines = <String>{};
    if (rawLines is List) {
      for (final value in rawLines) {
        newLines.add(value.toString());
      }
    }

    final newPlayers = <Map<String, dynamic>>[];
    if (rawPlayers is List) {
      for (final item in rawPlayers) {
        if (item is Map) newPlayers.add(Map<String, dynamic>.from(item));
      }
    }

    setState(() {
      if (newBoard.length == 25) board = newBoard;
      calledNumbers = newCalled;
      completedLines = newLines;
      players = newPlayers;
      myId = int.tryParse(data['player']?.toString() ?? '');
      turn = int.tryParse(data['turn']?.toString() ?? '');
      winner = int.tryParse(data['winner']?.toString() ?? '');
      gameStarted = data['gameStarted'] == true;
    });

    if (winner != null) {
      Future.delayed(const Duration(milliseconds: 200), showWinnerIfNeeded);
    }
  }

  void showWinnerIfNeeded() {
    if (!mounted || winner == null || winnerDialogShown) return;
    winnerDialogShown = true;
    final winnerPlayer = players.where((player) => int.tryParse(player['id']?.toString() ?? '') == winner).toList();
    final winnerName = winnerPlayer.isNotEmpty ? winnerPlayer.first['name']?.toString() ?? 'Player' : 'Player';
    final isMe = winner == myId;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(isMe ? 'SISCO! 🎉' : 'Game Over'),
        content: Text(isMe ? 'You completed SISCO!' : '$winnerName completed SISCO!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('BACK TO LOBBY'),
          ),
        ],
      ),
    );
  }

  void callNumber(int number) {
    if (!gameStarted || winner != null) return;
    if (turn != myId) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('It is not your turn.')));
      return;
    }
    if (calledNumbers.contains(number)) return;
    widget.client.send({'type': 'call', 'number': number});
  }

  List<List<int>> getLines() => [
        [0, 1, 2, 3, 4],
        [5, 6, 7, 8, 9],
        [10, 11, 12, 13, 14],
        [15, 16, 17, 18, 19],
        [20, 21, 22, 23, 24],
        [0, 5, 10, 15, 20],
        [1, 6, 11, 16, 21],
        [2, 7, 12, 17, 22],
        [3, 8, 13, 18, 23],
        [4, 9, 14, 19, 24],
        [0, 6, 12, 18, 24],
        [4, 8, 12, 16, 20],
      ];

  String getSiscoLetters() {
    const letters = ['S', 'I', 'S', 'C', 'O'];
    return letters.take(completedLines.length.clamp(0, 5)).join(' ');
  }

  String getPlayerLetters(int count) {
    const letters = ['S', 'I', 'S', 'C', 'O'];
    return letters.take(count.clamp(0, 5)).join(' ');
  }

  Widget buildPlayers() {
    return siscoSectionCard(
      child: Column(
        children: [
          const Text('PLAYERS', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: siscoDarkBlue)),
          const SizedBox(height: 8),
          ...players.map((player) {
            final id = int.tryParse(player['id']?.toString() ?? '');
            final name = player['name']?.toString() ?? 'Player';
            final count = int.tryParse(player['lines']?.toString() ?? '0') ?? 0;
            final isTurn = id == turn;
            return ListTile(
              dense: true,
              leading: CircleAvatar(backgroundColor: siscoBlue, foregroundColor: Colors.white, child: Text('$id')),
              title: Text(id == myId ? '$name (YOU)' : name, style: TextStyle(fontWeight: isTurn ? FontWeight.bold : FontWeight.normal, color: siscoDarkBlue)),
              subtitle: Text('SISCO: ${getPlayerLetters(count)}', style: const TextStyle(color: Color(0xFF56728D))),
              trailing: isTurn ? const Chip(label: Text('TURN'), backgroundColor: Color(0xFFD9ECFF)) : null,
            );
          }),
        ],
      ),
    );
  }

  Widget buildBoard() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFDCEBFA), width: 2),
            boxShadow: [BoxShadow(color: siscoBlue.withOpacity(0.1), blurRadius: 16, offset: const Offset(0, 5))],
          ),
          child: CustomPaint(
            painter: SiscoLinePainter(board: board, calledNumbers: calledNumbers, lines: getLines()),
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, crossAxisSpacing: 7, mainAxisSpacing: 7),
              itemCount: 25,
              itemBuilder: (context, index) {
                final number = board[index];
                final crossed = calledNumbers.contains(number);
                return Material(
                  color: crossed ? const Color(0xFFFFE5E5) : siscoPaleBlue,
                  borderRadius: BorderRadius.circular(11),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(11),
                    onTap: () => callNumber(number),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(color: crossed ? siscoRed : siscoBlue, width: crossed ? 2.3 : 1.2),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text('$number', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: crossed ? siscoRed : siscoDarkBlue)),
                          if (crossed) Icon(Icons.close_rounded, color: siscoRed.withOpacity(0.85), size: 28),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget buildNumberButtons() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 7,
      runSpacing: 7,
      children: List.generate(25, (index) {
        final number = index + 1;
        final called = calledNumbers.contains(number);
        final canCall = turn == myId && winner == null && gameStarted && !called;
        return SizedBox(
          width: 43,
          height: 43,
          child: FilledButton(
            onPressed: canCall ? () => callNumber(number) : null,
            style: FilledButton.styleFrom(
              padding: EdgeInsets.zero,
              backgroundColor: called ? siscoRed : siscoBlue,
              foregroundColor: Colors.white,
              disabledBackgroundColor: called ? siscoRed : const Color(0xFFD2DFEA),
              disabledForegroundColor: called ? Colors.white : siscoDarkBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
            ),
            child: Text('$number', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final myTurn = turn == myId;
    return Scaffold(
      backgroundColor: siscoPaleBlue,
      appBar: AppBar(title: Text('SISCO — ${widget.playerName}', style: const TextStyle(fontWeight: FontWeight.w900))),
      body: siscoBackdrop(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
                    siscoSectionCard(
                      child: Column(
                        children: [
                          const Text('S I S C O', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900, color: siscoDarkBlue, letterSpacing: 2)),
                          const SizedBox(height: 8),
                          Text(getSiscoLetters().isEmpty ? 'Complete lines to spell SISCO' : 'SISCO: ${getSiscoLetters()}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: siscoBlue)),
                          const SizedBox(height: 12),
                          Text(
                            winner != null ? 'GAME OVER' : myTurn ? '🔥 YOUR TURN — choose a number' : 'Waiting for the other player...',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: winner != null ? siscoRed : myTurn ? siscoBlue : const Color(0xFF56728D)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    buildBoard(),
                    const SizedBox(height: 18),
                    buildPlayers(),
                    const SizedBox(height: 18),
                    siscoSectionCard(
                      child: Column(
                        children: [
                          const Text('CALLED NUMBERS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: siscoDarkBlue, letterSpacing: 1)),
                          const SizedBox(height: 12),
                          buildNumberButtons(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PRACTICE GAME
// ============================================================

class PracticeGamePage extends StatefulWidget {
  final String playerName;
  final List<int> board;

  const PracticeGamePage({super.key, required this.playerName, required this.board});

  @override
  State<PracticeGamePage> createState() => _PracticeGamePageState();
}

class _PracticeGamePageState extends State<PracticeGamePage> {
  late List<int> board;
  final Set<int> calledNumbers = {};
  final Set<String> completedLines = {};
  final List<String> letters = ['S', 'I', 'S', 'C', 'O'];
  int nextLetter = 0;
  bool gameOver = false;

  @override
  void initState() {
    super.initState();
    board = List<int>.from(widget.board);
  }

  List<List<int>> getLines() => [
        [0, 1, 2, 3, 4],
        [5, 6, 7, 8, 9],
        [10, 11, 12, 13, 14],
        [15, 16, 17, 18, 19],
        [20, 21, 22, 23, 24],
        [0, 5, 10, 15, 20],
        [1, 6, 11, 16, 21],
        [2, 7, 12, 17, 22],
        [3, 8, 13, 18, 23],
        [4, 9, 14, 19, 24],
        [0, 6, 12, 18, 24],
        [4, 8, 12, 16, 20],
      ];

  void callNumber(int number) {
    if (gameOver || number < 1 || number > 25 || calledNumbers.contains(number)) return;
    setState(() => calledNumbers.add(number));
    checkLines();
  }

  void checkLines() {
    final lines = getLines();
    for (final line in lines) {
      final complete = line.every((index) => calledNumbers.contains(board[index]));
      final key = line.join(',');
      if (complete && !completedLines.contains(key)) {
        completedLines.add(key);
        if (nextLetter < letters.length) nextLetter++;
        if (nextLetter == 5) {
          setState(() => gameOver = true);
          Future.delayed(const Duration(milliseconds: 250), () {
            if (!mounted) return;
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => AlertDialog(
                title: const Text('SISCO! 🎉'),
                content: Text('${widget.playerName} completed SISCO!'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Text('BACK TO LOBBY'),
                  ),
                ],
              ),
            );
          });
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lines = getLines();
    return Scaffold(
      backgroundColor: siscoPaleBlue,
      appBar: AppBar(
        backgroundColor: siscoBlue,
        foregroundColor: Colors.white,
        title: Text('SISCO BINGO — ${widget.playerName}', style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: siscoBackdrop(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  children: [
                    siscoSectionCard(
                      child: Column(
                        children: [
                          const Text('S I S C O', style: TextStyle(fontSize: 29, fontWeight: FontWeight.w900, letterSpacing: 3, color: siscoDarkBlue)),
                          const SizedBox(height: 8),
                          Text(nextLetter == 5 ? 'YOU COMPLETED SISCO!' : 'Letters completed: $nextLetter / 5', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: siscoBlue)),
                          const SizedBox(height: 12),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            children: List.generate(5, (index) {
                              final completed = index < nextLetter;
                              return CircleAvatar(
                                radius: 20,
                                backgroundColor: completed ? siscoRed : siscoPaleBlue,
                                child: Text(letters[index], style: TextStyle(color: completed ? Colors.white : siscoDarkBlue, fontWeight: FontWeight.bold)),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text('TAP A NUMBER TO CALL IT', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: siscoDarkBlue, letterSpacing: 1)),
                    const SizedBox(height: 14),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: const Color(0xFFDCEBFA), width: 2),
                            boxShadow: [BoxShadow(color: siscoBlue.withOpacity(0.1), blurRadius: 16, offset: const Offset(0, 5))],
                          ),
                          child: CustomPaint(
                            painter: SiscoLinePainter(board: board, calledNumbers: calledNumbers, lines: lines),
                            child: GridView.builder(
                              padding: const EdgeInsets.all(8),
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, crossAxisSpacing: 7, mainAxisSpacing: 7),
                              itemCount: 25,
                              itemBuilder: (context, index) {
                                final number = board[index];
                                final crossed = calledNumbers.contains(number);
                                return Material(
                                  color: crossed ? const Color(0xFFFFE5E5) : siscoPaleBlue,
                                  borderRadius: BorderRadius.circular(11),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(11),
                                    onTap: gameOver ? null : () => callNumber(number),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(11),
                                        border: Border.all(color: crossed ? siscoRed : siscoBlue, width: crossed ? 2.3 : 1.2),
                                      ),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Text('$number', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: crossed ? siscoRed : siscoDarkBlue)),
                                          if (crossed) Icon(Icons.close_rounded, color: siscoRed.withOpacity(0.8), size: 28),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    siscoSectionCard(
                      child: Column(
                        children: [
                          const Text('CALLED NUMBERS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: siscoDarkBlue, letterSpacing: 1)),
                          const SizedBox(height: 12),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 7,
                            runSpacing: 7,
                            children: List.generate(25, (index) {
                              final number = index + 1;
                              final called = calledNumbers.contains(number);
                              return SizedBox(
                                width: 43,
                                height: 43,
                                child: FilledButton(
                                  style: FilledButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    backgroundColor: called ? siscoRed : siscoBlue,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: called ? siscoRed : const Color(0xFFD2DFEA),
                                    disabledForegroundColor: called ? Colors.white : siscoDarkBlue,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                                  ),
                                  onPressed: called || gameOver ? null : () => callNumber(number),
                                  child: Text('$number', style: const TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                    if (gameOver) ...[
                      const SizedBox(height: 18),
                      const Text('SISCO COMPLETE! 🎉', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900, color: siscoRed)),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// LINE PAINTER
// ============================================================

class SiscoLinePainter extends CustomPainter {
  final List<int> board;
  final Set<int> calledNumbers;
  final List<List<int>> lines;

  SiscoLinePainter({required this.board, required this.calledNumbers, required this.lines});

  @override
  void paint(Canvas canvas, Size size) {
    if (board.length != 25) return;
    final cellWidth = size.width / 5;
    final cellHeight = size.height / 5;
    final paint = Paint()
      ..color = siscoRed
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    for (final line in lines) {
      final complete = line.every((index) => calledNumbers.contains(board[index]));
      if (!complete || line.isEmpty) continue;
      final first = line.first;
      final last = line.last;
      final start = Offset(((first % 5) + 0.5) * cellWidth, ((first ~/ 5) + 0.5) * cellHeight);
      final end = Offset(((last % 5) + 0.5) * cellWidth, ((last ~/ 5) + 0.5) * cellHeight);
      canvas.drawLine(start, end, paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant SiscoLinePainter oldDelegate) => true;
}
