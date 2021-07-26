import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_attendence/home.dart';
import 'package:http/http.dart' as http;
import 'package:smart_attendence/src/components.dart';
import 'dart:convert';

import 'src/bloc.dart';

class Signup extends StatefulWidget {
  User user;
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  String _token = "";
  String email, username, password1, password2;
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  email = value;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                // filled: true,
                labelText: 'Email',
              ),
            ),
            SizedBox(
              height: 12,
            ),
            TextField(
              onChanged: (value) {
                setState(() {
                  username = value;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                // filled: true,
                labelText: 'Username',
              ),
            ),
            SizedBox(
              height: 12,
            ),
            TextField(
              onChanged: (value) {
                setState(() {
                  password1 = value;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                // filled: true,
                labelText: 'Password',
              ),
            ),
            SizedBox(
              height: 12,
            ),
            TextField(
              onChanged: (value) {
                setState(() {
                  password2 = value;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                // filled: true,
                labelText: 'Confirm Password',
              ),
            ),
            SizedBox(
              height: 12,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      Navigator.pop(context);
                    });
                  },
                  child: Text("Login Instead"),
                ),
                ElevatedButton(
                  onPressed: password1 == password2
                      ? () async {
                          try {
                            print('im in try');
                            final String URL = '192.168.0.194:8000';
                            Uri baseurl = Uri.http(URL, '/accounts/signup/');
                            var response = await http.post(baseurl, body: {
                              'username': username,
                              'password': password1,
                              "email": email
                            });
                            print(response.body);
                            if (response.statusCode == 200) {
                              Map parse = json.decode(response.body);
                              _token = parse['token'];
                              print(_token);
                              await me();
                              Navigator.pop(context);
                              Navigator.pop(context);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          HomePage(widget.user)));
                            } else {
                              showModalBottomSheet<void>(
                                context: context,
                                builder: (BuildContext context) {
                                  return Container(
                                    height: 200,
                                    color: Colors.white,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          const Text(
                                              'Username or Password Already exist'),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          ElevatedButton(
                                            child: const Text('Retry'),
                                            style: TextButton.styleFrom(
                                                backgroundColor:
                                                    Colors.indigoAccent),
                                            onPressed: () =>
                                                Navigator.pop(context),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                          } catch (e) {
                            showModalBottomSheet<void>(
                              context: context,
                              builder: (BuildContext context) {
                                return Container(
                                  height: 200,
                                  color: Colors.white,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        const Text(
                                            'Wrong Username or Password'),
                                        ElevatedButton(
                                          style: TextButton.styleFrom(
                                              backgroundColor:
                                                  Colors.indigoAccent),
                                          child: const Text('Retry'),
                                          onPressed: () =>
                                              Navigator.pop(context),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                            showModalBottomSheet<void>(
                              context: context,
                              builder: (BuildContext context) {
                                return Container(
                                  height: 200,
                                  color: Colors.white,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        const Text('Server Error'),
                                        ElevatedButton(
                                          style: TextButton.styleFrom(
                                              backgroundColor:
                                                  Colors.indigoAccent),
                                          child: const Text('Retry'),
                                          onPressed: () =>
                                              Navigator.pop(context),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                        }
                      : () {
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
                                      const Text("Password didn't match"),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ElevatedButton(
                                            style: TextButton.styleFrom(
                                                backgroundColor:
                                                    Colors.indigoAccent),
                                            child: const Text('Retry'),
                                            onPressed: () =>
                                                Navigator.pop(context),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                  child: Text('Sign Up'),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
