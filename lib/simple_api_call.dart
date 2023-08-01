library simple_api_call;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SimpleApiCall {
  final String baseUrl;
  final Duration timeout;
  final bool persistDataLocally;

  SimpleApiCall({
    @required this.baseUrl,
    this.timeout = const Duration(seconds: 30),
    this.persistDataLocally = false,
  });

  Future<T> fetchData<T>(
    String endpoint,
    T Function(Map<String, dynamic> json) fromJson,
  ) async {
    return _performApiCall<T>(
      () => http.get(Uri.parse('$baseUrl/$endpoint')),
      fromJson,
    );
  }

  Future<T> putData<T>(
    String endpoint,
    Map<String, String> body,
    T Function(Map<String, dynamic> json) fromJson,
  ) async {
    return _performApiCall<T>(
      () => http.put(Uri.parse('$baseUrl/$endpoint'), body: body),
      fromJson,
    );
  }

  Future<T> patchData<T>(
    String endpoint,
    Map<String, String> body,
    T Function(Map<String, dynamic> json) fromJson,
  ) async {
    return _performApiCall<T>(
      () => http.patch(Uri.parse('$baseUrl/$endpoint'), body: body),
      fromJson,
    );
  }

  Future<T> postData<T>(
    String endpoint,
    Map<String, String> body,
    T Function(Map<String, dynamic> json) fromJson,
  ) async {
    return _performApiCall<T>(
      () => http.post(Uri.parse('$baseUrl/$endpoint'), body: body),
      fromJson,
    );
  }

  // Future<T> postMultipartData<T>(
  //   String endpoint,
  //   Map<String, String> body,
  //   List<Map<String, dynamic>> files,
  //   T Function(Map<String, dynamic> json) fromJson,
  // ) async {
  //   var request =
  //       http.MultipartRequest('POST', Uri.parse('$baseUrl/$endpoint'));
  //   request.fields.addAll(body);

  //   for (var file in files) {
  //     final name = file['name'];
  //     final path = file['path'];
  //     final fileName = file['fileName'];
  //     final mimeType = file['mimeType'];

  //     final fileStream =
  //         http.ByteStream(Stream.castFrom(File(path).openRead()));
  //     final length = await File(path).length();

  //     final multipartFile = http.MultipartFile(
  //       name,
  //       fileStream,
  //       length,
  //       filename: fileName,
  //       contentType: MediaType.parse(mimeType),
  //     );

  //     request.files.add(multipartFile);
  //   }

  //   return _performApiCall<T>(() => request.send(), fromJson);
  // }

  Future<T> _performApiCall<T>(
    Future<http.Response> Function() apiCall,
    T Function(Map<String, dynamic> json) fromJson,
  ) async {
    try {
      final response = await apiCall().timeout(timeout, onTimeout: () {
        throw TimeoutException('Request timed out');
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final parsedData = fromJson(data);

        if (persistDataLocally) {
          await saveDataLocally("locally", data);
        }

        return parsedData;
      } else {
        throw Exception('Failed to fetch data');
      }
    } on TimeoutException catch (_) {
      throw Exception('Request timed out');
    } on http.ClientException catch (_) {
      throw Exception('Network error');
    } catch (e) {
      throw Exception('Network or Internet Error');
    }
  }

  Future<void> saveDataLocally(String key, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, json.encode(data));
  }

  Future<T> getDataLocally<T>(
      String key, T Function(Map<String, dynamic> json) fromJson) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(key);
    if (jsonString != null) {
      final jsonMap = json.decode(jsonString);
      return fromJson(jsonMap);
    }
    return null;
  }

  Future<void> clearDataLocally(String key) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }
}
