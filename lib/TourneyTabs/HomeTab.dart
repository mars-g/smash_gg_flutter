import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smash_gg/api.dart';
import 'dart:async';
import 'package:map_view/map_view.dart' as map_view;
import 'package:google_maps_webservice/places.dart' as places;

//put your api key here
final apiKey = "";

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

class HomeTab extends StatelessWidget {
  final Map _json;

  HomeTab(this._json);

  ///Assists in places lookups
  ///
  /// type should be as follows
  ///   placeId
  ///   address
  ///   name
  Future placesLookupHelper(String type) async{
    var placesApi = new places.GoogleMapsPlaces(apiKey);
    if (type == "placeId") {
      places.PlacesDetailsResponse placesResponse = await placesApi
          .getDetailsByPlaceId(_json['mapsPlaceId']);
      return placesResponse.result.geometry.location;
    }
    else if (type == "address"){
      places.PlacesSearchResponse placesResponse = await placesApi
          .searchByText(_json['venueAddress']);
      return placesResponse.results[0].geometry.location;
    }
    else {
      places.PlacesSearchResponse placesResponse = await placesApi
          .searchByText(_json['venueName']);
      return placesResponse.results[0].geometry.location;
    }
  }

  ///Map initialization and creation logic
  ///
  /// If the event is an online event, there is no map
  /// For offline events, lat/lng should be prioritized, then google places id
  /// Then google places venue search
  Widget staticMapWidget() {
    if (_json['hasOnlineEvents'] == "true"){
      return Text("This is an online event");
    }
    else if (_json['lat'] != null && _json['lng'] != null){
      var provider = new map_view.StaticMapProvider(apiKey);
      var markers = [new map_view.Marker("1",_json['venueAddress'],_json['lat'],_json['lng'])];
      final staticUri = provider.getStaticUriWithMarkers(markers,width: 900, height: 400, maptype: map_view.StaticMapViewType.roadmap, center: map_view.Location(_json['lat'],_json['lng']),);
      return new Image.network(staticUri.toString());
    }
    else if (_json['mapsPlaceId'] != "null"){
      return new FutureBuilder(
        future: placesLookupHelper("placeId"),
        builder: (context, snapshot){
          if (snapshot.hasData){
            var provider = new map_view.StaticMapProvider(apiKey);
            var markers = [new map_view.Marker("1",_json['venueAddress'],snapshot.data.lat,snapshot.data.lng)];
            final staticUri = provider.getStaticUriWithMarkers(markers,width: 900, height: 400, maptype: map_view.StaticMapViewType.roadmap, center: map_view.Location(snapshot.data.lat,snapshot.data.lng),);
            return new Image.network(staticUri.toString());
          }
          else if (snapshot.hasError){
            print(snapshot.error);
            return new Container();
          }
          else {
            return new Container();
          }
        },
      );
    }
    else if (_json['venueAddress'] != "null"){
      return new FutureBuilder(
        future: placesLookupHelper("address"),
        builder: (context, snapshot){
          if (snapshot.hasData){
            var provider = new map_view.StaticMapProvider(apiKey);
            var markers = [new map_view.Marker("1",_json['venueAddress'],snapshot.data.lat,snapshot.data.lng)];
            final staticUri = provider.getStaticUriWithMarkers(markers,width: 900, height: 400, maptype: map_view.StaticMapViewType.roadmap, center: map_view.Location(snapshot.data.lat,snapshot.data.lng),);
            return new Image.network(staticUri.toString());
          }
          else if (snapshot.hasError){
            print(snapshot.error);
            return new Container();
          }
          else {
            return new Container();
          }
        },
      );
    }
    return new Container();

  }

