import 'dart:async';
import 'dart:convert' show json, utf8;
import 'dart:io';
import 'package:http/http.dart' as http;


class Api {
  final HttpClient _httpClient = HttpClient();

  /// The API endpoint we want to hit.
  ///
  /// This API doesn't have a key but often, APIs do require authentication
  final String _url = 'api.smash.gg';
  ///secondary url is the secret api route not mentioned in the smash.gg docs
  ///should be used for creating the homepage and other things
  final String _url2 = 'smash.gg';




  Future getListOfTourneys(String searchTerm, List filters, String gameID, String countryCode, String addrState, int pageNum, String distFrom, String distance) async{
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
    if (addrState != 'null'){
      addrState = '"' + addrState + '"';
    }
    final uri = Uri.https(_url2, '/api/-/gg_api./public/tournaments/schedule;filter={"upcoming":$upcoming,"videogameIds":$gameID,' + '"countryCode":"$countryCode",' + '"addrState":$addrState,' + '"distance":"$distance",' + '"distanceFrom":"$distFrom"' +name + featured + regOpen + eventRegOpen + attendeeCount + isLeague + online + offline + '};page=$pageNum;per_page=15');
    final jsonResponse = await _getJson(uri);
    if (jsonResponse == null || jsonResponse['items'] == null) {
      print('Error retrieving tournament.');
      print(uri);
      return null;
    }
    if (jsonResponse['items']['entities']['tournament'] is List){
      return jsonResponse['items']['entities']['tournament'];

    }
    return jsonResponse['items']['entities'];
  }


  ///Attempt at parsing the post api for smashgg
  ///
  /// THe base url is smash.gg/api/~/gql-public
  /// Parameters are the operation name, the query, and variables
  Future<List> getGQLPost(String operationName, String tournamentId, Map filter, String page) async {
    final url = "https://" + _url2 + '/api/-/gql-public';
    Map params = {
      "operationName" : operationName,
      "variables" :
    {
      'tournamentId' : tournamentId,
      'filter' : filter,
      'page' : page,
      'sortBy' : 'playerRank ASC',
      'isAdmin' : false,
      'publicCache' : true,
    },
      'query' : "query TournamentAttendees(\$tournamentId: Int!, \$filter: ParticipantPageFilter = {}, \$page: Int = 1, \$sortBy: String = \"id DESC\", \$isAdmin: Boolean = false) {\n  attendeeTournament: tournament(id: \$tournamentId) {\n    id\n    participants(isAdmin: \$isAdmin, query: {page: \$page, perPage: 25, sortBy: \$sortBy, filter: \$filter}) {\n      pageInfo {\n        ...pageInfo\n        __typename\n      }\n      nodes {\n        id\n        gamerTag\n        prefix\n        balance @include(if: \$isAdmin)\n        checkedIn @include(if: \$isAdmin)\n        checkedInAt @include(if: \$isAdmin)\n        createdAt @include(if: \$isAdmin)\n        events {\n          id\n          hasDecks\n          rulesetSettings\n          deckSubmissionDeadline\n          name\n          type\n          __typename\n        }\n        ...contactInfo\n        player {\n          ...playerAvatar\n          __typename\n        }\n        entrants {\n          ...scheduleInfo\n          __typename\n        }\n        decks {\n          id\n          valid\n          participantId\n          entrantId\n          __typename\n        }\n        teams @include(if: \$isAdmin) {\n          ...team\n          __typename\n        }\n        __typename\n      }\n      __typename\n    }\n    __typename\n  }\n}\n\nfragment pageInfo on PageInfo {\n  page\n  total\n  perPage\n  totalPages\n  sortBy\n  __typename\n}\n\nfragment playerAvatar on Player {\n  id\n  name\n  prefix\n  gamerTag\n  color\n  twitchStream\n  twitterHandle\n  youtube\n  images {\n    ...image\n    __typename\n  }\n  __typename\n}\n\nfragment image on Image {\n  id\n  height\n  isOriginal\n  type\n  url\n  width\n  __typename\n}\n\nfragment scheduleInfo on Entrant {\n  id\n  eventId\n  name\n  seeds {\n    id\n    entrantId\n    phase {\n      id\n      groupCount\n      phaseOrder\n      name\n      __typename\n    }\n    phaseGroup {\n      id\n      displayIdentifier\n      startAt\n      state\n      waveId\n      wave {\n        id\n        startAt\n        __typename\n      }\n      __typename\n    }\n    __typename\n  }\n  event {\n    id\n    name\n    __typename\n  }\n  __typename\n}\n\nfragment team on Team {\n  id\n  name\n  complete\n  eventId\n  entrantId\n  acceptedMembers {\n    id\n    name\n    __typename\n  }\n  __typename\n}\n\nfragment contactInfo on Participant {\n  contactInfo {\n    id\n    name\n    nameFirst\n    nameLast\n    state\n    stateId\n    city\n    country\n    countryId\n    zipcode\n    __typename\n  }\n  __typename\n}\n"
    };

    final jsonResponse = await _postJson(url, params);
    if (jsonResponse == null || jsonResponse['data'] == null) {
      print('Error retrieving tournament.');
      print(jsonResponse['entities']['tournament']);
      print(url);
      return null;
    }

    return jsonResponse['data']['attendeeTournament']['participants']['nodes'];
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

  Future<List> getAttendeesInfo(String slug, int pageNum, String filter) async{
    Map<String,String> params = new Map();
    params['page'] = '$pageNum';
    params['filter'] = '{incompleteTeam=$filter}';
    final uri = Uri.https(_url, '/$slug/attendees',params);
    final jsonResponse = await _getJson(uri);
    if (jsonResponse == null || jsonResponse['items'] == null){
      print("Error retrieving attendees");
      print(uri);
      return null;
    }
    print(uri);
    return jsonResponse['items']['entities']['attendee'];
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

  ///Fetches and decodes a JSON object for a post request
  ///Requires a map of the params as well as the url to send post request to
  ///Some of the code taken from https://stackoverflow.com/a/49801308/9976250
  /// Returns null if no reponse
  Future<Map<String, dynamic>> _postJson(String url, Map params) async {
    try {
      String jsonString = json.encode(params);
      Map<String,String> headers = {
        'Content-type' : 'application/json',
        'Accept' : 'gzip,deflate,br'
      };
      final httpResponse =
          await http.post(url, body: jsonString, headers: headers);
      if (httpResponse.statusCode != HttpStatus.OK) {
        return null;
      }

      final jsonResponse = json.decode(httpResponse.body);
      return jsonResponse;
      // Finally, the string is parsed into a JSON object.
    } on Exception catch (e) {
      print('$e');
      return null;
    }
  }



  // Copyright 2017 The Chromium Authors. All rights reserved.
  // Use of this source code is governed by a BSD-style license that can be
  // found in the LICENSE file.
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
