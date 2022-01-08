import 'package:flutter/material.dart';
import 'package:npcx/npcx.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NPC Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'NPC Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _text = '';
  String _timeout = '0';
  Cancelable? _cancelable;

  @override
  void initState() {
    super.initState();
  }

  void _click() async {
    if (_cancelable != null) {
      _cancelable!.cancel();
      setState(() {
        _cancelable = null;
      });
      return;
    }
    try {
      String path = '/Downloads/';
      setState(() {
        _cancelable = Cancelable();
        _text = 'start download to $path';
      });
      final r = await Npcx.deliver('download', param: path, cancelable: _cancelable!, timeout: Duration(seconds: int.parse(_timeout)), onNotify: (param) async {
        setState(() {
          _text = param.toString();
        });
      });
      setState(() {
        _text = r.toString();
        _cancelable = null;
      });
    } catch (e) {
      setState(() {
        _text = e.toString();
      _cancelable = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(14),
              child: Container(
                color: Colors.lightBlue.shade100,
                child: TextField(
                  controller: TextEditingController(text: _timeout),
                  decoration: const InputDecoration(labelText: 'Timeout:'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _timeout = value;
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Container(
                padding: const EdgeInsets.all(14),
                color: Colors.lightBlue.shade100,
                child: Text(
                  _text,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _click,
        tooltip: _cancelable == null ? 'download' : 'cancel',
        child: _cancelable == null ? const Icon(Icons.download) : const Icon(Icons.cancel),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
