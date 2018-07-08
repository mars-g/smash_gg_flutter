import 'package:flutter/material.dart';
import 'api.dart';
import 'TourneyItem.dart';
import 'TourneyPage.dart';
import 'prefs.dart';

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
      routes: <String, WidgetBuilder>{},
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
  String searchTerm = "";
  Map filters;
  int pageNum = 1;
  ScrollController _scrollController = new ScrollController();

  //Array holds the text for filters and the status of it being checked
  var filterTexts = [
    'Upcoming',
    'Featured',
    'Competitor Registration Open',
    'Spectator Registration Open',
    '<100 Attendees',
    '101-200 Attendees',
    '201-500 Attendees',
    '501-1000 Attendees',
    '1001+ Attendees',
    'Country/State/Province',
    'City',
    'League/Circuit',
    'Online',
    'Offline',
  ];
  var filterChecks = [
    true,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];

  @override
  void initState(){
    super.initState();
    Prefs.init();
  }

  @override
  void dispose(){
    Prefs.dispose();
    super.dispose();
  }

  void _updateFilters(var value) {
    setState(() {
      //Switch the value of the filter
      filterChecks[value] = !filterChecks[value];
      pageNum = 1;
      _scrollController.jumpTo(0.0);
    });
  }

  void _search(String searchInput) {
    setState(() {
      //convenience change to deselect upcoming when searching
      filterChecks[0] = false;
      searchTerm = searchInput;
      pageNum = 1;
      _scrollController.jumpTo(0.0);
    });
  }

  void doNil() {}

  void incrementPage() {
    setState(() {
      pageNum += 1;
      _scrollController.jumpTo(0.0);
    });
  }

  void decrementPage() {
    setState(() {
      if (pageNum > 1) {
        pageNum -= 1;
      }
      _scrollController.jumpTo(0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: new Text(widget.title),
          //also create a login button that will be used to login and exist in the appbar
          actions: <Widget>[
            new FlatButton(
              onPressed: doNil,
              //color: Colors.redAccent[700],
              color: Colors.white12,
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(8.0)),
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
              onChanged: _search,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                fillColor: Colors.grey[150],
                filled: true,
                hintText: "Search for a tourney",
                prefixIcon: Icon(Icons.search),
              ),
            ),
            new Container(
              child: new FutureBuilder(
                future:
                    _api.getListOfTourneys(searchTerm, filterChecks, pageNum),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      if (!(snapshot.data is List)) {
                        return new TourneyItem(snapshot.data['tournament']);
                      }
                      return new Expanded(
                          child: ListView.builder(
                        controller: _scrollController,
                        shrinkWrap: false,
                        scrollDirection: Axis.vertical,
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return TourneyItem(snapshot.data[index]);
                        },
                      ));
                    } else {
                      return new Text("No results found");
                    }
                  } else {
                    return new CircularProgressIndicator();
                  }
                },
              ),
            ),
            new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new FlatButton(
                      onPressed: decrementPage,
                      color: Theme.of(context).accentColor,
                      child: Icon(Icons.keyboard_arrow_left)),
                  new FlatButton(
                      onPressed: incrementPage,
                      color: Theme.of(context).accentColor,
                      child: Icon(Icons.keyboard_arrow_right))
                ]),
          ],
        ),
        drawer: Drawer(
          child: drawerList(),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: new SizedBox(
          width: 50.0,
          height: 50.0,
          child: PopupMenuButton(
            itemBuilder: (BuildContext context) {
              var itemList = new List<PopupMenuItem>();
              for (int i = 0; i < filterTexts.length; i++) {
                itemList.add(
                    createPopupMenuItem(filterTexts[i], filterChecks[i], i));
              }
              return itemList;
            },
            onSelected: _updateFilters,
            child: new Container(
              decoration: new BoxDecoration(
                  color: Colors.blue,
                  borderRadius: new BorderRadius.only(
                    topLeft: const Radius.circular(40.0),
                    topRight: const Radius.circular(40.0),
                    bottomLeft: const Radius.circular(40.0),
                    bottomRight: const Radius.circular(40.0),
                  )),
              child: new Icon(Icons.add),
            ),
          ),
        ));
  }
  Widget drawerList(){
    List<Widget> widgets = [];
    widgets.add(DrawerHeader(
      child: Center(child: Text("Recently Viewed", style: TextStyle(fontSize: 30.0, fontFamily: 'Raleway'),)),
      decoration: BoxDecoration(
          color: Colors.redAccent
      ),
    ));
    var stringList = Prefs.getStringListF('recentTourneys');


    Widget futureBuilder = new FutureBuilder(
      future: stringList,
      builder: (context, snapshot){
        if (snapshot.hasData){
          if(snapshot.data.length == 1 && snapshot.data[0] == "") {
            return new Container();
          }
          List<Widget> myWidgets = [];
          for (int i = 0; i < snapshot.data.length; i++){
            Widget tourneyTile = new ListTile(
                title: Text(snapshot.data[0]),
                onTap: (){}
            );
            myWidgets.add(tourneyTile);
          }
          return Column(children: myWidgets);
        }
        else {
          return CircularProgressIndicator();
        }
      },
    );
    widgets.add(futureBuilder);
    return ListView(children: widgets,);
  }

  PopupMenuItem createPopupMenuItem(
      String filterText, bool checked, int value) {
    if (checked) {
      return PopupMenuItem(
        value: value,
        child: Flex(
          direction: Axis.horizontal,
          children: <Widget>[Text(filterText), new Icon(Icons.check_circle)],
        ),
      );
    } else {
      return PopupMenuItem(
        value: value,
        child: Text(filterText),
      );
    }
  }
}
