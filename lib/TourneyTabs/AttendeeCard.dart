import 'dart:math';

import 'package:flutter/material.dart';

class AttendeeCard extends StatelessWidget {
  final Map _json;
  final rng = new Random();

  final height = 65.0;
  final width = 65.0;

  AttendeeCard(this._json);

  Widget addImage() {
    if (_json['player']['images'].length != 0) {
      return new Image.network(
        _json['player']['images'][0]['url'],
        height: height,
        width: width,
      );
    }
    return new Container(
        height: height,
        width: width,
        color: Color.fromARGB(rng.nextInt(255), rng.nextInt(255),
            rng.nextInt(255), rng.nextInt(255)),
        child: new Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: Text(
              _json['gamerTag'][0],
              textAlign: TextAlign.center,
              style: new TextStyle(fontSize: 25.0),
            )));
  }

  @override
  build(BuildContext context) {
    return new Card(
      child: InkWell(
          onTap: () {},
          highlightColor: Theme.of(context).accentColor,
          splashColor: Theme.of(context).accentColor,
          child: Container(
            child: Row(
              children: <Widget>[
                addImage(),
                new Flexible(
                    child: new Column(
                  children: <Widget>[
                    new Text(
                      _json['gamerTag'],
                      style: TextStyle(fontSize: 18.0),
                      textAlign: TextAlign.left,
                    ),
                    //new Text(_json['player']['name'], style: TextStyle(fontSize: 12.0),),
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        getTwitchIcon(),
                        getTwitterIcon(),
                      ],
                    ),
                  ],
                )),
                new Flexible(
                  child: locationText(),
                )
              ],
            ),
          )),
    );
  }

  Widget eventText(){
    return new Text('');
  }

  ///used to display the location of an attendee
  ///
  ///returns a column with state and us for us players and returns a text of country else
  Widget locationText(){
    if (_json['player']['state'] != null){
      return new Column(children: <Widget>[
        new Text(_json['player']['country']),
        new Text(_json['player']['state'], style: TextStyle(fontSize: 12.0),),
      ],);
    }
    else if (_json['player']['region'] != null){
      return new Column(children: <Widget>[
        new Text(_json['player']['country']),
        new Text(_json['player']['region'], style: TextStyle(fontSize: 12.0),),
      ],);
    }
    else if (_json['player']['country'] != null){
      return new Text(_json['player']['country']);
    }
    return new Text('');


  }

  //Used to add twitter icon if necessary
  Widget getTwitterIcon() {
    if (_json['player']['twitchStream'] != null) {
      return new Image.asset('assets/twitter.icon.png',
          height: 15.0, width: 15.0);
    }
    return new Text('');
  }

  //Used to add twitch icon if necessary
  Widget getTwitchIcon() {
    if (_json['player']['twitterHandle'] != null) {
      return new Image.asset(
        'assets/twitch.icon.png',
        height: 15.0,
        width: 15.0,
      );
    }
    return new Text('');
  }
}
