import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'package:recommender/ui/movie_list.dart';

void main() {
  Paint.enableDithering = true;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark().copyWith(
          bottomSheetTheme: BottomSheetThemeData(
              backgroundColor: Colors.black.withOpacity(0))),
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              title: TabBar(tabs: [
                Tab(text: 'Movie Recommendation'),
                Tab(text: 'Popular Movies'),
              ]),
            ),
            body: TabBarView(children: [
              MyHomePage(),
              MovieList(),
            ])),
      ), //
    );
  }
}
