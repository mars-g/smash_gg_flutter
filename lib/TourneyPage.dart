import 'package:flutter/material.dart';
import 'TourneyTabs/AttendeesTab.dart';
import 'TourneyTabs/EventTab.dart';
import 'AboutPage.dart';
import 'TourneyTabs/HomeTab.dart';

///Represents the page for a given tourney
///
/// Requires the JSON api object as a parameter
class TourneyPage extends StatefulWidget {
  final Map _json;

  TourneyPage(this._json);

  @override
  _TourneyPageState createState() => new _TourneyPageState(_json);
}

class _TourneyPageState extends State<TourneyPage> with SingleTickerProviderStateMixin{
  final Map _json;
  TabController controller;

  _TourneyPageState(this._json);

  @override
  void initState(){
    super.initState();
    controller = new TabController(length: 3, vsync: this);
  }
  @override
  void dispose(){
    controller.dispose();
    super.dispose();
  }

  void doNil() {
    Navigator.of(context).push(new MaterialPageRoute(
        builder: (BuildContext context) =>
        new AboutPage()));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(_json['name']),
        actions: <Widget>[
          new FlatButton(
            onPressed: doNil,
            //color: Colors.redAccent[700],
            color: Colors.white12,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(8.0)),
            child: Text(
              "About",
              style: new TextStyle(
                fontSize: 24.0,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
      body: new TabBarView(
        children: <Widget>[new HomeTab(_json), new EventTab(_json), new AttendeesTab(_json)],
        controller: controller,
      ),
      bottomNavigationBar: new Material(
        color: Colors.grey,
        child: new TabBar(
          tabs: <Tab>[
            new Tab(
              icon: new Icon(Icons.info)
            ),
            new Tab(
              icon: new Icon(Icons.videogame_asset),
            ),
            new Tab(
              icon: new Icon(Icons.people),
            )
          ],
          controller: controller,
        ),
      ),
    );
  }
}
