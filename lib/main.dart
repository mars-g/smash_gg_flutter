import 'package:flutter/material.dart';
import 'api.dart';
import 'TourneyItem.dart';
import 'TourneyPage.dart';


void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Smash.gg',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primaryColor: Colors.red[700],
        brightness: Brightness.light,
        accentColor: Colors.red[100],

      ),
      home: new MyHomePage(title: 'Smash GG'),
      routes: <String, WidgetBuilder>{
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Api _api = Api();
  void _incrementCounter() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    //launchUrl("google.com");
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text(widget.title),
        //also create a login button that will be used to login and exist in the appbar
        actions: <Widget>[
          new FlatButton(
              onPressed: _incrementCounter,
              //color: Colors.redAccent[700],
              color: Colors.white12,
              shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(8.0)),
              child: Text(
                "Login",
                style: new TextStyle(
                  fontSize: 24.0,
                  color: Colors.white,
                ),
              ),
          )
        ],
      ),
      body: new Column(
        children: <Widget>[
          new TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              fillColor: Colors.grey[150],
              filled: true,
              hintText: "Search for a tourney",
              prefixIcon: Icon(Icons.search),
            ),
          ),
          new Container(
              // Invoke "debug paint" (press "p" in the console where you ran
              // "flutter run", or select "Toggle Debug Paint" from the Flutter tool
              // window in IntelliJ) to see the wireframe for each widget.
              //padding: EdgeInsets.all(1.2),
              child:
                new FutureBuilder(
                  future: _api.getListOfTourneys(),
                  builder: (context, snapshot){
                    if(snapshot.hasData){
                      return new Expanded( child : ListView.builder(
                        shrinkWrap: false,
                        scrollDirection: Axis.vertical,
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index){
                          return TourneyItem(snapshot.data[index]);
                        },
                      ));
                    }
                    else if (snapshot.hasError){
                      return new Text("${snapshot.error}");
                    }
                    else {
                      return new CircularProgressIndicator();
                    }
                  },
                ),
            ),
        ],
      ),
    );
  }
}
