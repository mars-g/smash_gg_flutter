import 'package:flutter/material.dart';

class AttendeesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Row(
          children: <Widget>[
            new FlatButton(onPressed: (){}, child: Text('Filters')),
            new Flexible(child: TextField(),),
          ],
        ),
      ],
    );
  }
}