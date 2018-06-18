import 'dart:math';

import 'package:flutter/material.dart';

class AttendeeCard extends StatelessWidget {
  final Map _json;
  final rng = new Random();

  final height = 65.0;
  final width = 65.0;

  AttendeeCard(this._json);

  Widget addImage() {
    if (_json['images'].length != 0) {
      return new Image.network(
        _json['images'][0]['url'],
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
                    new Text(_json['name']),
                    new Flexible(child: Row()),
                  ],
                ))
              ],
            ),
          )),
    );
  }
}
