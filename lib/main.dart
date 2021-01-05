import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Facebook oauth sample',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Facebook 認証サンプル'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, Object> _userData;
  AccessToken _accessToken;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _checkIfIsLogged();
  }

  String prettyPrint(Map json) {
    JsonEncoder encoder = new JsonEncoder.withIndent('  ');
    String pretty = encoder.convert(json);
    return pretty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _checking
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      _userData != null ? prettyPrint(_userData) : 'NO LOGGED',
                    ),
                    SizedBox(height: 20),
                    _accessToken != null
                        ? Text(
                            prettyPrint(_accessToken.toJson()),
                          )
                        : Container(),
                    SizedBox(height: 20),
                    CupertinoButton(
                      color: Colors.blue,
                      child: Text(_userData != null ? 'LOGOUT' : 'LOGIN'),
                      onPressed: _userData != null ? _logOut : _login,
                    ),
                    SizedBox(height: 50),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _checkIfIsLogged() async {
    final AccessToken accessToken = await FacebookAuth.instance.isLogged;
    this.setState(() {
      _checking = false;
    });

    if (accessToken != null) {
      print('is logged:::: ${prettyPrint(accessToken.toJson())}');
      final userData = await FacebookAuth.instance.getUserData();
      _accessToken = accessToken;
      setState(() {
        _userData = userData;
      });
    }
  }

  void _printCredential() {
    print(prettyPrint(_accessToken.toJson()));
  }

  Future<void> _login() async {
    try {
      this.setState(() {
        _checking = true;
      });
      _accessToken = await FacebookAuth.instance.login();
      _printCredential();
      final userData = await FacebookAuth.instance.getUserData();
      _userData = userData;
    } on FacebookAuthException catch (error) {
      print(error.message);
      switch (error.errorCode) {
        case FacebookAuthErrorCode.OPERATION_IN_PROGRESS:
          print('you have a previous login operation in progress');
          break;
        case FacebookAuthErrorCode.CANCELLED:
          print('login cancelled');
          break;
        case FacebookAuthErrorCode.FAILED:
          print('login failed');
          break;
      }
    } catch (e, s) {
      print(e);
      print(s);
    } finally {
      this.setState(() {
        _checking = false;
      });
    }
  }

  Future<void> _logOut() async {
    await FacebookAuth.instance.logOut();
    _accessToken = null;
    _userData = null;
    this.setState(() {});
  }
}
