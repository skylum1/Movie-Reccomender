import 'package:recommender/models/item_model.dart';
import 'package:rxdart/rxdart.dart';
import 'package:recommender/resources/repository.dart';
import 'dart:async';

class MoviesBloc {
  final _repository = Repository();
  final _moviesFetcher = PublishSubject<ItemModel>();
  Stream<ItemModel> get allMovies => _moviesFetcher.stream;

  fetchAllMovies() async {
    ItemModel itemModel = await _repository.fetchMoviesList();
    _moviesFetcher.sink.add(itemModel);
  }

  dispose() {
    _moviesFetcher?.close();
  }
}
