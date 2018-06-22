import 'package:flutter/material.dart';
import 'package:smash_gg/api.dart';
import 'AttendeeCard.dart';

class AttendeesTab extends StatefulWidget{
  final Map _json;
  AttendeesTab(this._json);

  @override
  _AttendeesTabState createState() => new _AttendeesTabState(_json);
}

class _AttendeesTabState extends State<AttendeesTab> {
  final _api = new Api();
  final Map _json;
  var pageNum = 1;

  _AttendeesTabState(this._json);


  void incrementPage(){
    setState(() {
      pageNum += 1;
    });
  }
  void decrementPage(){
    setState(() {
      if (pageNum > 1){
        pageNum -= 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Row(
          children: <Widget>[
            new FlatButton(
              onPressed: () {},
              child: Text('Filters'),
              color: Colors.blueAccent,
            ),
            new Padding(
              padding: EdgeInsets.all(8.0),
            ),
            new Flexible(
              child: TextField(
                decoration: InputDecoration(
                    suffixIcon: Icon(Icons.search),
                    hintText: 'Search for a player'),
              ),
            ),
          ],
        ),
        new FutureBuilder(
            future: _api.getAttendeesInfo(_json['slug'], pageNum),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return new Expanded(
                    child: ListView.builder(
                  shrinkWrap: false,
                  scrollDirection: Axis.vertical,
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return AttendeeCard(snapshot.data[index]);
                  },
                ));
              } else if (snapshot.hasError) {
                return new Text(
                    'Error grabbing attendees list.\n Attendees may noit be published by the TO');
              }
              return new CircularProgressIndicator();
            }),
        new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new FlatButton(
                  onPressed: decrementPage, color: Theme.of(context).accentColor, child: Icon(Icons.keyboard_arrow_left)),
              new FlatButton(
                  onPressed: incrementPage, color: Theme.of(context).accentColor, child: Icon(Icons.keyboard_arrow_right))
            ]),
      ],
    );
  }
}
