import 'package:flutter/material.dart';
import 'api.dart';
import 'TourneyItem.dart';
import 'TourneyPage.dart';
import 'AboutPage.dart';
import 'prefs.dart';
import 'dart:async';
import 'package:map_view/map_view.dart';
import 'package:google_maps_webservice/places.dart' as places;

//put your api key here
final apiKey = "";

void main() {
  MapView.setApiKey(apiKey);
  runApp(new MyApp());
}

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

_MyHomePageState _myHomePageState = new _MyHomePageState();

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
  _MyHomePageState createState() => _myHomePageState;
}

class _MyHomePageState extends State<MyHomePage> {
  Api _api = Api();
  String searchTerm = "";
  Map filters;
  int pageNum = 1;
  ScrollController _scrollController = new ScrollController();
  var currentGameID = '""';
  var countryCode = '';
  var addrState = 'null';
  var _selection;
  var distance = "50mi";
  var distFrom = "";

  //this variable will be updated depending on whether usa or canada is chosen
  List<String> regions = [""];

  //list of all games
  var gamesTexts = [
    'All Games',
    'Melee',
    'Smash 4',
    'Street Fighter V',
    'Rocket League',
    'Super Smash Bros',
    'Killer Instinct',
    'DragonBall FighterZ'
  ];

