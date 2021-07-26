import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:smart_attendence/src/components.dart';
import 'package:dio/dio.dart';
import 'package:async/async.dart';
import 'package:path/path.dart';

class RegisterFace extends StatefulWidget {
  RegisterFace(this.user);
  User user;
  @override
  _RegisterFaceState createState() => _RegisterFaceState();
}

class _RegisterFaceState extends State<RegisterFace> {
  bool circular = false;
  File image1;
  File image2;
  String result;
  // Dio dio = Dio();
  final picker = ImagePicker();
  openCamera(int i) async {
    var picture = await picker.getImage(source: ImageSource.camera);
    setState(() {
      if (i == 1) {
        setState(() {
          image1 = File(picture.path);
        });
      } else {
        setState(() {
          image2 = File(picture.path);
        });
      }
    });
  }

  Future upload() async {
    setState(() {
      circular = true;
    });
    final String URL = '192.168.0.194:8000';
    Uri baseurl = Uri.http(URL, 'accounts/facereg/');

    var stream = new http.ByteStream(DelegatingStream.typed(image1.openRead()));
    // get file length
    var length = await image1.length();

    var stream2 =
        new http.ByteStream(DelegatingStream.typed(image2.openRead()));
    // get file length
    var length2 = await image2.length();
    // string to uri
    var uri = Uri.parse(baseurl.toString());

    // create multipart request
    var request = new http.MultipartRequest("POST", uri);

    // multipart that takes file
    var multipartFile = new http.MultipartFile('image1', stream, length,
        filename: basename(image1.path));
    var multipartFile2 = new http.MultipartFile('image2', stream2, length2,
        filename: basename(image2.path));

    // add file to multipart
    request.files.add(multipartFile);
    request.files.add(multipartFile2);
    request.headers.addAll({
      "Authorization": "Token ${widget.user.token}",
      "Content-type": "multipart/form-data"
    });

    // send
    var response = await request.send();
    print(response.statusCode);

    // listen for response
    response.stream.transform(utf8.decoder).listen((value) {
      print(value);
      Map parse = json.decode(value);
      setState(() {
        result = parse['response'];
        circular = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    print('result');
    return Scaffold(
      appBar: AppBar(
        title: Text('Please Setup Face Registration'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: circular
              ? CircularProgressIndicator()
              : Text(
                  """NOTE: 
            
Please Make sure While Capturing the photo your face clearly Visible with proper lighting""",
                  style: TextStyle(fontSize: 20),
                ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.indigoAccent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.indigoAccent,
                    primary: Colors.white,
                  ),
                  onPressed: () {
                    openCamera(1);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text('Capture First Image'),
                  )),
            ),
            Expanded(
              child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.indigoAccent,
                    primary: Colors.white,
                  ),
                  onPressed: () {
                    openCamera(2);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text('Capture Second Image'),
                  )),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await upload();
          // Map parse = json.decode(request.body);
          if (true) {
            showModalBottomSheet<void>(
              context: context,
              builder: (BuildContext context) {
                return Container(
                  height: 200,
                  color: Colors.green[400],
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Text('Registered Successfully'),
                        SizedBox(
                          height: 8,
                        ),
                        ElevatedButton(
                          style: TextButton.styleFrom(
                              backgroundColor: Colors.white),
                          child: const Text(
                            'Go Back',
                            style: TextStyle(color: Colors.black),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
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
                  color: Colors.red[400],
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Text('Registration Failed'),
                        SizedBox(
                          height: 8,
                        ),
                        ElevatedButton(
                          style: TextButton.styleFrom(
                              backgroundColor: Colors.indigoAccent),
                          child: const Text('Try again'),
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
          }
        },
        child: Icon(Icons.upload_sharp),
      ),
    );
  }
}