  @override
  Widget build(BuildContext context) {
    final Api _api = new Api();
    bool hasBanner = false;

    int bannerNum;
    for (int i = 0; i < _json['images'].length; i++) {
      if (_json['images'][i]['type'] == 'banner') {
        hasBanner = true;
        bannerNum = i;
      }
    }
    //there is a banner image, which should be the top
    return new ListView(
      children: <Widget>[
        bannerImage(hasBanner, bannerNum),
        new Padding(
          padding: EdgeInsets.all(6.0),
        ),
        dateText(_json),
        FutureBuilder(
          future: _api.getAttendeesList(_json['slug']),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.length == 0){
                return new Text(" ");
              }
              return new Padding(padding: new EdgeInsets.fromLTRB(0.0, 6.0, 0.0, 0.0), child: Text(snapshot.data.length.toString() + ' attendees',
              textAlign: TextAlign.center,
              style: new TextStyle(
                fontSize: 16.0,
                color: Colors.red,
              ),));
            } else if (snapshot.hasError) {
              return new Text("${snapshot.error}");
            } else {
              return new Text(" ");
            }
          },
        ),
        new Padding(
          padding: EdgeInsets.all(12.0),
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
                child: detailsText())),
        new Text(
          "Location",
          style: new TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        locationText(context),
        locationWidget(),
        //mapview goes here
        staticMapWidget(),
        gettingThereText(),
        new Text(
          "Additional Information",
          style: new TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        new Padding(padding: EdgeInsets.all(3.0)),
        new Text(
          "Contact",
          style: new TextStyle(
            fontSize: 16.0,
          ),
          textAlign: TextAlign.center,
        ),
        new Padding(padding: EdgeInsets.all(3.0)),
        contactText(context),
        new Padding(padding: EdgeInsets.all(3.0)),
        new Text(
          "Rules",
          style: new TextStyle(
            fontSize: 16.0,
          ),
          textAlign: TextAlign.center,
        ),
        new Padding(padding: EdgeInsets.all(3.0)),
        rulesText(),
        new Padding(padding: EdgeInsets.all(3.0)),
        new Text(
          "Prizes",
          style: new TextStyle(
            fontSize: 16.0,
          ),
          textAlign: TextAlign.center,
        ),
        new Padding(padding: EdgeInsets.all(3.0)),
        prizesText(),
      ],
    );
  }

  ///Display tourney text
  Widget detailsText(){
    if (_json['details'] == null){
      return new Text("No tournament description");
    }
    return new MarkdownBody(
      data: _json['details'],
    );
  }

  ///Display banner image
  Widget bannerImage(bool hasBanner, int bannerNum) {
    if (!hasBanner) {
      return new Text(" ");
    } else {
      return new Image.network(_json['images'][bannerNum]['url']);
    }
  }

  ///Generate the text for the prizes
  Widget prizesText() {
    String prizes = "No prize info provided";
    if (_json['prizes'] != null) {
      prizes = _json['prizes'];
    }
    return new Padding(padding: EdgeInsets.all(6.0), child: Text(prizes));
  }

  ///Generate the text for the rules
  Widget rulesText() {
    String rulesText = "No rules info provided";
    if (_json['rules'] != null) {
      rulesText = _json['rules'];
    }
    return new Padding(padding: EdgeInsets.all(6.0), child: Text(rulesText));
  }

  ///Generate the contact portion of the text
  Widget contactText(BuildContext context) {
    String contactEmail = _json['contactEmail'];
    String contactTwitter = _json['contactTwitter'];
    String contactPhone = _json['contactPhone'];
    if (contactEmail == null &&
        contactTwitter == null &&
        contactPhone == null) {
      return new Text(
        "No contact info provided",
      );
    }
    if (_json['contactEmail'] == null) {
      contactEmail = " ";
    }
    if (_json['contactTwitter'] == null) {
      contactTwitter = " ";
    }
    if (_json['contactPhone'] == null) {
      contactPhone = " ";
    }
    return new Padding(
        padding: EdgeInsets.all(6.0),
        child: Text('Email:' +
            contactEmail +
            '\nTwitter: ' +
            contactTwitter +
            '\nPhone: ' +
            contactPhone));
  }

  ///Generates Location Text for the venue and venue address
  Widget locationText(BuildContext context) {
    if (_json['venueName'] != null && _json['venueAddress'] != null) {
      String venueName = _json['venueName'];
      return new Padding(
          padding: EdgeInsets.all(6.0),
          child: RichText(
              text: new TextSpan(
                  text: "$venueName \n",
                  style: DefaultTextStyle.of(context).style,
                  children: <TextSpan>[
                new TextSpan(
                  text: _json['venueAddress'],
                )
              ])));
    } else if (_json['venueName'] != null) {
      return new Padding(
          padding: EdgeInsets.all(6.0), child: Text(_json['venueName']));
    } else if (_json['venueAddress'] != null) {
      return new Padding(
          padding: EdgeInsets.all(6.0), child: Text(_json['venueAddress']));
    } else {
      return new Padding(
          padding: EdgeInsets.all(6.0), child: Text("No location info"));
    }
  }

  ///Creates link to the map
  void launchMapsPlace() async {
    String mapsPlaceId;
    if (_json['venueAddress'] != null) {
      mapsPlaceId = _json['venueAddress'];
    } else if (_json['venueName'] != null) {
      mapsPlaceId = _json['venueName'];
    } else {
      return;
    }
    String url = 'https://www.google.com/maps/search/?api=1&query=$mapsPlaceId';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  ///Returns a button that opens maps when clicked
  Widget locationWidget() {
    if (_json['venueName'] == null && _json['venueAddress'] == null) {
      return new Text(" ");
    }
    return new Padding(
        padding: EdgeInsets.symmetric(horizontal: 120.0),
        child: FlatButton(
            onPressed: launchMapsPlace,
            color: Colors.blueAccent,
            child: Text("Open in Maps")));
  }

  ///Creates the text to display the date
  Widget dateText(Map json) {
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
        textAlign: TextAlign.center,
        style: new TextStyle(
          fontSize: 28.0,
        ),
      );
    } else {
      return new Text(
        '$month $date - $endMonth $endDate',
        textAlign: TextAlign.center,
        style: new TextStyle(
          fontSize: 28.0,
        ),
      );
    }
  }

  ///Creates the text for the getting there instructions
  Widget gettingThereText() {
    if (_json['gettingThere'] == null) {
      return new Text(" ");
    }
    return new Padding(
        padding: EdgeInsets.all(6.0),
        child: Text("Getting there:\n " + _json['gettingThere']));
  }
}