  //bools to keep track of which games are selected
  var gameChecks = [true, false, false, false, false, false, false, false];

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
    'Offline'
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
    false,
  ];

  @override
  void initState() {
    super.initState();
    Prefs.init();
  }

  @override
  void dispose() {
    Prefs.dispose();
    super.dispose();
  }

  void _updateCountry(var value) {
    setState(() {
      countryCode = countryCodes[value];
      _selection = value;
      //value is the us
      if (value == 0) {
        regions = stateList;
      }
      else if (value == 1){
        regions = provinceList;
      }
      else {
        Navigator.of(context).pop();
      }
    });
    return;
  }

  void _updateRegion(var value) {
    if (value != "") {
      setState(() {
        addrState = value;
      });
    }
    return;
  }

  void _updateFilters(var value) {
    if (value == 10 && filterChecks[value] == false){
      showDialog(context: context,
      builder: (BuildContext context) => new StatefulDialog2(title: new Text("Choose City")));
    }
    if (value == 9 && filterChecks[value] == false) {
      regions = [""];

      showDialog(
          context: context,
          builder: (BuildContext context) => new StatefulDialog(
                title: new Text("Select Location"),
              ));
    }
    setState(() {
      //check if value is the location value
      //Switch the value of the filter
      if (value == 9 && filterChecks[value] == true) {
        countryCode = '';
        addrState = 'null';
      }
      if (value == 10 && filterChecks[value] == true) {
        distFrom = '';
      }
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

  void doNil() {
    Navigator.of(context).push(new MaterialPageRoute(
        builder: (BuildContext context) =>
        new AboutPage()));
  }

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

  void _updateGames(var value) {
    setState(() {
      if (gameChecks[value]) {
        gameChecks[value] = false;
        gameChecks[0] = true;
        currentGameID = '""';
        return;
      }
      for (int i = 0; i < gameChecks.length; i++) {
        gameChecks[i] = false;
      }
      gameChecks[value] = true;
      //all games
      if (value == 0) {
        currentGameID = '""';
      }
      //melee
      else if (value == 1) {
        currentGameID = "1";
      }
      //sm4sh
      else if (value == 2) {
        currentGameID = "3";
      }
      //sfv
      else if (value == 3) {
        currentGameID = "7";
      }
      //rocket league
      else if (value == 4) {
        currentGameID = "14";
      }
      //super smash bros
      else if (value == 5) {
        currentGameID = "4";
      }
      //killer instinct
      else if (value == 6) {
        currentGameID = "19";
      }
      //dbfz
      else if (value == 7) {
        currentGameID = "287";
      }
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
                "About",
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
            Row(children: <Widget>[
              PopupMenuButton(
                itemBuilder: (BuildContext context) {
                  var itemList = new List<PopupMenuItem>();
                  for (int j = 0; j < gamesTexts.length; j++) {

                    itemList.add(CheckedPopupMenuItem(
                      value: j,
                      checked: gameChecks[j],
                      child: Text(gamesTexts[j]),
                    ));
                  }
                  return itemList;
                },
                onSelected: _updateGames,
              ),
              Expanded(
                  child: TextField(
                onChanged: _search,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  fillColor: Colors.grey[150],
                  filled: true,
                  hintText: "Search for a tourney",
                  prefixIcon: Icon(Icons.search),
                ),
              ))
            ]),
            new Container(
              child: new FutureBuilder(
                future: _api.getListOfTourneys(searchTerm, filterChecks,
                    currentGameID, countryCode, addrState, pageNum, distFrom, distance),
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
                //add a divider
                if (i == 2 || i == 4 || i == 9 || i == 11 || i == 12){
                  itemList.add(PopupMenuItem(child: PopupMenuDivider()));
                }
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

  Widget drawerList() {
    List<Widget> widgets = [];
    widgets.add(DrawerHeader(
      child: Center(
          child: Text(
        "Recently Viewed",
        style: TextStyle(fontSize: 30.0, fontFamily: 'Raleway'),
      )),
      decoration: BoxDecoration(color: Colors.redAccent),
    ));
    var stringList = Prefs.getStringListF('recentTourneys');

    Widget futureBuilder = new FutureBuilder(
      future: stringList,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length == 1 && snapshot.data[0] == "") {
            return new Container();
          }
          List<Widget> myWidgets = [];
          for (int i = 0; i < snapshot.data.length; i++) {
            Widget tourneyTile = new FutureBuilder(
              future: _api.getTourneyInfo(snapshot.data[i]),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return new ListTile(
                      leading: findImage(snapshot.data),
                      title: Text(snapshot.data['name']),
                      onTap: () {
                        List<String> recentList =
                            Prefs.getStringList('recentTourneys');
                        if (recentList[0] == "") {
                          recentList[0] = snapshot.data['slug'];
                        } else if (recentList.indexOf(snapshot.data['slug']) !=
                            -1) {
                          recentList.remove(snapshot.data['slug']);
                          recentList.insert(0, snapshot.data['slug']);
                        } else if (recentList.length == 10) {
                          recentList.insert(0, snapshot.data['slug']);
                          recentList.removeLast();
                        } else {
                          recentList.insert(0, snapshot.data['slug']);
                        }
                        Prefs.setStringList('recentTourneys', recentList);
                        Navigator.of(context).push(new MaterialPageRoute(
                            builder: (BuildContext context) =>
                                new TourneyPage(snapshot.data)));
                      });
                } else if (snapshot.hasError) {
                  return new Text("ERROR RETRIEVING TOURNEY");
                } else {
                  return new Container();
                }
              },
            );
            myWidgets.add(tourneyTile);
          }
          return Column(children: myWidgets);
        } else {
          return CircularProgressIndicator();
        }
      },
    );
    widgets.add(futureBuilder);
    return ListView(
      children: widgets,
    );
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

class StatefulDialog extends StatefulWidget {
  final Widget title;
  final Widget content;
  StatefulDialog({this.title: const Text(""), this.content: const Text(""),});

  @override
  _StatefulDialogState createState() => new _StatefulDialogState(title: this.title, content: this.content);
}


//Stateful Dialog for updating alert dialog
class _StatefulDialogState extends State<StatefulDialog>{
  final Widget title;
  final Widget content;
  var _selection;
  List<String> regions = [""];

  _StatefulDialogState({this.title: const Text(""), this.content: const Text("")});

  void _updateCountry(var value) {
    _myHomePageState.setState(() {
      _myHomePageState.countryCode = countryCodes[value];
      //value is the us
    });
    setState(() {
      _selection = value;
      if (value == 0) {
        regions = stateList;
      }
      else if (value == 1){
        regions = provinceList;
      }
      else {
        Navigator.of(context).pop();
      }
    });
    return;
  }

  void _updateRegion(var value) {
    if (value != "") {
      _myHomePageState.setState(() {
        _myHomePageState.addrState = value;
        Navigator.of(context).pop();
      });
    }
    return;
  }

  @override
  Widget build(BuildContext content){
    return new AlertDialog(
        title: this.title,
        content: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            //country button
            ButtonTheme(
                alignedDropdown: true,
                child: DropdownButton(
                  value: _selection,
                  hint: new Text("Country"),
                  items: countryNames.map((String value) {
                    return new DropdownMenuItem(
                      value: countryNames.lastIndexOf(value),
                      child: SizedBox(width: 150.0, child: Text(value)),
                    );
                  }).toList(),
                  onChanged: _updateCountry,
                )),
            Padding(
              padding: EdgeInsets.all(16.0),
            ),
            ButtonTheme(
                alignedDropdown: true,
                child: DropdownButton(
                  hint: new Text("State/Province"),
                  items: regions.map((String value) {
                    return new DropdownMenuItem(
                      value: value,
                      child: SizedBox(width: 150.0, child: Text(value)),
                    );
                  }).toList(),
                  onChanged: _updateRegion,
                )),
          ],
        ),
    );
  }

}

class StatefulDialog2 extends StatefulWidget {
  final Widget title;
  final Widget content;
  StatefulDialog2({this.title: const Text(""), this.content: const Text(""),});

  @override
  _StatefulDialogState2 createState() => new _StatefulDialogState2(title: this.title, content: this.content);
}


//Stateful Dialog for updating alert dialog
class _StatefulDialogState2 extends State<StatefulDialog2>{
  final Widget title;
  final Widget content;
  var radioValue = 1;
  _StatefulDialogState2({this.title: const Text(""), this.content: const Text("")});

  void updateRadio(int value){
    setState(() {
      radioValue = value;
    });
    if (value == 0){
      _myHomePageState.distance = "10mi";
    }
    else if (value == 1){
      _myHomePageState.distance = "50mi";
    }
    else if (value == 2){
      _myHomePageState.distance = "100mi";
    }
    else if (value == 3){
      _myHomePageState.distance = "250mi";
    }
  }

  @override
  Widget build(BuildContext content){
    return new AlertDialog(
      title: this.title,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(children: <Widget>[Radio<int>(
              value: 0,
              groupValue: radioValue,
              onChanged: updateRadio,
            ),
            Text("10 mi")
          ]),
          Row(children: <Widget>[
            Radio<int>(
              value: 1,
              groupValue: radioValue,
              onChanged: updateRadio,
            ),
            Text("50 mi")
          ]),
          Row(children: <Widget>[
            Radio<int>(
              value: 2,
              groupValue: radioValue,
              onChanged: updateRadio,
            ),
            Text("100 mi")
          ]),
          Row(children: <Widget>[
            Radio<int>(
              value: 3,
              groupValue: radioValue,
              onChanged: updateRadio,
            ),
            Text("250 mi")
          ]),
          TextField(
            onSubmitted: listPlaces,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              fillColor: Colors.grey[150],
              filled: true,
              hintText: "Search for a tourney",
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ],
      ),
    );
  }
  Future listPlaces(String input) async{
    var placeApi = new places.GoogleMapsPlaces(apiKey);
    var response = await placeApi.searchByText(input);
    _myHomePageState.setState((){
      _myHomePageState.distFrom = response.results[0].geometry.location.lat.toString() + ',' + response.results[0].geometry.location.lng.toString();
    });
    Navigator.of(context).pop();
    return;
  }

}

