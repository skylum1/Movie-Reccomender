import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:flutter/material.dart';
import 'package:recommender/data/movies.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'add_movie.dart';
import 'package:recommender/data/structures.dart';
import 'dart:math';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  RatingCollection collection;
  tfl.Interpreter interpreter;
  List<int> recommendations = [];
  Widget bottomSheet(BuildContext context) {
    return Container(
      child: Container(
          height: 335,
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xff2B1E3D), Color(0xff1A1A30)])),
                  child: TextField(
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(left: 10),
                        hintText: 'Movie Name'),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                    padding: EdgeInsets.only(left: 12),
                    child: Text(
                      'Rating',
                      style: TextStyle(fontSize: 20),
                    )),
                SizedBox(
                  height: 20,
                ),
                RatingBar.builder(
                  itemSize: 55, //40
                  initialRating: 3,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    print(rating);
                  },
                ),
              ],
            ),
          ),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xff204B6D),
                    Color(0xff001E36),
                  ]),

              // color: Color(0x2E2E2E).withOpacity(1),
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(30),
                  topLeft: Radius.circular(30)))),
    );
  }

  void output(Map<int, double> mov, int count) async {
    recommendations.clear();
    // Stopwatch stop = new Stopwatch()..start();
    double id = getId(mov, count);
    if (id == -1) return;
    var input0 = [id];
    var input1 = [0.0];
    var output0 = [1].reshape([1, 1]);
    var outputs = {0: output0};
    List<List<double>> inputs;
    Map<int, double> ot = new Map();
    Map<int, String> movi = {};
    movi.addAll(movies);
    mov.forEach((key, value) {
      movi.remove(key);
    });
    movi.forEach((key, value) {
      input1 = [key.toDouble()];
      inputs = [input0, input1];
      if (interpreter != null)
        interpreter.runForMultipleInputs(inputs, outputs);
      if (output0[0][0].isNaN) output0[0][0] = -3.5;
      ot[key] = (output0[0][0]); //+ 3.5);
    });
    // print(movies.length);
    List<int> sot = ot.keys.toList()
      ..sort((k1, k2) => ot[k1].compareTo(ot[k2]));
    sot = sot.reversed.toList();
    for (int i = 0; i < 70; i++) recommendations.add(sot[i]);
    print(recommendations.length);
    // out = ot[sot[0]];
    // print('First el :${ot[sot[0]]} ${ot.length} in ${stop.elapsed}');
  }

  double getId(Map<int, double> mov, int count) {
    // Stopwatch stop = new Stopwatch()..start();
    if (interpreter == null) return -1;
    var input0 = [9.0];
    var input1 = [0.0];
    var output0 = [1].reshape([1, 1]);
    var outputs = {0: output0};
    List<List<double>> inputs;
    double min = double.infinity;
    double temp;
    double selectedId;
    for (int i = 1; i <= count; i++) {
      temp = 0;
      input0 = [Random().nextInt(138493).toDouble() + 1];
      mov.forEach((key, value) {
        input1 = [key.toDouble()];
        inputs = [input0, input1];
        interpreter.runForMultipleInputs(inputs, outputs);
        if (output0[0][0].isNaN) output0[0][0] = -3.5;
        temp += (output0[0][0] + 3.5 - value) * (output0[0][0] + 3.5 - value);
      });
      temp = sqrt(temp / mov.length);
      if (temp < min) {
        min = temp;
        selectedId = input0[0];
      }
    }
    // print(sot);
    // out = ot[sot[0]];
    return (selectedId);
    // print('First el :$selectedId $min in ${stop.elapsed}');
  }

  @override
  void dispose() {
    super.dispose();
    interpreter.close();
  }

  @override
  void initState() {
    super.initState();
    collection = RatingCollection();
    loadModel();
  }

  void loadModel() async {
    interpreter = await tfl.Interpreter.fromAsset('model.tflite');
  }

  Future<void> updateReccom() async {
    print('pass1');
    Map<int, double> userList = {};
    print('${collection.collection.length}+${collection.previousCount}');
    if (collection.collection.length == 1 ||
        collection.collection.length >= 5 + collection.previousCount) {
      collection.previousCount = collection.collection.length;
      collection.collection.forEach((element) {
        userList.addAll({element.id: element.rating});
      });
      print('pass2');
      // print(userList);
      output(userList, 100);
    }
  }

  Widget buildrecomview(BuildContext context) {
    if (recommendations.length == 0)
      return Container(
        padding: EdgeInsets.all(35),
        child: Center(
          child: Text(
            'Add movies to get recommendations!',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );

    return ListView.separated(
        separatorBuilder: (context, index) {
          return SizedBox(
            height: 5,
          );
        },
        physics: BouncingScrollPhysics(),
        itemCount: recommendations.length,
        itemBuilder: (context, index) {
          return Card(
            color: Colors.blue,
            elevation: 2,
            shadowColor: Colors.blueAccent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Wrap(
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: 5, bottom: 5),
                        width: 300,
                        child: Text(movies[recommendations[index]]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget buildlistview(BuildContext context) {
    if (collection.collection.length == 0)
      return Center(
        child: Text('No ratings !'),
      );

    return ListView.separated(
        separatorBuilder: (context, index) {
          return SizedBox(
            height: 5,
          );
        },
        physics: BouncingScrollPhysics(),
        itemCount: collection.collection.length,
        itemBuilder: (context, index) {
          return Card(
            color: Colors.deepPurple,
            elevation: 2,
            shadowColor: Colors.deepPurpleAccent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Wrap(
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: 5, bottom: 5),
                        width: 200,
                        child: Text(collection.collection[index].name),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Text(collection.collection[index].rating.toString()),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.only(left: 10, top: 20),
                // width: 100,
                child: Text(
                  'Your Movies',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Expanded(
            child: Container(
              width: 300,
              // height: 200,
              child: buildlistview(context),
            ),
          ),
          Expanded(
              child: Container(
                  child: Container(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.only(left: 20, top: 20),
                              // width: 100,
                              child: Text(
                                'Recommendations',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        SingleChildScrollView(
                          child: Container(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            height: 150,
                            child: buildrecomview(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(30),
                          topLeft: Radius.circular(30))))),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAnimatedDialog<void>(
              animationType: DialogTransitionType.fade,
              barrierDismissible: true,
              duration: Duration(milliseconds: 300),
              context: context,
              builder: (_) => AddMovie()).whenComplete(() {
            if (AddMovie().id != null) {
              UserRating temp = UserRating();
              temp.id = AddMovie().id;
              AddMovie().id = null;
              temp.name = movies[temp.id];
              temp.rating = AddMovie().rating;
              setState(() {
                collection.collection.add(temp);
              });
              updateReccom();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Movie added'),
                ),
              );
            }
          });
          // setState(() {
          //   updateReccom();
          // });
        },
        tooltip: 'Add',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
