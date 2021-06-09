import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'face_detection_camera.dart';

import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mask detector',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _loading = false;
  List? _outputs;
  File? _image;
  final picker = ImagePicker();
  int count = 0;
  void initState() {
    super.initState();
    _loading = true;
    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
  }

  pickImage() async {
    count++;
    print(count);
    var image = await picker.getImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      _loading = true;
      //Declare File _image in the class which is used to display the image on the screen.
      _image = File(image.path);
    });
    classifyImage(_image!);
  }

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 1,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _loading = false;
      //Declare List _outputs in the class which will be used to show the classified classs name and confidence
      _outputs = output;

      if (count.isOdd) {
        print('hey');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Color.fromRGBO(21, 32, 43, 1),
        body: _loading
            ? Container(
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _image == null
                          ? Container()
                          : Image.file(_image!,
                              fit: BoxFit.contain,
                              height: MediaQuery.of(context).size.height * 0.6),
                      SizedBox(
                        height: 10,
                      ),
                      _outputs != null
                          ? Column(
                              children: <Widget>[
                                Text(
                                  _outputs![0]["label"] == '0 with_mask'
                                      ? "Mask detected"
                                      : "Mask not detected",
                                  style: TextStyle(
                                    color:
                                        _outputs![0]["label"] == '0 with_mask'
                                            ? Colors.green
                                            : Colors.red,
                                    fontSize: 25.0,
                                  ),
                                ),
                                Text(
                                  "${(_outputs![0]["confidence"] * 100).toStringAsFixed(0)}%",
                                  style: TextStyle(
                                      color: Colors.purpleAccent, fontSize: 20),
                                )
                              ],
                            )
                          : Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      "Stay Home & Stay Safe",
                                      style: TextStyle(
                                          fontSize: 50,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Color.fromRGBO(247, 184, 96, 1)),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Container(
                                          height: height * 0.5,
                                          child: Image.asset(
                                            'assets/mask.png',
                                          )),
                                      SizedBox(height: 10),
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Text(
                                          "The input photo must have a close face",
                                          style: TextStyle(
                                              color: Color.fromRGBO(
                                                  247, 184, 96, 1),
                                              fontSize: 20),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      SizedBox(
                                        height: height * 0.05,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          FloatingActionButton(
                                            backgroundColor:
                                                Color.fromRGBO(247, 184, 96, 1),
                                            heroTag: null,
                                            onPressed: () => pickImage(),
                                            child: Icon(Icons.image),
                                          ),
                                          SizedBox(width: 10),
                                          FloatingActionButton(
                                            backgroundColor:
                                                Color.fromRGBO(247, 184, 96, 1),
                                            heroTag: null,
                                            onPressed: () {
                                              Navigator.push(context,
                                                  MaterialPageRoute(builder:
                                                      (BuildContext context) {
                                                return FaceDetectionFromLiveCamera();
                                              }));
                                            },
                                            child: Icon(Icons.camera),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            )
                    ],
                  ),
                ),
              ));
  }
}
