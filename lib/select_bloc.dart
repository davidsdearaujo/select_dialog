import 'package:rxdart/rxdart.dart';

class SelectOneBloc<T> {
  final Future<List<T>> Function(String text) onFind;
  final _filter$ = BehaviorSubject.seeded("");
  BehaviorSubject<List<T>> _list$;

  Observable<List<T>> filteredListOut;
  Observable<List<T>> _filteredListOnlineOut;
  Observable<List<T>> _filteredListOfflineOut;

  SelectOneBloc(List<T> items, this.onFind) {
    _list$ = BehaviorSubject.seeded(items);

    _filteredListOfflineOut =
        Observable.combineLatest2(_list$, _filter$, filter);

    _filteredListOnlineOut = _filter$
        .where((_) => onFind != null)
        .distinct()
        .debounceTime(Duration(milliseconds: 500))
        .switchMap((val) => Observable.fromFuture(onFind(val)).startWith(null));

    filteredListOut =
        Observable.merge([_filteredListOfflineOut, _filteredListOnlineOut]);
  }

  void onTextChanged(String filter) {
    _filter$.add(filter ?? "".toLowerCase());
  }

  List<T> filter(List<T> list, String filter) {
    return list
        ?.where(
          (item) =>
              _filter$.value == null ||
              item.toString().toLowerCase().contains(_filter$.value) ||
              _filter$.value.isEmpty,
        )
        ?.toList();
  }

  // bool isFiltered(T item, String filter)

  void dispose() {
    _filter$.close();
    _list$.close();
  }
}
