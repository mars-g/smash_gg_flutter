// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert' show json, utf8;
import 'dart:io';


class Api {
  /// We use the `dart:io` HttpClient. More details: https://flutter.io/networking/
  // We specify the type here for readability. Since we're defining a final
  // field, the type is determined at initialization.
  final HttpClient _httpClient = HttpClient();

  /// The API endpoint we want to hit.
  ///
  /// This API doesn't have a key but often, APIs do require authentication
  final String _url = 'api.smash.gg';
  ///secondary url is the secret api route not mentioned in the smash.gg docs
  ///should be used for creating the homepage and other things
  final String _url2 = 'smash.gg';




  Future getListOfTourneys(String searchTerm, List filters) async{
    //first step is to generate filter params
    String upcoming = 'false';
    String featured = '';
    String eventRegOpen = '';
    String regOpen = '';
    String attendeeCount = '';
    bool attendeeFlag = false;
    String isLeague = '';
    String online = '';
    String offline = '';
    String name = '';
    if (filters[0]){
        upcoming = 'true';
    }
    if (filters[1]){
      featured = ',"isFeatured":true';
    }
    if (filters[2]){
      eventRegOpen = ',"eventRegOpen":true';
    }
    if (filters[3]){
      regOpen = ',"regOpen":true';
    }
    if (filters[4]){
      attendeeCount += '"lt:100"';
      attendeeFlag = true;
    }
    if (filters[5]){
      if (attendeeFlag){
        attendeeCount += ',';
      }
      attendeeCount += '"gt:100,lte:200"';
      attendeeFlag = true;
    }
    if (filters[6]){
      if (attendeeFlag){
        attendeeCount += ',';
      }
      attendeeCount += '"gt:200,lte:500"';
      attendeeFlag = true;
    }
    if (filters[7]){
      if (attendeeFlag){
        attendeeCount += ',';
      }
      attendeeCount += '"gt:500,lte:1000"';
      attendeeFlag = true;
    }
    if (filters[8]){
      if (attendeeFlag){
        attendeeCount += ',';
      }
      attendeeCount += '"gt:1000"';
      attendeeFlag = true;
    }
    if (attendeeFlag){
      attendeeCount = ',"attendeeCount":[' + attendeeCount + ']';
    }
    if (filters[11]){
      isLeague = ',"isLeague": true';
    }
    if (filters[12]){
      online = ',"online":true';
    }
    if(filters[13]){
      offline = ',"offline::true';
    }
    if (searchTerm != ''){
      name = ',"name":"' + searchTerm + '"';
    }
    final uri = Uri.https(_url2, '/api/-/gg_api./public/tournaments/schedule;filter={"upcoming":$upcoming,"videogameIds":1' + name + featured + regOpen + eventRegOpen + attendeeCount + isLeague + online + offline + '}');
    final jsonResponse = await _getJson(uri);
    if (jsonResponse == null || jsonResponse['items'] == null) {
      print('Error retrieving tournament.');
      print(uri);
      return null;
    }
    print(uri);
    if (jsonResponse['items']['entities']['tournament'] is List){
      return jsonResponse['items']['entities']['tournament'];

    }
    return jsonResponse['items']['entities'];
  }

  /// Gets all the main info from a tourney
  ///
  /// The `tourney` parameter is the name of the tourney
  /// We pass this into the query parameter in the API call.
  ///
  /// Returns a list. Returns null on error.
  Future<Map> getTourneyInfo(String tourney) async {
    final uri = Uri.https(_url, '/$tourney');
    final jsonResponse = await _getJson(uri);
    if (jsonResponse == null || jsonResponse['entities'] == null) {
      print('Error retrieving tournament.');
      print(jsonResponse['entities']['tournament']);
      print(_url +  '/tournament/$tourney');
      return null;
    }


    return jsonResponse['entities']['tournament'];
  }

  ///Gets events from a specific tourney
  ///
  /// Tourney param is name of tourney
  ///
  /// Returns a list of the events, returns null on error
  Future<List> getTourneyEvents(String tourney) async{
    Map<String,String> params = new Map();
    params['expand\[\]'] = 'event';
    final uri = Uri.https(_url, '/$tourney',params);
    final jsonResponse = await _getJson(uri);
    if (jsonResponse == null || jsonResponse['entities'] == null){
      print("Error retrieving events");
      print(uri);
      return null;
    }
    return jsonResponse['entities']['event'];
  }

