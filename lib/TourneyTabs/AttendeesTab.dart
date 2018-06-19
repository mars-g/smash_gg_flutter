import 'package:flutter/material.dart';
import 'package:smash_gg/api.dart';
import 'AttendeeCard.dart';

class AttendeesTab extends StatelessWidget {
  final _api = new Api();
  final Map _json;

  AttendeesTab(this._json);

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
            future: _api.getAttendeesInfo(_json['slug'], '1'),
            builder: (context, snapshot) {
              if (snapshot.hasData){
                return new Expanded(child: ListView.builder(
                  shrinkWrap: false,
                  scrollDirection: Axis.vertical,
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index){
                    if (index < 25){
                      return AttendeeCard(snapshot.data[index]);
                    }
                    return null;
                  },
                ));
              }
              else if (snapshot.hasError){
                return new Text('Error grabbing attendees list.\n Attendees may noit be published by the TO');
              }
              return new CircularProgressIndicator();
            })
      ],
    );
  }
}
