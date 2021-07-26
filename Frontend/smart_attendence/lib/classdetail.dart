import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:smart_attendence/src/components.dart';
import 'package:http/http.dart' as http;

class ClassDetail extends StatefulWidget {
  ClassDetail(this.cls, this.user, this.org);
  Classroom cls;
  Organisation org;
  List<Student> stds = [];
  User user;
  @override
  _ClassDetailState createState() => _ClassDetailState();
}

class _ClassDetailState extends State<ClassDetail> {
  List<Widget> stu = [];
  void getStudents() async {
    final String URL = '192.168.0.194:8000';
    Uri baseurl = Uri.http(URL, 'api/classdetail/');
    var response = await http.post(baseurl, headers: {
      'Authorization': 'Token ${widget.user.token}'
    }, body: {
      'orgcode': widget.org.code,
      'classcode': widget.cls.unique_code
    });
    List parse = json.decode(response.body);
    print(parse);
    for (int i = 0; i < parse.length; i++) {
      Student std =
          Student(name: parse[i]['username'], email: parse[i]['email']);
      setState(() {
        widget.stds.add(std);
        stu.add(_buildStudent(std));
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cls.title + ' Details'),
      ),
      body: ListView(
        children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Code: ${widget.cls.unique_code}',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Column(
                      children: [
                        Text('Date: ${widget.cls.date}'),
                        SizedBox(
                          height: 4,
                        ),
                        Text('Total Present : ${stu.length}')
                      ],
                    )
                  ],
                ),
              )
            ] +
            stu,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            getStudents();
          });
        },
        child: Icon(Icons.restore_rounded),
      ),
    );
  }

  Widget _buildStudent(Student std) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4),
      child: ListTile(
        tileColor: Colors.green[50],
        title: Text(std.name),
        subtitle: Text(std.email),
      ),
    );
  }
}
