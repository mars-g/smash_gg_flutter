import 'package:flutter/material.dart';
import 'package:smash_gg/api.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

const url = 'https://www.smash.gg/';

class EventCard extends StatelessWidget {
  final Map _json;
  //final Future<Null> launched;


  EventCard(this._json);

  @override
  Widget build(BuildContext context) {
    final Api _api = new Api();
    return new Card(
      child: InkWell(
        onTap: () {
          Future<Null> laucnhed = _launchInBrowser(url + _json['slug']);
        },
        highlightColor: Theme.of(context).accentColor,
        splashColor: Theme.of(context).accentColor,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: new Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  //first child is the title of the event
                  new Flexible(child: Text(
                    _json['name'],
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: new TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0),
                  )),
                  new FutureBuilder(
                      future: _api.getEntrantsList(_json['slug']),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return new Flexible(
                              child: Text(
                            snapshot.data.length.toString() + " entrants",
                            maxLines: 1,
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.clip,
                            style: new TextStyle(color: Colors.red),
                          ));
                        } else if (snapshot.hasError) {
                          return new Text("${snapshot.error}");
                        } else {
                          return new Text(" ");
                        }
                      })
                ],
              ),
              entrantsBox(_api),
            ],
          ),
        ),
      ),
    );
  }
  Future<Null> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false, forceWebView: false);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<Null> _launchInWebViewOrVC(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: true, forceWebView: true);
    } else {
      throw 'Could not launch $url';
    }
  }
  ///Creates the entrants box based on the tourney state
  ///
  ///Entrants box is a list of the top 10 entrants if tourney is unfinished.
  /// Entrants box is a list of the standings is completed
  ///
  Widget entrantsBox(Api _api) {
    //tourney is done and standings should be shown
    if (_json['state'] == 3) {
      return new FutureBuilder(
          future: _api.getTopPlacers(_json['slug']),
          builder: (context, snapshot) {
            if (snapshot.hasData){
              if (snapshot.data.length == 0){
                return new Text(" ");
              }
              String text = '';
              // loop through all top attendees
              for (int i = 0; i < 10 && i < snapshot.data.length; i++){
                if (i == 5 || i == 7 || i ==9){
                  text += (i).toString();
                }
                else {
                  text += (i+1).toString();
                }

                text += ': ';
                //see if there is only one player per participant
                if(snapshot.data[i]['players'].length == 1){
                  //see if there is a sponsor
                  if (snapshot.data[i]['players'][0]['prefix'] != null &&  snapshot.data[i]['players'][0]['prefix'] != ""){
                    text += snapshot.data[i]['players'][0]['prefix'];
                    text += '|';
                  }
                  text += snapshot.data[i]['players'][0]['gamerTag'];
                  text += '\n';
                }
                else {
                  for (int j = 0; j < snapshot.data[i]['players'].length; j++){
                    if (snapshot.data[i]['players'][j]['prefix'] != null &&  snapshot.data[i]['players'][j]['prefix'] != ""){
                      text += snapshot.data[i]['players'][j]['prefix'];
                      text += '|';
                    }
                    text += snapshot.data[i]['players'][j]['gamerTag'];
                    if (j != snapshot.data[i]['players'].length -1) {
                      text += '/';
                    }
                  }
                  text += '\n';
                }

              }
              return new Text(text,
                textAlign: TextAlign.left,);
            }
            else if (snapshot.hasError){
              return new Text("${snapshot.error}");
            }
            else {
              return new Text(" ");
            }
          });
    }
    //tourney is still ongoing and should display yhe top 10 seeds
    else {
      return new FutureBuilder(
          future: _api.getTopAttendees(_json['slug']),
          builder: (context, snapshot) {
            if (snapshot.hasData){
              if (snapshot.data.length == 0){
                return new Text(" ");
              }
              String text = 'Entrants: ';
              // loop through all top attendees
              for (int i = 0; i < 10 && i < snapshot.data.length; i++){
                //see if there is only one player per participant
                if(snapshot.data[i]['players'].length == 1){
                  //see if there is a sponsor
                  if (snapshot.data[i]['players'][0]['prefix'] != null &&  snapshot.data[i]['players'][0]['prefix'] != ""){
                    text += snapshot.data[i]['players'][0]['prefix'];
                    text += '|';
                  }
                  text += snapshot.data[i]['players'][0]['gamerTag'];
                  text += '   ';
                }
                else {
                  for (int j = 0; j < snapshot.data[i]['players'].length; j++){
                    if (snapshot.data[i]['players'][j]['prefix'] != null &&  snapshot.data[i]['players'][j]['prefix'] != ""){
                      text += snapshot.data[i]['players'][j]['prefix'];
                      text += '|';
                    }
                    text += snapshot.data[i]['players'][j]['gamerTag'];
                    if (j != snapshot.data[i]['players'].length -1) {
                      text += '/';
                    }
                  }
                  text += '\t';
                }

              }
              return new Text(text,
              textAlign: TextAlign.left,);
            }
            else if (snapshot.hasError){
              return new Text("${snapshot.error}");
            }
            else {
              return new Text(" ");
            }
          });
    }
  }
}
