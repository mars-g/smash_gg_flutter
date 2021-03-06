import 'package:flutter/material.dart';
import 'TourneyPage.dart';
import 'prefs.dart';

//Map of months from their integer rep
Map<int, String> months = {
  1: 'January',
  2: 'February',
  3: 'March',
  4: 'April',
  5: 'May',
  6: 'June',
  7: 'July',
  8: 'August',
  9: 'September',
  10: 'October',
  11: 'November',
  12: 'December'
};

///Represents the icon, tourney name and basic info displayed on the homepoage
///in the listview
///
/// Requires a json object of the tourney info for that tounrey
class TourneyItem extends StatelessWidget {
  final Map _json;

  TourneyItem(this._json);

  @override
  Widget build(BuildContext context) {
    return new Card(
      child: InkWell(
        onTap: () {
          //Obtain list of recent tourneys from shared preferences
          List<String> recentList = Prefs.getStringList('recentTourneys');
          //if list is empty, add this tourney to the list
          if(recentList[0] == ""){
            recentList[0] = _json['slug'];
          }
          //check if tourney is in list
            //if true, move it to top of list
          else if (recentList.indexOf(_json['slug']) != -1){
            recentList.remove(_json['slug']);
            recentList.insert(0,_json['slug']);
          }
          //if list is full remove last list and add new tourney
          else if (recentList.length == 10){
            recentList.insert(0, _json['slug']);
            recentList.removeLast();
          }
          else {
            recentList.insert(0, _json['slug']);
          }
          Prefs.setStringList('recentTourneys', recentList);
          Navigator.of(context).push(new MaterialPageRoute(
              builder: (BuildContext context) => new TourneyPage(_json)));
        },
        highlightColor: Theme.of(context).accentColor,
        splashColor: Theme.of(context).accentColor,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            textDirection: TextDirection.ltr,
            children: <Widget>[
              findImage(_json),
              Padding(padding: new EdgeInsets.all(1.0)),
              Flexible(
                child: Column(
                  children: <Widget>[
                    Center(
                      child: Text(
                        _json['name'],
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.clip,
                        style: new TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 22.0),
                      ),
                    ),
                    dateText(_json),
                    locText(_json),
                  ],
                ),
              ),
              attendeeCount(),
            ],
          ),
        ),
      ),
    );
  }

  Widget attendeeCount(){
    if (_json['mutations']['cardData'] != null){
      for(var value in _json['mutations']['cardData'].values){
        if (value['attendeeCount'] == 'null' || value['attendeeCount'] == null){
          return new Text(" ");
        }
        return new Text(value['attendeeCount'].toString(), style: TextStyle(color: Colors.red, fontSize: 12.0),);
      }
    }
    return new Text('');
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

Text dateText(Map json) {
  DateTime dateTime =
      new DateTime.fromMillisecondsSinceEpoch(json['startAt'] * 1000);
  String month = months[dateTime.month];
  String date = dateTime.day.toString();
  dateTime = new DateTime.fromMillisecondsSinceEpoch(json['endAt'] * 1000);
  String endDate = dateTime.day.toString();
  String endMonth = months[dateTime.month];
  String year = dateTime.year.toString();
  if (endDate == date && endMonth == month) {
    return new Text(
      '$month $date, $year',
      textAlign: TextAlign.left,
    );
  } else {
    return new Text(
      '$month $date - $endMonth $endDate, $year',
      textAlign: TextAlign.left,
    );
  }
}

Text locText(json) {
  String city = json['city'];
  String state = json['addrState'];
  if (city == null && state == null) {
    return Text(
      " ",
      style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w400),
    );
  } else if (city == null) {
    return new Text(
      '$state',
      style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w400),
    );
  } else if (state == null) {
    return new Text(
      '$city',
      style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w400),
    );
  }
  return new Text(
    '$city, $state',
    style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w400),
  );
}
