import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

class AttendeePage extends StatelessWidget {
  final Map _json;
  final height = 200.0;
  final width = 200.0;
  final rng = new Random();

  AttendeePage(this._json);

  @override
  build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(_json['gamerTag']),
      ),
      body: new Column(children: <Widget>[
        new Row(children: <Widget>[
          attendeeImage(),
          new Flexible(
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  new Text(
                    _json['gamerTag'],
                    style: TextStyle(fontSize: 26.0),
                    textAlign: TextAlign.center,
                  ),
                  new Text(_json['player']['name'], style: TextStyle(fontSize: 13.0), textAlign: TextAlign.center,),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      getTwitchIcon(),
                      getTwitterIcon(),
                    ],
                  ),
                ],
              )),
        ],)
      ]),
    );
  }

  Widget attendeeImage(){
    if (_json['player']['images'].length != 0) {
      return new Image.network(
        _json['player']['images'][0]['url'],
        height: height,
        width: width,
      );
    }
    return new Text('');
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
