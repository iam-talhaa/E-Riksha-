import 'dart:convert';
import 'dart:io';

import 'package:e_riksha/data/AppException.dart';
import 'package:e_riksha/data/Network/BaseApiService.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Networkapiservices extends Baseapiservice {
  
  Future<dynamic> _getGetApiService(String url) async {
    dynamic responseJson;
    try {
      final reponse = await http
          .get(Uri.parse(url))
          .timeout(Duration(seconds: 10));

      responseJson = returnResponse(reponse);
    } on SocketException {
      throw FetchDataException("NO Internet Connection");
    }
    return responseJson;
  }

  returnResponse(http.Response reponse) {
    switch (reponse.statusCode) {
      case 200:
        dynamic repoonse = jsonDecode(reponse.body);
        return reponse;
      case 400:
        throw BadRequestException('Bad Request');
      case 404:
        throw FetchDataException('User Not Found');
    }
  }
}