//list of all country names
final countryNames = [
  "United States of America",
  "Canada",
  "Afghanistan",
  "Aland Islands",
  "Albania",
  "Algeria",
  "American Samoa",
  "Andorra",
  "Angola",
  "Anguilla",
  "Antarctica",
  "Antigua and Barbuda",
  "Argentina",
  "Armenia",
  "Aruba",
  "Australia",
  "Austria",
  "Azerbaijan",
  "Bahamas",
  "Bahrain",
  "Bangladesh",
  "Barbados",
  "Belarus",
  "Belgium",
  "Belize",
  "Benin",
  "Bermuda",
  "Bhutan",
  "Bolivia",
  "Bosnia and Herzegovina",
  "Botswana",
  "Bouvet Island",
  "Brazil",
  "British Virgin Islands",
  "British Indian Ocean Territory",
  "Brunei Darussalam",
  "Bulgaria",
  "Burkina Faso",
  "Burundi",
  "Cambodia",
  "Cameroon",
  "Cape Verde",
  "Cayman Islands",
  "Central African Republic",
  "Chad",
  "Chile",
  "China",
  "Hong Kong, SAR China",
  "Macao, SAR China",
  "Christmas Island",
  "Cocos (Keeling) Islands",
  "Colombia",
  "Comoros",
  "Congo (Brazzaville)",
  "Congo (Kinshasa)",
  "Cook Islands",
  "Costa Rica",
  "CÃ´te d'Ivoire",
  "Croatia",
  "Cuba",
  "Cyprus",
  "Czech Republic",
  "Denmark",
  "Djibouti",
  "Dominica",
  "Dominican Republic",
  "Ecuador",
  "Egypt",
  "El Salvador",
  "Equatorial Guinea",
  "Eritrea",
  "Estonia",
  "Ethiopia",
  "Falkland Islands (Malvinas)",
  "Faroe Islands",
  "Fiji",
  "Finland",
  "France",
  "French Guiana",
  "French Polynesia",
  "French Southern Territories",
  "Gabon",
  "Gambia",
  "Georgia",
  "Germany",
  "Ghana",
  "Gibraltar",
  "Greece",
  "Greenland",
  "Grenada",
  "Guadeloupe",
  "Guam",
  "Guatemala",
  "Guernsey",
  "Guinea",
  "Guinea-Bissau",
  "Guyana",
  "Haiti",
  "Heard and Mcdonald Islands",
  "Holy See (Vatican City State)",
  "Honduras",
  "Hungary",
  "Iceland",
  "India",
  "Indonesia",
  "Iran",
  "Islamic Republic of Iraq",
  "Ireland",
  "Isle of Man",
  "Israel",
  "Italy",
  "Jamaica",
  "Japan",
  "Jersey",
  "Jordan",
  "Kazakhstan",
  "Kenya",
  "Kiribati",
  "Korea (North)",
  "Korea (South)",
  "Kuwait",
  "Kyrgyzstan",
  "Lao PDR",
  "Latvia",
  "Lebanon",
  "Lesotho",
  "Liberia",
  "Libya",
  "Liechtenstein",
  "Lithuania",
  "Luxembourg",
  "Macedonia, Republic of",
  "Madagascar",
  "Malawi",
  "Malaysia",
  "Maldives",
  "Mali",
  "Malta",
  "Marshall Islands",
  "Martinique",
  "Mauritania",
  "Mauritius",
  "Mayotte",
  "Mexico",
  "Micronesia, Federated States of",
  "Moldova",
  "Monaco",
  "Mongolia",
  "Montenegro",
  "Montserrat",
  "Morocco",
  "Mozambique",
  "Myanmar",
  "Namibia",
  "Nauru",
  "Nepal",
  "Netherlands",
  "Netherlands Antilles",
  "New Caledonia",
  "New Zealand",
  "Nicaragua",
  "Niger",
  "Nigeria",
  "Niue",
  "Norfolk Island",
  "Northern Mariana Islands",
  "Norway",
  "Oman",
  "Pakistan",
  "Palau",
  "Palestinian Territory",
  "Panama",
  "Papua New Guinea",
  "Paraguay",
  "Peru",
  "Philippines",
  "Pitcairn",
  "Poland",
  "Portugal",
  "Puerto Rico",
  "Qatar",
  "RÃ©union",
  "Romania",
  "Russian Federation",
  "Rwanda",
  "Saint-BarthÃ©lemy",
  "Saint Helena",
  "Saint Kitts and Nevis",
  "Saint Lucia",
  "Saint-Martin (French part)",
  "Saint Pierre and Miquelon",
  "Saint Vincent and Grenadines",
  "Samoa",
  "San Marino",
  "Sao Tome and Principe",
  "Saudi Arabia",
  "Senegal",
  "Serbia",
  "Seychelles",
  "Sierra Leone",
  "Singapore",
  "Slovakia",
  "Slovenia",
  "Solomon Islands",
  "Somalia",
  "South Africa",
  "South Georgia and the South Sandwich Islands",
  "South Sudan",
  "Spain",
  "Sri Lanka",
  "Sudan",
  "Suriname",
  "Svalbard and Jan Mayen Islands",
  "Swaziland",
  "Sweden",
  "Switzerland",
  "Syrian Arab Republic (Syria)",
  "Taiwan, Republic of China",
  "Tajikistan",
  "Tanzania, United Republic of",
  "Thailand",
  "Timor-Leste",
  "Togo",
  "Tokelau",
  "Tonga",
  "Trinidad and Tobago",
  "Tunisia",
  "Turkey",
  "Turkmenistan",
  "Turks and Caicos Islands",
  "Tuvalu",
  "Uganda",
  "Ukraine",
  "United Arab Emirates",
  "United Kingdom",
  "US Minor Outlying Islands",
  "Uruguay",
  "Uzbekistan",
  "Vanuatu",
  "Venezuela (Bolivarian Republic)",
  "Viet Nam",
  "Virgin Islands, US",
  "Wallis and Futuna Islands",
  "Western Sahara",
  "Yemen",
  "Zambia",
  "Zimbabwe"
];

