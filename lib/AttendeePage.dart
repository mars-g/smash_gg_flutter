import 'package:flutter/material.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

class AttendeePage extends StatelessWidget {
  final Map _json;
  final height = 200.0;
  final width = 200.0;
  final int r;
  final int g;
  final int b;

  AttendeePage(this._json, this.r, this.g, this.b);

  @override
  build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(_json['gamerTag']),
      ),
      body: new Column(children: <Widget>[
        new Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
          attendeeImage(),
          new Padding(padding: EdgeInsets.all(8.0),),
          new Flexible(
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  new Text(
                    _json['gamerTag'],
                    style: TextStyle(fontSize: 34.0),
                    textAlign: TextAlign.center,
                  ),
                  new Text(_json['player']['name'], style: TextStyle(fontSize: 15.0), textAlign: TextAlign.center,),
                  twitRow(),
                ],
              )),
        ],),
        new Padding(padding: EdgeInsets.all(12.0),),
        new Text("Events Entered", textAlign: TextAlign.center, style: TextStyle(fontSize: 28.0),),
        eventText(),
      ]),
    );
  }

  Widget eventText(){
    String text = '';
    if (_json['events'].length == 0){
      return new Text('None');
    }
    text += _json['events'][0]['name'];

    for (int i = 1; i < _json['events'].length; i++){
      text +='\n';
      text += _json['events'][i]['name'];
    }
    return new Text(text, style: TextStyle(fontSize: 16.0),textAlign: TextAlign.left, overflow: TextOverflow.ellipsis,);
  }

  Widget twitRow(){
    if ((_json['player']['twitchStream'] != null) && _json['player']['twitterHandle'] != null){
      return new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          getTwitchIcon(),
          getTwitterIcon(),
        ],
      );
    }
    else if (_json['player']['twitterHandle'] != null){
      print("HERE");
      return getTwitterIcon();
    }
    else if (_json['player']['twitchStream'] != null){
      return getTwitchIcon();
    }
    return new Text(' ');

  }
  Widget attendeeImage(){
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
        decoration: BoxDecoration(shape: BoxShape.circle, color: Color.fromARGB(255,r,g,b)),
        child: new Padding(
            padding: EdgeInsets.only(top: 25.0),
            child: Text(
              _json['gamerTag'][0].toUpperCase(),
              textAlign: TextAlign.center,
              style: new TextStyle(fontSize: 120.0, color: Colors.white, fontFamily: 'Raleway', ),
            )));
  }
  //Used to add twitter icon if necessary
  Widget getTwitchIcon() {
    if (_json['player']['twitchStream'] != null) {
      return new FlatButton(onPressed: (){
        Future<Null> launched = _launchInBrowser('https:/twitch.tv/' + _json['player']['twitchStream']);
      }, child: Image.asset('assets/twitch.icon.png',
          height: 25.0, width: 25.0),
      color: Colors.deepPurple,) ;
    }
    return new Text('');
  }

  //Used to add twitch icon if necessary
  Widget getTwitterIcon() {
    if (_json['player']['twitterHandle'] != null) {
      return new FlatButton( onPressed: () {
        Future<Null> laucnhed = _launchInBrowser('https:/twitter.com/' + _json['player']['twitterHandle']);
      }, child: new Image.asset(
        'assets/twitter.icon.png',
        height: 25.0,
        width: 25.0,
      ),
      color: Colors.lightBlue,);
    }
    return new Text('');
  }

  Future<Null> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false, forceWebView: false);
    } else {
      throw 'Could not launch $url';
    }
  }
}
