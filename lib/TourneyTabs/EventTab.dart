import 'package:flutter/material.dart';
import 'package:smash_gg/api.dart';
import 'EventCard.dart';

class EventTab extends StatelessWidget {
  final Map _json;

  EventTab(this._json);

  @override
  Widget build(BuildContext context) {
    Api _api = Api();
    return new FutureBuilder(
      future: _api.getTourneyEvents(_json['slug']),
      builder: (context, snapshot){
        if(snapshot.hasData){
          return new ListView.builder(
            shrinkWrap: false,
            scrollDirection: Axis.vertical,
            itemCount: snapshot.data.length,
            itemBuilder: (BuildContext context, int index){
              return EventCard(snapshot.data[index]);
            },
          );
        }
        else if (snapshot.hasError){
          return new Text("${snapshot.error}");
        }
        else {
          return new Container(child:CircularProgressIndicator());
        }
      },
    );
  }
}