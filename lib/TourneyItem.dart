import 'package:flutter/material.dart';
import 'api.dart';

//Map of months from their integer rep
Map<int,String> months = {
  1 : 'January',
  2 : 'February',
  3 : 'March',
  4 : 'April',
  5 : 'May',
  6 : 'June',
  7 : 'July',
  8 : 'August',
  9 : 'September',
  10 : 'October',
  11 : 'November',
  12 : 'December'
};

///Represents the icon, tourney name and basic info displayed on the homepoage
///in the listview
///
/// Requires a json object of the tourney info for that tounrey
class TourneyItem extends StatelessWidget {
  final Map _json;
  final _api = Api();

  TourneyItem(this._json);

  @override
  Widget build(BuildContext context) {
    return new Card(
      child: InkWell(
        onTap: () {},
        highlightColor: Theme.of(context).accentColor,
        splashColor: Theme.of(context).accentColor,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              findImage(_json),
              Flexible(
                child: Column(
                  children: <Widget>[
                    Text(
                      _json['name'],
                      overflow: TextOverflow.ellipsis,
                      style: new TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 22.0),
                    ),
                    dateText(_json),
                  ],
                ),
              ),
              FutureBuilder(
                future: _api.getTourneyEvents(_json['slug']),
                builder: (context, snapshot){
                  if(snapshot.hasData){
                    return new Text(snapshot.data[0]['name']);
                  }
                  else if (snapshot.hasError){
                    return new Text("${snapshot.error}");
                  }
                  else {
                    return new Text(" ");
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///function to display find image source from map
  ///
  /// param is a json object map from smash.gg secondary api
  Image findImage(Map json) {
    List images = json['images'];
    if (images == null || images.length == 0) {
      return new Image.asset(
        "assets/cup.icon.png",
        height: 80.0,
        width: 80.0,
      );
    }
    for (Map image in images) {
      if (image['type'] == 'profile') {
        return Image.network(
          image['url'],
          height: 80.0,
          width: 80.0,
        );
      }
    }
    return Image.network(images[0]['url'], height: 80.0, width: 80.0);
  }
}

Text dateText(Map json){
  DateTime dateTime = new DateTime.fromMillisecondsSinceEpoch(json['startAt'] * 1000);
  String month = months[dateTime.month];
  String date = dateTime.day.toString();
  return new Text('$month $date',
    textAlign: TextAlign.left,);
}
