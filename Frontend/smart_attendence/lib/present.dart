import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_attendence/classdetail.dart';
import 'package:smart_attendence/createclass.dart';
import 'package:smart_attendence/src/components.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

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
