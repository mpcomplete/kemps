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

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(value)
    ));
  }

  void _handleSubmitted() {
    FormState form = _formKey.currentState;
    if (!form.validate()) {
      _autovalidate = true;
      _showInSnackBar('Please give every player a name.');
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
  List<bool> _enabled;
  Function _onSelectedChanged;
  KempsCall _call;
  int _caller;
  String _message;

  List<Player> get players => config.app.players;

  @override
  void initState() {
    super.initState();
    _resetCall();
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
          new KempsScores(
            app: config.app,
            selected: _selected,
            enabled: _enabled,
            onSelectedChanged: _onSelectedChanged,
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Container(
                height: 48.0,
                padding: const EdgeInsets.only(bottom: 20.0),
                child: new Text(_message ?? ''),
              )
            ]
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _makeButton('KEMPS', _canPress(KempsCall.kemps) ? _handleKemps : null),
              _makeButton('UNKEMPS', _canPress(KempsCall.unkemps) ? _handleUnkemps : null),
            ]
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _makeButton('CO-KEMPS', _canPress(KempsCall.coKemps) ? _handleCoKemps : null),
              _makeButton('CO-UNKEMPS', _canPress(KempsCall.coUnkemps) ? _handleCoUnkemps : null),
            ]
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _call == null ? new Container() : _makeButton('CANCEL', _resetCall),
            ]
          ),
        ]
      )
    );
  }

  Widget _makeButton(String text, Function onPressed) {
    return new Container(
      padding: const EdgeInsets.all(20.0),
      alignment: const FractionalOffset(0.5, 0.5),
      child: new RaisedButton(
        child: new Text(text),
        onPressed: onPressed
      ),
    );
  }

  bool _canPress(KempsCall callButton) {
    if (_call == null)
      return true;
    if (_call != callButton)
      return false;
    switch (_call) {
      case KempsCall.kemps:
      case KempsCall.unkemps:
        return _onSelectedChanged == _selectCallees && _selectedIndices.length >= 2;
      case KempsCall.coKemps:
        return _selectedIndices.length >= 2;
      case KempsCall.coUnkemps:
        return _selectedIndices.length == 1;
    }
    return false;
  }

  void _handleKemps() {
    if (_onSelectedChanged == null) {
      setState(() {
        _selected = new List<bool>.filled(5, false);
        _enabled = new List<bool>.filled(5, true);
        _onSelectedChanged = _selectCaller;
        _call = KempsCall.kemps;
        _message = 'Select the player who called Kemps';
      });
    } else if (_onSelectedChanged == _selectCallees) {
      List<int> callees = _callees;
      players[_caller].score += callees.length == 1 ? 1 : 2;
      for (int i in callees) {
        players[i].score += 1;
        players[i].addProfitsWith(_caller);
        players[_caller].addProfitsWith(i);
      }
      String maybeDouble = (callees.length == 1) ? '' : 'double ';
      _showInSnackBar('${_getNames([_caller])} ${maybeDouble}kemps ${_getNames(callees)}!');
      _resetCall();
    } else {
      assert(false);
    }
  }

  void _handleUnkemps() {
    if (_onSelectedChanged == null) {
      setState(() {
        _selected = new List<bool>.filled(5, false);
        _enabled = new List<bool>.filled(5, true);
        _onSelectedChanged = _selectCaller;
        _call = KempsCall.unkemps;
        _message = 'Select the player who called Unkemps';
      });
    } else if (_onSelectedChanged == _selectCallees) {
      List<int> callees = _callees;
      for (int i in callees)
        players[i].score -= 1;
      String maybeDouble = (callees.length == 1) ? '' : 'double ';
      _showInSnackBar('${_getNames([_caller])} ${maybeDouble}unkemps ${_getNames(callees)}!');
      _resetCall();
    }
  }

  void _handleCoKemps() {
    if (_onSelectedChanged == null) {
      setState(() {
        _selected = new List<bool>.filled(5, false);
        _enabled = new List<bool>.filled(5, true);
        _onSelectedChanged = _selectCaller;
        _call = KempsCall.coKemps;
        _message = 'Select the players who called Co-Kemps';
      });
    } else if (_onSelectedChanged == _selectCaller) {
      List<int> callers = _selectedIndices;
      assert(callers.length == 2 || callers.length == 3);
      for (int i in callers) {
        players[i].score += callers.length == 2 ? 2 : 5;
        for (int j in callers) {
          if (i != j)
            players[i].addProfitsWith(j);
        }
      }
      if (callers.length == 2) {
        _showInSnackBar('Co-Kemps! ${_getNames(callers)}!');
      } else {
        _showInSnackBar('TRINITY KEMPS!!! ${_getNames(callers)}!');
      }
      _resetCall();
    } else {
      assert(false);
    }
  }

    void _handleCoUnkemps() {
    if (_onSelectedChanged == null) {
      setState(() {
        _selected = new List<bool>.filled(5, false);
        _enabled = new List<bool>.filled(5, true);
        _onSelectedChanged = _selectCaller;
        _call = KempsCall.coUnkemps;
        _message = 'Select the player who was Co-Unkempsed';
      });
    } else if (_onSelectedChanged == _selectCaller) {
      players[_caller].score -= 2;
      _showInSnackBar('${_getNames([enemy1(_caller), enemy2(_caller)])} co-unkemps ${_getNames([_caller])}!');
      _resetCall();
    }
  }

  void _resetCall() {
    setState(() {
      _selected = new List<bool>.filled(5, false);
      _enabled = new List<bool>.filled(5, false);
      _onSelectedChanged = null;
      _call = null;
      _caller = null;
      _message = null;
    });
  }

  List<int> get _selectedIndices {
    List<int> result = <int>[];
    for (int i = 0; i < 5; ++i) {
      if (_selected[i])
        result.add(i);
    }
    return result;
  }

  List<int> get _callees {
    List<int> result = <int>[];
    for (int i = 0; i < 5; ++i) {
      if (_selected[i] && i != _caller)
        result.add(i);
    }
    return result;
  }

  String _getNames(List<int> indices) {
    String result = players[indices[0]].name;
    for (int i = 1; i < indices.length; ++i)
      result += ' and ${players[indices[i]].name}';
    return result;
  }

  // Returns 5 bools with `true` at each given index.
  // _makeBools([1, 2]) returns [false, true, true, false, false]
  List<bool> _makeBools(List<int> trueValues) {
    List<bool> result = new List<bool>.filled(5, false);
    for (int i in trueValues)
      result[i] = true;
    return result;
  }

  void _selectCaller(int index, bool value) {
    setState(() {
      assert(value);
      _selected[index] = true;
      bool firstCaller = _caller == null;
      _caller = index;

      switch (_call) {
        case KempsCall.kemps:
          _enabled = _makeBools(<int>[friend1(index), friend2(index)]);
          _onSelectedChanged = _selectCallees;
          _message = 'Select the callee(s)';
          break;
        case KempsCall.coKemps:
          if (firstCaller) {
            _enabled = _makeBools(<int>[friend1(index), friend2(index)]);
          } else {
            _enabled[index] = false;
          }
          break;
        case KempsCall.unkemps:
          _enabled = _makeBools(<int>[enemy1(index), enemy2(index)]);
          _onSelectedChanged = _selectCallees;
          _message = 'Select the callee(s)';
          break;
        case KempsCall.coUnkemps:
          _enabled = new List<bool>.filled(5, false);
          break;
      }
    });
  }

  void _selectCallees(int index, bool value) {
    setState(() {
      _selected[index] = value;
    });
  }

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(value),
      duration: const Duration(milliseconds: 5000)
    ));
  }
}

class KempsScores extends StatelessWidget {
  KempsScores({this.app, this.selected, this.enabled, this.onSelectedChanged}) {
    assert(app != null);
    assert(selected != null);
    assert(enabled != null);
  }

  final KempsAppState app;
  final List<bool> selected;
  final List<bool> enabled;
  final Function onSelectedChanged;

  @override
  Widget build(BuildContext context) {
    return new Material(
      child: new Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
        child: new Table(
          columnWidths: <int, TableColumnWidth>{
            0: const FlexColumnWidth(1.0),
            1: const FlexColumnWidth(2.0),
            2: const FlexColumnWidth(1.0),
            3: const FlexColumnWidth(3.0)
          },
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
          child: onSelectedChanged == null ?
            new Container(height: 48.0) :
            new Checkbox(
              value: selected[index],
              onChanged: !enabled[index] ? null : (bool value) {
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
