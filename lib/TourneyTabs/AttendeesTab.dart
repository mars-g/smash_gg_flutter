import 'package:flutter/material.dart';
import 'package:smash_gg/api.dart';
import 'AttendeeCard.dart';
import 'dart:math';

class AttendeesTab extends StatefulWidget{
  final Map _json;
  AttendeesTab(this._json);

  @override
  _AttendeesTabState createState() => new _AttendeesTabState(_json);
}

class _AttendeesTabState extends State<AttendeesTab> {
  final _api = new Api();
  final Map _json;
  int pageNum = 1;
  var filter = {};
  bool incompleteTeam = false;
  final rng = new Random();
  ScrollController _scrollController = new ScrollController();

  _AttendeesTabState(this._json);


  void incrementPage(){
    setState(() {
      pageNum += 1;
      _scrollController.jumpTo(0.0);
    });
  }
  void decrementPage(){
    setState(() {
      if (pageNum > 1){
        pageNum -= 1;
        _scrollController.jumpTo(0.0);
      }
    });
  }
  void _search(String searchInput) {
    setState(() {
      if (searchInput != ""){
        filter["search"] = {"searchString" : searchInput , "fieldsToSearch" : ["gamerTag", "playerName"]};
        print(filter);
      }
      else {
        filter.remove("search");
      }
      pageNum = 1;
      _scrollController.jumpTo(0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Row(
          children: <Widget>[
            new FlatButton(
              onPressed: () {
                setState(() {
                  _scrollController.jumpTo(0.0);
                  if (!incompleteTeam){
                    filter["incompleteTeam"] = true;
                    incompleteTeam = true;
                  }
                  else {
                   incompleteTeam = false;
                   filter.remove("incompleteTeam");
                  }
                });
              },
              child: buttonText(),
              color: Colors.blueAccent,
            ),
            new Padding(
              padding: EdgeInsets.all(8.0),
            ),
            new Flexible(
              child: TextField(
                onChanged: _search,
                decoration: InputDecoration(
                    suffixIcon: Icon(Icons.search),
                    hintText: 'Search for a player'),
              ),
            ),
          ],
        ),
        new FutureBuilder(
            future: _api.getGQLPost("TournamentAttendees",_json['id'].toString(),filter, pageNum.toString()),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  int x = rng.nextInt(150);

                  return new Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        shrinkWrap: false,
                        scrollDirection: Axis.vertical,
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return AttendeeCard(snapshot.data[index], _json['slug'], x + rng.nextInt(100),x + rng.nextInt(100), x + rng.nextInt(100));
                        },
                      ));
                } else {
                  return new Text(
                      'Error grabbing attendees list.\n Attendees may not be published by the TO');
                }
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

  Widget buttonText(){
    if (incompleteTeam == false){
      return Text("Open Team");
    }
    return Flex(
    direction: Axis.horizontal,
    children: <Widget>[Text("Open Team"), new Icon(Icons.check_circle)],
    );
  }
}
