import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;

class Organisation {
  Organisation({this.title, this.code});
  String title;
  String code;
}

class Classroom {
  Classroom({this.title, this.unique_code, this.time, this.date});
  String title;
  String unique_code;
  String time;
  String date = 'Today';
}

class User {
  User({this.is_hod, this.is_teacher, this.token, this.myOrgs});
  bool is_hod = false;
  bool is_teacher = false;
  String token;
  List<Organisation> myOrgs = [];
  void setOrgs(List<Organisation> orgs) {
    this.myOrgs = orgs;
  }
}

class Student {
  Student({this.name, this.email});
  String name;
  String email;
}

List<Organisation> orgs = [
  Organisation(title: 'SE-A'),
  Organisation(title: 'SE-B')
];

Future upload(
    File image, User user, Organisation org, String unique_code) async {
  final String URL = '192.168.0.194:8000';
  Uri baseurl = Uri.http(URL, 'api/markpresent/');

  var stream = new http.ByteStream(DelegatingStream.typed(image.openRead()));
  // get file length
  var length = await image.length();

  // string to uri
  var uri = Uri.parse(baseurl.toString());

  // create multipart request
  var request = new http.MultipartRequest("POST", uri);

  // multipart that takes file
  var multipartFile = new http.MultipartFile('image', stream, length,
      filename: basename(image.path));

  // add file to multipart
  request.files.add(multipartFile);
  request.fields.addAll({"orgcode": org.code, "classcode": unique_code});
  request.headers.addAll({
    "Authorization": "Token ${user.token}",
    "Content-type": "multipart/form-data"
  });

  // send
  var response = await request.send();
  print(response.statusCode);

  return response;
  // listen for response
  response.stream.transform(utf8.decoder).listen((value) {
    print(value);
  });
}
