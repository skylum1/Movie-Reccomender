import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:recommender/data/structures.dart';

class AddMovie extends StatefulWidget {
  @override
  _AddMovieState createState() => _AddMovieState();
  get id {
    return _AddMovieState._selectedid;
  }

  set id(int number) {
    _AddMovieState._selectedid = number;
  }

  get rating {
    return _AddMovieState._rating;
  }
}

class _AddMovieState extends State<AddMovie> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _typeAheadController = TextEditingController();
  static int _selectedid;
  static double _rating = 3;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AlertDialog(
          contentPadding: EdgeInsets.all(0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          content: Container(
              height: 325,
              padding: EdgeInsets.all(20),
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    /*
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
                      itemSize: 40, //40
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
                    ),*/
                    Form(
                      key: this._formKey,
                      child: Padding(
                        padding: EdgeInsets.all(22.0),
                        child: Column(
                          children: <Widget>[
                            // Text('What is your favorite city?'),
                            TypeAheadFormField(
                              noItemsFoundBuilder: (context) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    'No such Movie!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Theme.of(context).disabledColor,
                                        fontSize: 18.0),
                                  ),
                                );
                              },
                              textFieldConfiguration: TextFieldConfiguration(
                                decoration: InputDecoration(labelText: 'Movie'),
                                controller: this._typeAheadController,
                              ),
                              suggestionsCallback: (pattern) {
                                return MoviesService.getSuggestions(pattern);
                              },
                              itemBuilder: (context, String suggestion) {
                                return ListTile(
                                  // tileColor: Color(0xff204B6D).withOpacity(0.4),
                                  title: Text(suggestion),
                                );
                              },
                              transitionBuilder:
                                  (context, suggestionsBox, controller) {
                                return suggestionsBox;
                              },
                              onSuggestionSelected: (String suggestion) {
                                this._typeAheadController.text = suggestion;
                              },
                              validator: (value) {
                                int temp = MoviesService.valid(value);
                                if (temp != -1) {
                                  _selectedid = temp;
                                  return null;
                                } else
                                  return 'Please select a movie in list';
                              },
                              // onSaved: (value) => this._selectedCity = value,
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            RatingBar.builder(
                              itemSize: 31, //40
                              initialRating: _rating,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemPadding:
                                  EdgeInsets.symmetric(horizontal: 4.0),
                              itemBuilder: (context, _) => Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (rating) {
                                _rating = rating;
                                // print(rating);
                              },
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            ElevatedButton(
                              child: Text('Submit'),
                              onPressed: () {
                                if (this._formKey.currentState.validate()) {
                                  // print('addi ' + _selectedid.toString());
                                  this._formKey.currentState.save();

                                  Navigator.pop(context);
                                }
                              },
                            )
                          ],
                        ),
                      ),
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
                borderRadius: BorderRadius.circular(30),
              ))),
    );
  }
}
