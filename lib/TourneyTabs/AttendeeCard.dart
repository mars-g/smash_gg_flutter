import '../AttendeePage.dart';
import 'package:flutter/material.dart';

class AttendeeCard extends StatelessWidget {
  final Map _json;
  final String slug;
  final int r;
  final int g;
  final int b;

  final height = 50.0;
  final width = 50.0;

  AttendeeCard(this._json, this.slug, this.r, this.b, this.g);

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
        decoration: BoxDecoration(shape: BoxShape.circle, color: Color.fromARGB(255, r, g, b)),
        child: new Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: Text(
              _json['gamerTag'][0].toUpperCase(),
              textAlign: TextAlign.center,
              style: new TextStyle(fontSize: 25.0, color: Colors.white),
            )));
  }

  @override
  build(BuildContext context) {
    return new Card(
      child: InkWell(
          onTap: () {
            Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => new AttendeePage(_json, slug, r,g,b)));
          },
          highlightColor: Theme.of(context).accentColor,
          splashColor: Theme.of(context).accentColor,
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                addImage(),
                new Flexible(
                    child: new Column(
                  children: <Widget>[
                        (_json['gamerTag'] != null)? new Text(
                      _json['gamerTag'],
                      style: TextStyle(fontSize: 18.0),
                      textAlign: TextAlign.center) : new Container(),
                        (_json['player'] != null && _json['player']['name'] != null) ? new Text(_json['player']['name'], style: TextStyle(fontSize: 12.0), textAlign: TextAlign.center,) : new Container(),
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
                ),
                new Padding(padding: EdgeInsets.only(right: 36.0),),
                eventText(),
              ],
            ),
          )),
    );
  }

  Widget eventText(){
    String text = '';
    if (_json['events'].length == 0){
      return new Text('');
    }

    if (_json['events'][0]['name'].length > 20) {
      text += _json['events'][0]['name'].substring(0, 20);
    }
    else {
      text += _json['events'][0]['name'];
    }
    for (int i = 1; i < _json['events'].length; i++){
      text +='\n';
      if (_json['events'][i]['name'].length > 20) {
        text += _json['events'][i]['name'].substring(0, 20);
      }
      else {
        text += _json['events'][i]['name'];
      }
    }
    return new Text(text, style: TextStyle(fontSize: 12.0),textAlign: TextAlign.end, overflow: TextOverflow.ellipsis,);
  }

  ///used to display the location of an attendee
  ///
  ///returns a column with state and us for us players and returns a text of country else
  Widget locationText(){
    if (_json['player']['state'] != null){
      return new Center( child: Column(children: <Widget>[
        new Text(_json['player']['country'], textAlign: TextAlign.center,),
        new Text(_json['player']['state'], style: TextStyle(fontSize: 12.0), textAlign: TextAlign.center,),
      ],));
    }
    else if (_json['player']['region'] != null){
      return new Center(child: Column(children: <Widget>[
        new Text(_json['player']['country'],textAlign: TextAlign.center,),
        new Text(_json['player']['region'], style: TextStyle(fontSize: 12.0), textAlign: TextAlign.center,),
      ],));
    }
    else if (_json['player']['country'] != null){
      return new Center(child: Text(_json['player']['country'], textAlign: TextAlign.center,));
    }
    return new Text('');


  }

  //Used to add twitter icon if necessary
  Widget getTwitterIcon() {
    if (_json['player']['twitterHandle'] != null) {
      return new Image.asset('assets/twitter.icon.png',
          height: 15.0, width: 15.0);
    }
    return new Text('');
  }

  //Used to add twitch icon if necessary
  Widget getTwitchIcon() {
    if (_json['player']['twitchStream'] != null) {
      return new Image.asset(
        'assets/twitch.icon.png',
        height: 15.0,
        width: 15.0,
      );
    }
    return new Text('');
  }
}
