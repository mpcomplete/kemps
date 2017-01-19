import 'package:flutter/material.dart';

class Player {
  Player(this.name);

  String name;
  int score = 0;
  Map<int, int> profitSharing = <int, int>{};
}

//     1
//         2
// 0
//         3
//     4
// Friends of 0: [2, 3]
List<int> getFriends(int playerIndex) {
  return <int>[
    (playerIndex + 2) % 5,
    (playerIndex + 3) % 5,
  ];
}

class KempsApp extends StatefulWidget {
  KempsApp({ Key key }) : super(key: key);

  @override
  KempsAppState createState() => new KempsAppState();
}

class KempsAppState extends State<KempsApp> {
  List<Player> _players;

  List<Player> get players => _players;
  void initPlayers(List<String> playerNames) {
    _players = new List<Player>.generate(5, (int index) {
      return new Player(playerNames[index]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Kemps',
      // theme: theme,
      routes: <String, WidgetBuilder>{
         '/':      (BuildContext context) => new KempsNames(this),
        //  '/names': (BuildContext context) => new KempsNames()
         '/play':  (BuildContext context) => new KempsPlay(this)
        //  '/scores':  (BuildContext context) => new KempsAppScores()
      },
      // onGenerateRoute: _getRoute,
    );
  }
}

class KempsNames extends StatefulWidget {
  KempsNames(this.app);

  KempsAppState app;

  @override
  KempsNamesState createState() => new KempsNamesState();
}

class KempsNamesState extends State<KempsNames> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  List<String> _players = new List<String>(5);
  bool _autovalidate = false;

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(value)
    ));
  }

  void _handleSubmitted() {
    FormState form = _formKey.currentState;
    if (!form.validate()) {
      _autovalidate = true;
      showInSnackBar('Please fix the errors in red before submitting.');
    } else {
      form.save();
      config.app.initPlayers(_players);
      Navigator.popAndPushNamed(context, '/play');
    }
  }

  Widget _makeInput(int n) {
    return new InputFormField(
      labelText: 'Player $n',
      isDense: true,
      onSaved: (InputValue val) { _players[n-1] = val.text; },
      validator: (InputValue val) { return val.text.isEmpty ? 'Required' : null; },
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text('Enter Players')
      ),
      body: new Form(
        key: _formKey,
        autovalidate: _autovalidate,
        // onWillPop: _warnUserAboutInvalidData,
        child: new Block(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          children: <Widget>[
            _makeInput(1),
            _makeInput(2),
            _makeInput(3),
            _makeInput(4),
            _makeInput(5),
            new Container(
              padding: const EdgeInsets.all(20.0),
              alignment: const FractionalOffset(0.5, 0.5),
              child: new RaisedButton(
                child: new Text('SAVE'),
                onPressed: _handleSubmitted,
              ),
            )
          ]
        )
      )
    );
  }
}

class KempsPlay extends StatefulWidget {
  KempsPlay(this.app);

  KempsAppState app;

  @override
  KempsPlayState createState() => new KempsPlayState();
}

class KempsPlayState extends State<KempsPlay> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List<bool> _checked = new List<bool>.filled(5, false);

  Widget _makeCheckbox(int index) {
    // TODO: disable if partner is not selected
    return new Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        new Checkbox(
          value: _checked[index],
          onChanged: (bool value) {
            setState(() => _checked[index] = value);
          }
        ),
        new Text(config.app.players[index].name + ' ${config.app.players[index].score} and ${config.app.players[index].profitSharing}')
      ]
    );
  }

  void _handleKemps() {
    for (int i = 0; i < 5; ++i) {
      if (_checked[i]) {
        config.app.players[i].score++;
        for (int j = 0; j < 5; ++j) {
          if (_checked[j])
            config.app.players[i].profitSharing[j] = 1 + (config.app.players[i].profitSharing[j] ?? 0);
        }
      }
    }
    setState(() {
      _checked = new List<bool>.filled(5, false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text('Playing')
      ),
      body: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _makeCheckbox(0),
          _makeCheckbox(1),
          _makeCheckbox(2),
          _makeCheckbox(3),
          _makeCheckbox(4),
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Container(
                padding: const EdgeInsets.all(20.0),
                alignment: const FractionalOffset(0.5, 0.5),
                child: new RaisedButton(
                  child: new Text('KEMPS'),
                  onPressed: _handleKemps,
                ),
              ),
              new Container(
                padding: const EdgeInsets.all(20.0),
                alignment: const FractionalOffset(0.5, 0.5),
                child: new RaisedButton(
                  child: new Text('UNKEMPS'),
                  onPressed: () {},
                ),
              ),
            ]
          )
        ]
      )
    );
  }
}

class KempsScores extends StatefulWidget {
  KempsScores(this.app);

  KempsAppState app;

  @override
  KempsScoresState createState() => new KempsScoresState();
}

class KempsScoresState extends State<KempsScores> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text('Enter Players')
      ),
      body: new Text('wee')
    );
  }
}


void main() {
  runApp(new KempsApp());
}
