import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final client = Client(
    'Matrix Example Chat',
    databaseBuilder: (_) async {
      final dir = await getApplicationSupportDirectory();
      final db = HiveCollectionsDatabase('matrix_example_chat', dir.path);
      await db.open();
      return db;
    },
  );
  await client.init();
  runApp(MatrixExampleChat(client: client));
}

class MatrixExampleChat extends StatelessWidget {
  final Client client;
  const MatrixExampleChat({required this.client, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Matrix Example Chat',
      builder: (context, child) => Provider<Client>(
        create: (context) => client,
        child: child,
      ),
      home: client.isLogged() ? const RoomListPage() : const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _homeserverTextField = TextEditingController(
    text: 'matrix.org',
  );
  final TextEditingController _usernameTextField = TextEditingController();
  final TextEditingController _passwordTextField = TextEditingController();

  bool _loading = false;

  void _login() async {
    setState(() {
      _loading = true;
    });
    // postPreLoginDID();
    // getDIDList();
    postLoginDId();
    try {
      final client = Provider.of<Client>(context, listen: false);
      await client
          .checkHomeserver(Uri.https(_homeserverTextField.text.trim(), ''));
      await client.login(
        LoginType.mLoginPassword,
        password: _passwordTextField.text,
        identifier: AuthenticationUserIdentifier(user: _usernameTextField.text),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const RoomListPage()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
      setState(() {
        _loading = false;
      });
    }
  }

  void postPreLoginDID() async {
    final client = Provider.of<Client>(context, listen: false);
    var response = await client.postPreLoginDID(
        did: "did:sdn:0db058993cf429b9bf3b84904e597b098ee60573");
    print("postPreLoginDID response.did= ${response.did}");
    print("postPreLoginDID response.message= ${response.message}");
    print("postPreLoginDID response.updated= ${response.updated}");
    print("postPreLoginDID random_server= ${response.random_server}");
    showToast("postPreLoginDID接口did=:${response.did}");
  }

  void getDIDList() async {
    final client = Provider.of<Client>(context, listen: false);
    SDNDIDListResponse response = await client.getDIDList(
        address: "0xa6dC81DE79ba5BDB908da792d5A96cBB15Cc7424");
    print("getDIDList response.did= ${response.data}");
    showToast("getDIDList接口did=:${response.data[0]}");
  }

  void postLoginDId() async {
    final client = Provider.of<Client>(context, listen: false);

    Map<String, dynamic> jsonData = {
      "did": "did:sdn:a6dc81de79ba5bdb908da792d5a96cbb15cc7424",
      "address": "did:sdn:a6dc81de79ba5bdb908da792d5a96cbb15cc7424",
      "token":
          "0x4326f122f1d0777343812ab2a4b1a3ca466fd781ed245cb735e68efb9867e7f35943b46a9a0f7c1061139294c3806f0f63df71b7c55996a6f7a1101390b47d081b",
      "message":
          "Login with this account\n\ntime: 2023-07-19T07:18:55Z\n877193042b68b5e93ead141e5b1d37e4140649bd3bc2f3e485f0e84aeb20d460\n2834949983173196185_5SmGRrUN"
    };

    print("jsonString $jsonData");

    try {
      var response = await client.postLoginDId(
        type: "m.login.did.identity",
        updated: "2023-07-19T07:18:55Z",
        identifier: jsonData,
        random_server: "2834949983173196185_5SmGRrUN",
      );

      print("postLoginDId response.access_token= ${response.access_token}");
      print("postLoginDId response.device_id= ${response.device_id}");
      print("postLoginDIdresponse.user_id= ${response.user_id}");
      showToast(
          "postLoginDId接口did=:${response.user_id} ${response.error} ${response.errorcode}  ");
    } catch (e) {
      print('Exception caught: $e');
      showToast('Exception caught: $e');
    }
  }

  void showToast(String text) {
    Fluttertoast.showToast(
      msg: text,
      toastLength:
          Toast.LENGTH_LONG, // 可选参数，可以是Toast.LENGTH_SHORT或Toast.LENGTH_LONG
      gravity: ToastGravity
          .BOTTOM, // 可选参数，可以是ToastGravity.TOP、ToastGravity.CENTER或ToastGravity.BOTTOM
      backgroundColor: Colors.grey, // 可选参数，自定义背景颜色
      textColor: Colors.white, // 可选参数，自定义文本颜色
      fontSize: 13.0, // 可选参数，自定义文本大小
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _homeserverTextField,
              readOnly: _loading,
              autocorrect: false,
              decoration: const InputDecoration(
                prefixText: 'https://',
                border: OutlineInputBorder(),
                labelText: 'Homeserver',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameTextField,
              readOnly: _loading,
              autocorrect: false,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Username',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordTextField,
              readOnly: _loading,
              autocorrect: false,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const LinearProgressIndicator()
                    : const Text('http test begin'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RoomListPage extends StatefulWidget {
  const RoomListPage({Key? key}) : super(key: key);

  @override
  _RoomListPageState createState() => _RoomListPageState();
}

class _RoomListPageState extends State<RoomListPage> {
  void _logout() async {
    final client = Provider.of<Client>(context, listen: false);
    await client.logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void _join(Room room) async {
    if (room.membership != Membership.join) {
      await room.join();
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RoomPage(room: room),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final client = Provider.of<Client>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: StreamBuilder(
        stream: client.onSync.stream,
        builder: (context, _) => ListView.builder(
          itemCount: client.rooms.length,
          itemBuilder: (context, i) => ListTile(
            leading: CircleAvatar(
              foregroundImage: client.rooms[i].avatar == null
                  ? null
                  : NetworkImage(client.rooms[i].avatar!
                      .getThumbnail(
                        client,
                        width: 56,
                        height: 56,
                      )
                      .toString()),
            ),
            title: Row(
              children: [
                Expanded(child: Text(client.rooms[i].displayname)),
                if (client.rooms[i].notificationCount > 0)
                  Material(
                      borderRadius: BorderRadius.circular(99),
                      color: Colors.red,
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child:
                            Text(client.rooms[i].notificationCount.toString()),
                      ))
              ],
            ),
            subtitle: Text(
              client.rooms[i].lastEvent?.body ?? 'No messages',
              maxLines: 1,
            ),
            onTap: () => _join(client.rooms[i]),
          ),
        ),
      ),
    );
  }
}

class RoomPage extends StatefulWidget {
  final Room room;
  const RoomPage({required this.room, Key? key}) : super(key: key);

  @override
  _RoomPageState createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  late final Future<Timeline> _timelineFuture;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    _timelineFuture = widget.room.getTimeline(onChange: (i) {
      print('on change! $i');
      _listKey.currentState?.setState(() {});
    }, onInsert: (i) {
      print('on insert! $i');
      _listKey.currentState?.insertItem(i);
    }, onRemove: (i) {
      print('On remove $i');
      _listKey.currentState?.removeItem(i, (_, __) => const ListTile());
    }, onUpdate: () {
      print('On update');
    });
    super.initState();
  }

  final TextEditingController _sendController = TextEditingController();

  void _send() {
    widget.room.sendTextEvent(_sendController.text.trim());
    _sendController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.room.displayname),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<Timeline>(
                future: _timelineFuture,
                builder: (context, snapshot) {
                  final timeline = snapshot.data;
                  if (timeline == null) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  }
                  return Column(
                    children: [
                      Center(
                        child: TextButton(
                            onPressed: timeline.requestHistory,
                            child: const Text('Load more...')),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: AnimatedList(
                          key: _listKey,
                          reverse: true,
                          initialItemCount: timeline.events.length,
                          itemBuilder: (context, i, animation) => timeline
                                      .events[i].relationshipEventId !=
                                  null
                              ? Container()
                              : ScaleTransition(
                                  scale: animation,
                                  child: Opacity(
                                    opacity: timeline.events[i].status.isSent
                                        ? 1
                                        : 0.5,
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        foregroundImage: timeline.events[i]
                                                    .sender.avatarUrl ==
                                                null
                                            ? null
                                            : NetworkImage(timeline
                                                .events[i].sender.avatarUrl!
                                                .getThumbnail(
                                                  widget.room.client,
                                                  width: 56,
                                                  height: 56,
                                                )
                                                .toString()),
                                      ),
                                      title: Row(
                                        children: [
                                          Expanded(
                                            child: Text(timeline
                                                .events[i].sender
                                                .calcDisplayname()),
                                          ),
                                          Text(
                                            timeline.events[i].originServerTs
                                                .toIso8601String(),
                                            style:
                                                const TextStyle(fontSize: 10),
                                          ),
                                        ],
                                      ),
                                      subtitle: Text(timeline.events[i]
                                          .getDisplayEvent(timeline)
                                          .body),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                    controller: _sendController,
                    decoration: const InputDecoration(
                      hintText: 'Send message',
                    ),
                  )),
                  IconButton(
                    icon: const Icon(Icons.send_outlined),
                    onPressed: _send,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
