import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smart_attendence/classdetail.dart';
import 'package:smart_attendence/home.dart';
import 'package:smart_attendence/orgdetail.dart';

import 'src/components.dart';

class CreateClass extends StatefulWidget {
  CreateClass(this.user, this.org);
  User user;
  Organisation org;
  @override
  _CreateClassState createState() => _CreateClassState();
}

class _CreateClassState extends State<CreateClass> {
  String title;
  User newUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Class'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              onChanged: (value) {
                title = value;
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Subject Title',
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.indigoAccent,
                  ),
                  onPressed: () async {
                    final String URL = '192.168.0.194:8000';
                    Uri baseurl = Uri.http(URL, 'api/createclass/');
                    var response = await http.post(baseurl, headers: {
                      'Authorization': 'Token ${widget.user.token}'
                    }, body: {
                      'title': title,
                      'code': widget.org.code
                    });
                    Map parse = json.decode(response.body);
                    if (parse['response'] == 'Sucess') {
                      Classroom cls = Classroom(
                          title: parse['title'],
                          unique_code: parse['unique_code'],
                          time: parse['time']);
                      // await me();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ClassDetail(cls, widget.user, widget.org)));
                    } else if (parse['response'] == 'unauthorized') {
                      showModalBottomSheet<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            height: 200,
                            color: Colors.yellow[200],
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: const Text(
                                        'Sorry you are not authorized to create class in this organization please contact HOD to get teacher code'),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  ElevatedButton(
                                    style: TextButton.styleFrom(
                                        backgroundColor: Colors.indigoAccent),
                                    child: const Text('Close'),
                                    onPressed: () => Navigator.pop(context),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    } else if (parse['response'] == 'Invalid Code') {
                      showModalBottomSheet<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            height: 200,
                            color: Colors.red[400],
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  const Text('Invalid Code'),
                                  SizedBox(
                                    height: 8,
                                  ),
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
                    } else {
                      showModalBottomSheet<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            height: 200,
                            color: Colors.red[500],
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  const Text('Server error'),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  ElevatedButton(
                                    style: TextButton.styleFrom(
                                        backgroundColor: Colors.indigoAccent),
                                    child: const Text('Try again Later'),
                                    onPressed: () => Navigator.pop(context),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                  child: Text('Create Subject'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
