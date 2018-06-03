import 'package:flutter/material.dart';

class HomeTab extends StatelessWidget {
  final Map _json;

  HomeTab(this._json);
  @override
  Widget build(BuildContext context) {
    // TODO: implement banner ui build
    bool hasBanner = false;
    int bannerNum;
    for (int i = 0; i < _json['images'].length; i++) {
      if (_json['images'][i]['type'] == 'banner') {
        hasBanner = true;
        bannerNum = i;
      }
    }
    //there is a banner image, which should be the top
    if (hasBanner) {
      return new ListView(
        children: <Widget>[
          new Image.network(_json['images'][bannerNum]['url']),
          new Padding(
            padding: EdgeInsets.all(8.0),
          ),
          new Text(
            "Details",
            style: new TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          new Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.0),
              child: new Center(
              child: Text(
            _json['details'],
            style: new TextStyle(
              fontSize: 18.0,
            ),
          ))),
          new Text(
            "Location",
            style: new TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else {
      return new Text("HOME");
    }
  }

}
