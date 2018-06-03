import 'package:flutter/material.dart';
import 'TourneyTabs/AttendeesTab.dart';
import 'TourneyTabs/EventTab.dart';
import 'TourneyTabs/HomeTab.dart';

///Represents the page for a given tourney
///
/// Requires the JSON api object as a parameter
class TourneyPage extends StatefulWidget {
  final Map _json;

  TourneyPage(this._json);

  @override
  _TourneyPageState createState() => new _TourneyPageState(_json, 'Home');
}

class _TourneyPageState extends State<TourneyPage> {
  final Map _json;
  String _pageState;

  _TourneyPageState(this._json, this._pageState);

  void switchPage(String chosenPage) {
    setState(() {
      _pageState = chosenPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(_json['name']),
      ),
      body: new Container(),
      bottomNavigationBar: TabBarView(
        children: <Widget>[new HomeTab(), new EventTab(), new AttendeesTab()],
        controller: new TabController(length: 3, vsync: null),
      ),
    );
  }
}
