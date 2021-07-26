import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_attendence/classdetail.dart';
import 'package:smart_attendence/createclass.dart';
import 'package:smart_attendence/src/components.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'src/bloc.dart';

class OrgDeatil extends StatefulWidget {
  OrgDeatil(this.user, this.org);
  User user;
  bool showcode = false;
  String Tcode = '';
  List<Classroom> classes = [];
  final Organisation org;
  @override
  _OrgDeatilState createState() => _OrgDeatilState();
}

class _OrgDeatilState extends State<OrgDeatil> {
  void ishod() async {
    final String URL = '192.168.0.194:8000';
    Uri baseurl = Uri.http(URL, 'api/ishod/${widget.org.code}/');
    var response = await http.get(
      baseurl,
      headers: {'Authorization': 'Token ${widget.user.token}'},
    );
    Map parse = json.decode(response.body);
    if (parse['response'] == true) {
      setState(() {
        widget.showcode = true;
        widget.Tcode = parse['teacher_code'];
      });
    }
  }

  void getClasses() async {
    final String URL = '192.168.0.194:8000';
    Uri baseurl = Uri.http(URL, 'api/listclass/${widget.org.code}/');
    var response = await http.get(
      baseurl,
      headers: {'Authorization': 'Token ${widget.user.token}'},
    );
    List parse = json.decode(response.body);
    for (int i = 0; i < parse.length; i++) {
      setState(() {
        widget.classes.add(Classroom(
          title: parse[i]['title'],
          unique_code: parse[i]['unique_code'],
          date: parse[i]['date'],
          time: parse[i]['startTime'],
        ));
      });
    }
    print(parse.length);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getClasses();
    ishod();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.org.title + ' Subjects'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Present(
                              user: widget.user,
                              org: widget.org,
                            )));
              },
              icon: Icon(Icons.add),
              iconSize: 28,
            ),
          ),
          widget.showcode
              ? IconButton(
                  icon: Icon(Icons.security),
                  iconSize: 28,
                  onPressed: () {
                    showModalBottomSheet<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return Container(
                          height: 200,
                          color: Colors.red[50],
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  'Teacher Code : ${widget.Tcode}',
                                  style: TextStyle(fontSize: 22),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                ElevatedButton(
                                  style: TextButton.styleFrom(
                                      backgroundColor: Colors.indigoAccent),
                                  child: const Text('close'),
                                  onPressed: () => Navigator.pop(context),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                )
              : Container(),
        ],
      ),
      floatingActionButton: widget.user.is_hod || widget.user.is_teacher
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            CreateClass(widget.user, widget.org)));
              },
              child: Icon(Icons.add),
              tooltip: 'Mark Present',
            )
          : Container(),
      body: ListView.builder(
          itemCount: widget.classes.length,
          itemBuilder: (BuildContext context, int index) {
            return _buildClass(widget.classes[index]);
          }),
    );
  }

  Widget _buildClass(Classroom myCls) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ListTile(
        tileColor: Colors.white,
        title: Text(myCls.title),
        trailing: widget.user.is_teacher || widget.user.is_hod
            ? Text(myCls.unique_code)
            : Text(''),
        subtitle: Text('Date: ${myCls.date}'),
        onTap: widget.user.is_teacher || widget.user.is_hod
            ? () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ClassDetail(myCls, widget.user, widget.org)));
              }
            : () {},
      ),
    );
  }
}

class Present extends StatefulWidget {
  Present({this.user, this.org});
  User user;
  Organisation org;
  @override
  _PresentState createState() => _PresentState();
}

class _PresentState extends State<Present> {
  File image;
  bool circular = false;
  final picker = ImagePicker();
  String code;
  openCamera() async {
    var picture = await picker.getImage(source: ImageSource.camera);
    setState(() {
      image = File(picture.path);
    });
  }

  mark() async {
    setState(() {
      circular = true;
    });
    var response = await upload(image, widget.user, widget.org, code);
    if (response.statuscode == 200) {
      setState(() {
        circular = false;
      });
      response.stream.transform(utf8.decoder).listen((value) {
        print(value);
        setState(() {
          circular = false;
          Map parse = json.decode(value);

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
                      Text(parse['response'].toString()),
                      SizedBox(
                        height: 8,
                      ),
                      ElevatedButton(
                        style: TextButton.styleFrom(
                            backgroundColor: Colors.indigoAccent),
                        child: const Text('Close'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ),
                ),
              );
            },
          );
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Face Authentication'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(36),
        child: circular
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        code = value;
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Class Code',
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.indigoAccent,
                        ),
                        child: Text('Authorize'),
                        onPressed: openCamera,
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      ElevatedButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.indigoAccent,
                        ),
                        onPressed: () {
                          mark();
                        },
                        child: Text('Confirm'),
                      )
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
