import 'package:flutter/material.dart';
import 'TourneyPage.dart';
import 'package:smash_gg/api.dart';

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
    final Api _api = new Api();
    return new Card(
      child: InkWell(
        onTap: () {
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
              FutureBuilder(
                future: _api.getAttendeesList(_json['slug']),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return new Transform(transform: new Matrix4.translationValues(5.0, -40.0, 3.0), child: Text(
                      snapshot.data.length.toString() + ' Players',
                      textAlign: TextAlign.right,
                      style: new TextStyle(fontSize: 10.0, color: Colors.red),
                    ));
                  } else if (snapshot.hasError) {
                    return new Text("${snapshot.error}");
                  } else {
                    return new Text(" ");
                  }
                },

              )
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

Text dateText(Map json) {
  DateTime dateTime =
      new DateTime.fromMillisecondsSinceEpoch(json['startAt'] * 1000);
  String month = months[dateTime.month];
  String date = dateTime.day.toString();
  dateTime = new DateTime.fromMillisecondsSinceEpoch(json['endAt'] * 1000);
  String endDate = dateTime.day.toString();
  String endMonth = months[dateTime.month];
  if (endDate == date && endMonth == month) {
    return new Text(
      '$month $date',
      textAlign: TextAlign.left,
    );
  } else {
    return new Text(
      '$month $date - $endMonth $endDate',
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
