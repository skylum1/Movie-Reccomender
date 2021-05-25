import 'movies.dart';

class MoviesService {
  static List<String> getSuggestions(String query) {
    List<String> matches = <String>[];
    movies.forEach((key, value) {
      if (value.toLowerCase().contains(query.toLowerCase())) matches.add(value);
    });
    return matches;
  }

  static int valid(String query) {
    int match = -1;
    /*for (var name in  movies) {
      if (movies[i].contains(query)) {
        print('match');
        match = true;
        break;
      }
    }*/
    movies.forEach((key, value) {
      if (value == (query)) {
        match = key;
      }
    });
    return match;
  }
}

class UserRating {
  int id;
  String name;
  double rating;
}

class RatingCollection {
  int previousCount = 0;
  List<UserRating> collection = [];
}
