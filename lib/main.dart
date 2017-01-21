import 'package:flutter/material.dart';

class Player {
  Player(this.name);

  String name;
  int score = 0;
  Map<int, int> profitSharing = <int, int>{};

  int getProfitsWith(int index) => profitSharing[index] ?? 0;
  void addProfitsWith(int index) {
    profitSharing[index] = getProfitsWith(index) + 1;
  }
}

//     1
//         2
// 0
//         3
//     4
int enemy1(int playerIndex) => (playerIndex + 1) % 5;
int friend1(int playerIndex) => (playerIndex + 2) % 5;
int friend2(int playerIndex) => (playerIndex + 3) % 5;
int enemy2(int playerIndex) => (playerIndex + 4) % 5;

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
    return new TextField(
      labelText: 'Player $n',
      initialValue: new InputValue(text: 'Player $n'), // @@@MP
      isDense: true,
      onSaved: (InputValue val) { _players[n-1] = val.text; },
      validator: (InputValue val) { return val.text.isEmpty ? 'Required' : null; },
    );
  }
}

class KempsPlay extends StatefulWidget {
  KempsPlay(this.app);

  KempsAppState app;

  @override
  KempsPlayState createState() => new KempsPlayState();
}

enum KempsCall {
  kemps,
  unkemps,
  coKemps,
  coUnkemps,
}

class KempsPlayState extends State<KempsPlay> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List<bool> _selected;
  Function _onSelectedChanged;
  KempsCall _call;
  int _caller;

  List<Player> get players => config.app.players;

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
          new KempsScores(
            app: config.app,
            selected: _selected,
            onSelectedChanged: _onSelectedChanged,
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Container(
                padding: const EdgeInsets.all(20.0),
                alignment: const FractionalOffset(0.5, 0.5),
                child: new RaisedButton(
                  child: new Text('KEMPS'),
                  onPressed: _canPress(KempsCall.kemps) ? _handleKemps : null,
                ),
              ),
              new Container(
                padding: const EdgeInsets.all(20.0),
                alignment: const FractionalOffset(0.5, 0.5),
                child: new RaisedButton(
                  child: new Text('UNKEMPS'),
                  onPressed: _canPress(KempsCall.unkemps) ? _handleUnkemps : null,
                ),
              ),
            ]
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Container(
                padding: const EdgeInsets.all(20.0),
                alignment: const FractionalOffset(0.5, 0.5),
                child: new RaisedButton(
                  child: new Text('CO-KEMPS'),
                  onPressed: _canPress(KempsCall.coKemps) ? _handleKemps : null,
                ),
              ),
              new Container(
                padding: const EdgeInsets.all(20.0),
                alignment: const FractionalOffset(0.5, 0.5),
                child: new RaisedButton(
                  child: new Text('CO-UNKEMPS'),
                  onPressed: _canPress(KempsCall.coUnkemps) ? _handleUnkemps : null,
                ),
              ),
            ]
          ),
        ]
      )
    );
  }

  bool _canPress(KempsCall callButton) {
    return (
      _call == null || (
        _call == callButton &&
        _onSelectedChanged == _selectCallees &&
        _getSelectedIndices().isNotEmpty
      )
    );
  }

  void _handleKemps() {
    if (_onSelectedChanged == null) {
      setState(() {
        // Shows the checkboxes.
        _selected = new List<bool>.filled(5, false);
        _onSelectedChanged = _selectCaller;
        _call = KempsCall.kemps;
      });
    } else if (_onSelectedChanged == _selectCallees) {
      List<int> callees = _getSelectedIndices();
      players[_caller].score += callees.length == 1 ? 1 : 2;
      for (int i in callees) {
        players[i].score += 1;
        players[i].addProfitsWith(_caller);
        players[_caller].addProfitsWith(i);
      }
      setState(() {
        _selected = null;
        _onSelectedChanged = null;
        _call = null;
      });
    } else {
      assert(false);
    }
  }

  void _handleUnkemps() {
    if (_onSelectedChanged == null) {
      setState(() {
        // Shows the checkboxes.
        _selected = new List<bool>.filled(5, false);
        _onSelectedChanged = _selectCaller;
        _call = KempsCall.unkemps;
      });
    } else if (_onSelectedChanged == _selectCallees) {
      List<int> callees = _getSelectedIndices();
      for (int i in callees)
        players[i].score -= 1;

      setState(() {
        _selected = new List<bool>.filled(5, false);
        _onSelectedChanged = null;
        _call = null;
      });
    }
  }

  List<int> _getSelectedIndices() {
    List<int> result = <int>[];
    for (int i = 0; i < 5; ++i) {
      if (_selected[i])
        result.add(i);
    }
    return result;
  }

  void _selectCaller(int index, bool value) {
    assert(value == true);
    setState(() {
      _selected = new List<bool>.filled(5, false);
      _caller = index;
      _onSelectedChanged = _selectCallees;
    });
  }

  void _selectCallees(int index, bool value) {
    setState(() {
      _selected[index] = value;
    });
  }
}

class KempsScores extends StatelessWidget {
  KempsScores({this.app, this.selected, this.onSelectedChanged});

  final KempsAppState app;
  final List<bool> selected;
  final Function onSelectedChanged;

  @override
  Widget build(BuildContext context) {
    return new Material(
      child: new Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
        child: new Table(
          // columnWidths: <int, TableColumnWidth>{
          //   0: const FixedColumnWidth(64.0)
          // },
          children: <TableRow>[
            _buildRow(0),
            _buildRow(1),
            _buildRow(2),
            _buildRow(3),
            _buildRow(4),
          ]
        )
      )
    );
  }

  TableRow _buildRow(int index) {
    return new TableRow(
      children: <Widget>[
        new TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: selected == null ?
            new Container(height: 48.0) :
            new Checkbox(
              value: selected[index],
              onChanged: onSelectedChanged == null ? null : (bool value) {
                onSelectedChanged(index, value);
              }
            ),
        ),
        new TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: new Text(app.players[index].name)
        ),
        new TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: new Text(app.players[index].score.toString())
        ),
        new TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: new Table(
            children: <TableRow>[
              new TableRow(
                children: <Widget>[
                  new TableCell(child: new Text(app.players[friend1(index)].name)),
                  new TableCell(child: new Text(app.players[index].getProfitsWith(friend1(index)).toString())),
                ]
              ),
              new TableRow(
                children: <Widget>[
                  new TableCell(child: new Text(app.players[friend2(index)].name)),
                  new TableCell(child: new Text(app.players[index].getProfitsWith(friend2(index)).toString())),
                ]
              ),
            ]
          )
        ),
      ]
    );
  }
}


void main() {
  runApp(new KempsApp());
}
