import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:smart_attendence/createorg.dart';
import 'package:smart_attendence/faceregister.dart';
import 'package:smart_attendence/joinorgview.dart';
import 'package:smart_attendence/login.dart';
import 'package:smart_attendence/orgdetail.dart';
import 'package:smart_attendence/src/components.dart';
import 'package:http/http.dart' as http;

import 'src/bloc.dart';

class HomePage extends StatelessWidget {
  HomePage(this.user);
  User user;
  @override
  Widget build(BuildContext context) {
    return Home(user);
  }
}

class Home extends StatefulWidget {
  Home(this.user);
  User user;
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Joined Organizations'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => JoinOrg(widget.user)),
                );
              },
              iconSize: 28,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              icon: Icon(Icons.logout),
              iconSize: 28,
            ),
          )
        ],
      ),
      body: Container(
        child: ListView.builder(
            itemCount: widget.user.myOrgs.length,
            itemBuilder: (BuildContext context, int index) {
              return _buildOrganization(widget.user.myOrgs[index]);
            }),
      ),
      floatingActionButton: widget.user.is_hod
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CreateOrg(widget.user)),
                );
              },
              child: Icon(Icons.add),
            )
          : Container(),
      bottomNavigationBar: BottomAppBar(
        child: TextButton(
          style: TextButton.styleFrom(
            primary: Colors.indigoAccent,
            backgroundColor: Colors.black12,
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => RegisterFace(widget.user)));
          },
          child: SizedBox(
            // height: 35,
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Text(
                'Setup Face Registration',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrganization(Organisation org) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListTile(
            tileColor: Colors.white,
            title: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              child: Text(org.title),
            ),
            trailing: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              child: Text('Code: ${org.code}'),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => OrgDeatil(widget.user, org)),
              );
            },
          ),
        ),
        // Divider()
      ],
    );
  }
}