  ///Gets phases from a specific tourney
  ///
  /// Tourney param is name of tourney
  ///
  /// Returns a list of the phases, returns null on error
  Future<List> getTourneyPhases(String tourney) async {
    Map<String,String> params = new Map();
    params['expand\[\]'] = 'phase';
    final uri = Uri.https(_url, '/tournament/$tourney',params);
    final jsonResponse = await _getJson(uri);
    if (jsonResponse == null || jsonResponse['entities'] == null){
      print("Error retrieving events");
      print(uri);
      return null;
    }
    return jsonResponse['entities']['phase'];
  }

  ///Gets groups from a specific tourney
  ///
  /// Tourney param is name of tourney
  ///
  /// Returns a list of the groups, returns null on error
  Future<List> getTourneyGroups(String tourney) async {
    Map<String,String> params = new Map();
    params['expand\[\]'] = 'groups';
    final uri = Uri.https(_url, '/tournament/$tourney',params);
    final jsonResponse = await _getJson(uri);
    if (jsonResponse == null || jsonResponse['entities'] == null){
      print("Error retrieving events");
      print(uri);
      return null;
    }
    return jsonResponse['entities']['groups'];
  }

  ///Gets event info from a specific tourney and specific event
  ///
  /// Tourney param is name of tourney
  ///
  /// Returns a map of the event info, returns null on error
  Future<Map> getEventInfo(String tourney, String event) async {
    final uri = Uri.https(_url, '/tournament/$tourney/event/$event');
    final jsonResponse = await _getJson(uri);
    if (jsonResponse == null || jsonResponse['entities'] == null){
      print("Error retrieving events");
      print(uri);
      return null;
    }
    return jsonResponse['entities']['event'];
  }



  ///Gets list of all attendees for a tourney
  ///
  /// Requires the slug of the tourney
  Future<List> getAttendeesList(String slug) async {
    Map<String,String> params = new Map();
    params['expand\[\]'] = 'participants';
    final uri = Uri.https(_url, '/$slug',params);
    final jsonResponse = await _getJson(uri);
    if (jsonResponse == null || jsonResponse['entities'] == null){
      print("Error retrieving attendees");
      print(uri);
      return null;
    }
    return jsonResponse['entities']['participants'];
  }

  ///List of all the entrants
  Future<List> getEntrantsList(String slug) async{
    Map<String,String> params = new Map();
    params['expand\[\]'] = 'entrants';
    final uri = Uri.https(_url, '/$slug',params);
    final jsonResponse = await _getJson(uri);
    if (jsonResponse == null || jsonResponse['entities'] == null){
      print("Error retrieving entrants");
      print(uri);
      return null;
    }
    return jsonResponse['entities']['entrants'];
  }

  ///Returns list of top players order
  ///
  /// requires the slug for the event
  Future<List> getTopAttendees(String slug) async{
    final uri = Uri.https(_url2, '/api/-/gg_api./$slug;expand=["details","fullEntrantCount","tagsByEntity","tagsByContainer","stream"];mutations=["tournamentEventCardData"]');
    final jsonResponse = await _getJson(uri);
    if (jsonResponse == null || jsonResponse['entities'] == null){
      print("Error retrieving entrants");
      print(uri);
      return null;
    }
    Map returnMap = jsonResponse['entities']['event']['mutations']['cardData'];
    for (var value in returnMap.values){
      return value['topAttendees'];
    }

    return jsonResponse['entities']['event'];
  }

  ///Returns list of placements for top players
  ///
  /// requires the slug for the event
  Future<List> getTopPlacers(String slug) async{
    final uri = Uri.https(_url2, '/api/-/gg_api./$slug;expand=["details","fullEntrantCount","tagsByEntity","tagsByContainer","stream"];mutations=["tournamentEventCardData"]');
    final jsonResponse = await _getJson(uri);
    if (jsonResponse == null || jsonResponse['entities'] == null){
      print("Error retrieving entrants");
      print(uri);
      return null;
    }
    Map returnMap = jsonResponse['entities']['event']['mutations']['cardData'];
    for (var value in returnMap.values){
      return value['topPlacers'];
    }

    return jsonResponse['entities']['event'];
  }

  /// Fetches and decodes a JSON object represented as a Dart [Map].
  ///
  /// Returns null if the API server is down, or the response is not JSON.
  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    try {
      final httpRequest = await _httpClient.getUrl(uri);
      final httpResponse = await httpRequest.close();
      if (httpResponse.statusCode != HttpStatus.OK) {
        return null;
      }
      // The response is sent as a Stream of bytes that we need to convert to a
      // `String`.
      final responseBody = await httpResponse.transform(utf8.decoder).join();
      // Finally, the string is parsed into a JSON object.
      return json.decode(responseBody);
    } on Exception catch (e) {
      print('$e');
      return null;
    }
  }
}