//corresponding codes for countries
final countryCodes = [
  "US",
  "CA",
  "AF",
  "AX",
  "AL",
  "DZ",
  "AS",
  "AD",
  "AO",
  "AI",
  "AQ",
  "AG",
  "AR",
  "AM",
  "AW",
  "AU",
  "AT",
  "AZ",
  "BS",
  "BH",
  "BD",
  "BB",
  "BY",
  "BE",
  "BZ",
  "BJ",
  "BM",
  "BT",
  "BO",
  "BA",
  "BW",
  "BV",
  "BR",
  "VG",
  "IO",
  "BN",
  "BG",
  "BF",
  "BI",
  "KH",
  "CM",
  "CV",
  "KY",
  "CF",
  "TD",
  "CL",
  "CN",
  "HK",
  "MO",
  "CX",
  "CC",
  "CO",
  "KM",
  "CG",
  "CD",
  "CK",
  "CR",
  "CI",
  "HR",
  "CU",
  "CY",
  "CZ",
  "DK",
  "DJ",
  "DM",
  "DO",
  "EC",
  "EG",
  "SV",
  "GQ",
  "ER",
  "EE",
  "ET",
  "FK",
  "FO",
  "FJ",
  "FI",
  "FR",
  "GF",
  "PF",
  "TF",
  "GA",
  "GM",
  "GE",
  "DE",
  "GH",
  "GI",
  "GR",
  "GL",
  "GD",
  "GP",
  "GU",
  "GT",
  "GG",
  "GN",
  "GW",
  "GY",
  "HT",
  "HM",
  "VA",
  "HN",
  "HU",
  "IS",
  "IN",
  "ID",
  "IR",
  "IQ",
  "IE",
  "IM",
  "IL",
  "IT",
  "JM",
  "JP",
  "JE",
  "JO",
  "KZ",
  "KE",
  "KI",
  "KP",
  "KR",
  "KW",
  "KG",
  "LA",
  "LV",
  "LB",
  "LS",
  "LR",
  "LY",
  "LI",
  "LT",
  "LU",
  "MK",
  "MG",
  "MW",
  "MY",
  "MV",
  "ML",
  "MT",
  "MH",
  "MQ",
  "MR",
  "MU",
  "YT",
  "MX",
  "FM",
  "MD",
  "MC",
  "MN",
  "ME",
  "MS",
  "MA",
  "MZ",
  "MM",
  "NA",
  "NR",
  "NP",
  "NL",
  "AN",
  "NC",
  "NZ",
  "NI",
  "NE",
  "NG",
  "NU",
  "NF",
  "MP",
  "NO",
  "OM",
  "PK",
  "PW",
  "PS",
  "PA",
  "PG",
  "PY",
  "PE",
  "PH",
  "PN",
  "PL",
  "PT",
  "PR",
  "QA",
  "RE",
  "RO",
  "RU",
  "RW",
  "BL",
  "SH",
  "KN",
  "LC",
  "MF",
  "PM",
  "VC",
  "WS",
  "SM",
  "ST",
  "SA",
  "SN",
  "RS",
  "SC",
  "SL",
  "SG",
  "SK",
  "SI",
  "SB",
  "SO",
  "ZA",
  "GS",
  "SS",
  "ES",
  "LK",
  "SD",
  "SR",
  "SJ",
  "SZ",
  "SE",
  "CH",
  "SY",
  "TW",
  "TJ",
  "TZ",
  "TH",
  "TL",
  "TG",
  "TK",
  "TO",
  "TT",
  "TN",
  "TR",
  "TM",
  "TC",
  "TV",
  "UG",
  "UA",
  "AE",
  "GB",
  "UM",
  "UY",
  "UZ",
  "VU",
  "VE",
  "VN",
  "VI",
  "WF",
  "EH",
  "YE",
  "ZM",
  "ZW"
];

final stateList = [
  "AL",
  "AK",
  "AZ",
  "AR",
  "CA",
  "CO",
  "CT",
  "DE",
  "FL",
  "GA",
  "HI",
  "ID",
  "IL",
  "IN",
  "IA",
  "KS",
  "KY",
  "LA",
  "ME",
  "MD",
  "MA",
  "MI",
  "MN",
  "MS",
  "MO",
  "MT",
  "NE",
  "NV",
  "NH",
  "NJ",
  "NM",
  "NY",
  "NC",
  "ND",
  "OH",
  "OK",
  "OR",
  "PA",
  "RI",
  "SC",
  "SD",
  "TN",
  "TX",
  "UT",
  "VT",
  "VA",
  "WA",
  "WV",
  "WI",
  "WY"
];

final provinceList = [
  "AB",
  "BC",
  "LB",
  "MB",
  "NB",
  "NL",
  "NS",
  "NU",
  "ON",
  "PE",
  "QC",
  "SK",
  "YU"
];