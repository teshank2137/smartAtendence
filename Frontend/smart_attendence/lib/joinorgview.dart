import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:smart_attendence/src/components.dart';
import 'package:http/http.dart' as http;

import 'home.dart';

class JoinOrg extends StatefulWidget {
  JoinOrg(this.user);
  User user;
  @override
  _JoinOrgState createState() => _JoinOrgState();
}

class _JoinOrgState extends State<JoinOrg> {
  String code;
  User newUser;
  void me() async {
    final String URL = '192.168.0.194:8000';
    Uri baseurl = Uri.http(URL, '/accounts/me/');
    var response = await http
        .get(baseurl, headers: {'Authorization': 'Token ${widget.user.token}'});
    Map parse = json.decode(response.body);

    Uri baseurl2 = Uri.http(URL, '/api/allmyorgs/');
    var response2 = await http.get(baseurl2,
        headers: {'Authorization': 'Token ${widget.user.token}'});
    List parse2 = json.decode(response2.body);
    print(parse2);
    List<Organisation> myOrgs = [];
    for (int i = 0; i < parse2.length; i++) {
      myOrgs.add(Organisation(
          title: parse2[i]['title'], code: parse2[i]['unique_code']));
    }

    newUser = User(
      is_hod: parse['is_hod'],
      is_teacher: parse['is_teacher'],
      token: widget.user.token,
      myOrgs: myOrgs,
    );

    print(widget.user.myOrgs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Join Organization'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              onChanged: (value) {
                code = value;
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Org Code',
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
                    Uri baseurl = Uri.http(URL, 'api/tjoin/${code}');
                    var response = await http.get(baseurl, headers: {
                      'Authorization': 'Token ${widget.user.token}'
                    });
                    Map parse = json.decode(response.body);
                    if (parse['response'] == 'Sucess') {
                      await me();
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Home(newUser)));
                    }
                  },
                  child: Text('Join As Teacher'),
                ),
                SizedBox(
                  width: 12,
                ),
                ElevatedButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.indigoAccent,
                  ),
                  onPressed: () async {
                    final String URL = '192.168.0.194:8000';
                    Uri baseurl = Uri.http(URL, 'api/sjoin/${code}');
                    var response = await http.get(baseurl, headers: {
                      'Authorization': 'Token ${widget.user.token}'
                    });
                    Map parse = json.decode(response.body);
                    if (parse['response'] == 'Sucess') {
                      await me();
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Home(newUser)));
                    }
                    // Navigator.pop(context);
                  },
                  child: Text('Join As Student'),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
