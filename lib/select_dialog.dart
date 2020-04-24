library select_dialog;

import 'package:flutter/material.dart';
import 'select_bloc.dart';

typedef Widget SelectOneItemBuilderType<T>(
    BuildContext context, T item, bool isSelected);

typedef Widget ErrorBuilderType<T>(BuildContext context, dynamic exception);

class SelectDialog<T> extends StatefulWidget {
  final T selectedValue;
  final List<T> itemsList;

  ///![image](https://user-images.githubusercontent.com/16373553/80187339-db365f00-85e5-11ea-81ad-df17d7e7034e.png)
  final bool showSearchBox;
  final void Function(T) onChange;
  final Future<List<T>> Function(String text) onFind;
  final SelectOneItemBuilderType<T> itemBuilder;
  final WidgetBuilder emptyBuilder;
  final WidgetBuilder loadingBuilder;
  final ErrorBuilderType errorBuilder;
  final bool autofocus;

  ///![image](https://user-images.githubusercontent.com/16373553/80187339-db365f00-85e5-11ea-81ad-df17d7e7034e.png)
  final InputDecoration searchBoxDecoration;

  ///![image](https://user-images.githubusercontent.com/16373553/80187103-72e77d80-85e5-11ea-9349-e4dc8ec323bc.png)
  final TextStyle titleStyle;

  ///|**Max width**: 90% of screen width|**Max height**: 70% of screen height|
  ///|---|---|
  ///|![image](https://user-images.githubusercontent.com/16373553/80189438-0a020480-85e9-11ea-8e63-3fabfa42c1c7.png)|![image](https://user-images.githubusercontent.com/16373553/80190562-e2ac3700-85ea-11ea-82ef-3383ae32ab02.png)|
  final BoxConstraints constraints;

  const SelectDialog({
    Key key,
    this.itemsList,
    this.showSearchBox,
    this.onChange,
    this.selectedValue,
    this.onFind,
    this.itemBuilder,
    this.searchBoxDecoration,
    this.titleStyle,
    this.emptyBuilder,
    this.errorBuilder,
    this.loadingBuilder,
    this.constraints,
    this.autofocus = false,
  }) : super(key: key);

  static Future<T> showModal<T>(
    BuildContext context, {
    List<T> items,
    String label,
    T selectedValue,
    bool showSearchBox,
    Future<List<T>> Function(String text) onFind,
    SelectOneItemBuilderType<T> itemBuilder,
    void Function(T) onChange,
    InputDecoration searchBoxDecoration,
    Color backgroundColor,
    TextStyle titleStyle,
    WidgetBuilder emptyBuilder,
    WidgetBuilder loadingBuilder,
    ErrorBuilderType errorBuilder,
    BoxConstraints constraints,
    bool autofocus = false,
  }) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          title: Text(
            label ?? "",
            style: titleStyle,
          ),
          content: SelectDialog<T>(
            selectedValue: selectedValue,
            itemsList: items,
            onChange: onChange,
            onFind: onFind,
            showSearchBox: showSearchBox,
            itemBuilder: itemBuilder,
            searchBoxDecoration: searchBoxDecoration,
            titleStyle: titleStyle,
            emptyBuilder: emptyBuilder,
            loadingBuilder: loadingBuilder,
            errorBuilder: errorBuilder,
            constraints: constraints,
            autofocus: autofocus,
          ),
        );
      },
    );
  }

  @override
  _SelectDialogState<T> createState() =>
      _SelectDialogState<T>(itemsList, onChange, onFind);
}

class _SelectDialogState<T> extends State<SelectDialog<T>> {
  SelectOneBloc<T> bloc;
  void Function(T) onChange;

  _SelectDialogState(
    List<T> itemsList,
    this.onChange,
    Future<List<T>> Function(String text) onFind,
  ) {
    bloc = SelectOneBloc(itemsList, onFind);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.autofocus ?? false) {
      FocusScope.of(context).requestFocus(bloc.focusNode);
    }
  }

  @override
  void dispose() {
    super.dispose();
    bloc.dispose();
  }

  bool get isMobile =>
      MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;

  BoxConstraints get webDefaultConstraints =>
      BoxConstraints(maxWidth: 250, maxHeight: 500);

  BoxConstraints get mobileDefaultConstraints => BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.9,
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.7,
      constraints: widget.constraints ?? isMobile
          ? webDefaultConstraints
          : mobileDefaultConstraints,
      child: Column(
        children: <Widget>[
          if (widget.showSearchBox ?? true)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                focusNode: bloc.focusNode,
                onChanged: bloc.onTextChanged,
                decoration: widget.searchBoxDecoration ??
                    InputDecoration(
                      hintText: "Find",
                      contentPadding: const EdgeInsets.all(2.0),
                    ),
              ),
            ),
          Expanded(
            child: Scrollbar(
              child: StreamBuilder<List<T>>(
                stream: bloc.filteredListOut,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    if (widget.errorBuilder != null) {
                      return widget.errorBuilder(context, snapshot.error);
                    } else {
                      return Center(child: Text("Oops. \n${snapshot.error}"));
                    }
                  } else if (!snapshot.hasData) {
                    if (widget.loadingBuilder != null) {
                      return widget.loadingBuilder(context);
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  } else if (snapshot.data.isEmpty) {
                    if (widget.emptyBuilder != null) {
                      return widget.emptyBuilder(context);
                    } else {
                      return Center(child: Text("No data found"));
                    }
                  }
                  return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      var item = snapshot.data[index];
                      if (widget.itemBuilder != null)
                        return InkWell(
                          child: widget.itemBuilder(
                            context,
                            item,
                            item == widget.selectedValue,
                          ),
                          onTap: () {
                            onChange(item);
                            Navigator.pop(context);
                          },
                        );
                      else
                        return ListTile(
                          title: Text(item.toString()),
                          selected: item == widget.selectedValue,
                          onTap: () {
                            onChange(item);
                            Navigator.pop(context);
                          },
                        );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
