import 'package:flutter/material.dart';
import 'package:smart_attendence/signup.dart';
import 'package:smart_attendence/src/components.dart';
import 'home.dart';
import 'main.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'src/bloc.dart';

class LoginPage extends StatefulWidget {
  User user;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _token = "";
  String _username;
  String _password;
  bool enable = false;
  void me() async {
    final String URL = '192.168.0.194:8000';
    Uri baseurl = Uri.http(URL, '/accounts/me/');
    var response =
        await http.get(baseurl, headers: {'Authorization': 'Token ${_token}'});
    Map parse = json.decode(response.body);

    Uri baseurl2 = Uri.http(URL, '/api/allmyorgs/');
    var response2 =
        await http.get(baseurl2, headers: {'Authorization': 'Token ${_token}'});
    List parse2 = json.decode(response2.body);
    print(parse2);
    List<Organisation> myOrgs = [];
    for (int i = 0; i < parse2.length; i++) {
      myOrgs.add(Organisation(
          title: parse2[i]['title'], code: parse2[i]['unique_code']));
    }

    widget.user = User(
      is_hod: parse['is_hod'],
      is_teacher: parse['is_teacher'],
      token: _token,
      myOrgs: myOrgs,
    );

    print(widget.user.myOrgs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _username = value;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                // filled: true,
                labelText: 'Username',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _password = value;
                  if (value.length >= 0) {
                    enable = true;
                  }
                });
              },
              decoration: InputDecoration(
                // fillColor: enable ? Colors.blue : Colors.red,
                // focusColor: enable ? Colors.blue : Colors.red,
                border: OutlineInputBorder(),
                // filled: true,
                labelText: 'Password',
              ),
              obscureText: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // TextButton(
                //   onPressed: () {},
                //   child: Text('Cancel'),
                // ),
                ElevatedButton(
                  onPressed: () async {
                    if (enable) {
                      print(_username);
                      print(_password);
                      // Future res =
                      //     await widget.bloc.login(_username, _password);
                      try {
                        print('im in try');
                        final String URL = '192.168.0.194:8000';
                        Uri baseurl = Uri.http(URL, '/accounts/login');
                        var response = await http.post(baseurl, body: {
                          'username': _username,
                          'password': _password
                        });
                        print(response.body);
                        if (response.statusCode == 200) {
                          Map parse = json.decode(response.body);
                          _token = parse['token'];
                          await me();
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomePage(widget.user)));
                        } else {
                          print('im in else');
                          showModalBottomSheet<void>(
                            context: context,
                            builder: (BuildContext context) {
                              return Container(
                                height: 200,
                                color: Colors.white,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      const Text('Wrong Username or Password'),
                                      ElevatedButton(
                                        style: TextButton.styleFrom(
                                            backgroundColor:
                                                Colors.indigoAccent),
                                        child: const Text('Retry'),
                                        onPressed: () => Navigator.pop(context),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      } catch (e) {
                        print('im in Catch');
                        showModalBottomSheet<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              height: 200,
                              color: Colors.white,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    const Text('Server Error'),
                                    ElevatedButton(
                                      style: TextButton.styleFrom(
                                          backgroundColor: Colors.indigoAccent),
                                      child: const Text('Retry'),
                                      onPressed: () => Navigator.pop(context),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                    }
                  },
                  child: Text('Login'),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Signup(),
                ),
              );
            },
            child: Text('Create Account'),
          )
        ],
      ),
    );
  }
}
