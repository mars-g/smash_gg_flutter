import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("About Page"),
      ),
      body: new Padding(padding: EdgeInsets.all(20.0), child: Text(
        'Hello! This is an app that interfaces with the smash.gg website. Right now, there is no way to login in or do anything that only a logged in user can do such as register for tournaments. I hope to add these things as soon as I can and replace this page with a login page. If you want to follow whats happening with this app or view the source code, you can do so at:\nhttps://github.com/mars-g/smash_gg_flutter\n You can also contact me through the appstore if you have any questions or bugs to report. Thanks!',
        style: new TextStyle(fontSize: 16.0),
      )),
    );
  }
}
