import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'home.dart';
import 'src/components.dart';

class CreateOrg extends StatefulWidget {
  CreateOrg(this.user);
  User user;
  @override
  _CreateOrgState createState() => _CreateOrgState();
}

class _CreateOrgState extends State<CreateOrg> {
  String title;
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
        title: Text('Create Organization'),
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
                labelText: 'Organization Title',
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
                    Uri baseurl = Uri.http(URL, 'api/createorg/');
                    var response = await http.post(baseurl, headers: {
                      'Authorization': 'Token ${widget.user.token}'
                    }, body: {
                      'title': title
                    });
                    Map parse = json.decode(response.body);
                    if (parse['response'] == 'SUCESS') {
                      await me();
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomePage(newUser)));
                    }
                  },
                  child: Text('Create Org'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
