# simple_api_call

Simple API Call


```ruby

dependencies:
  flutter:
    sdk: flutter
  simple_api_call: ^0.0.1

```
Calling it
```ruby

import 'package:flutter/material.dart';
import 'package:simple_api_call/simple_api_call.dart';

class MyApp extends StatelessWidget {
  final api = SimpleApiCall(baseUrl: 'your_base_url_here');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('API Call Example')),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              try {
                final data = await api.fetchData('your_endpoint_here');
                // Use the fetched data
                print('Fetched Data: $data');
                // Optionally save the data locally
                await api.saveDataLocally('data_key', data);
              } catch (e) {
                // Handle errors
                print('Error: $e');
              }
            },
            child: Text('Fetch Data'),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}


```
