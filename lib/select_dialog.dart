library select_dialog;

import 'package:flutter/material.dart';

import 'multiple_items_bloc.dart';
import 'select_bloc.dart';

typedef Widget SelectOneItemBuilderType<T>(
    BuildContext context, T item, bool isSelected);

typedef Widget ErrorBuilderType<T>(BuildContext context, dynamic exception);
typedef Widget ButtonBuilderType(BuildContext context, VoidCallback onPressed);

class SelectDialog<T> extends StatefulWidget {
  final T selectedValue;
  final List<T> multipleSelectedValues;
  final List<T> itemsList;

  ///![image](https://user-images.githubusercontent.com/16373553/80187339-db365f00-85e5-11ea-81ad-df17d7e7034e.png)
  final bool showSearchBox;
  final void Function(T) onChange;
  final void Function(List<T>) onMultipleItemsChange;
  final Future<List<T>> Function(String text) onFind;
  final SelectOneItemBuilderType<T> itemBuilder;
  final WidgetBuilder emptyBuilder;
  final WidgetBuilder loadingBuilder;
  ///![image](https://user-images.githubusercontent.com/16373553/94357272-d599e500-006d-11eb-9bcb-5f067943011e.png)
  final ButtonBuilderType okButtonBuilder;
  final ErrorBuilderType errorBuilder;
  final bool autofocus;
  final bool alwaysShowScrollBar;
  final int searchBoxMaxLines;
  final int searchBoxMinLines;

  ///![image](https://user-images.githubusercontent.com/16373553/80187339-db365f00-85e5-11ea-81ad-df17d7e7034e.png)
  final InputDecoration searchBoxDecoration;

  final String searchHint;

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
    this.onMultipleItemsChange,
    this.selectedValue,
    this.multipleSelectedValues,
    this.onFind,
    this.itemBuilder,
    this.searchBoxDecoration,
    String searchHint,
    this.titleStyle,
    this.emptyBuilder,
    this.okButtonBuilder,
    this.errorBuilder,
    this.loadingBuilder,
    this.constraints,
    this.autofocus = false,
    bool alwaysShowScrollBar,
    this.searchBoxMaxLines = 1,
    this.searchBoxMinLines = 1,
  })  : searchHint = searchHint ?? "Find",
        alwaysShowScrollBar = alwaysShowScrollBar ?? false,
        super(key: key);

  static Future<T> showModal<T>(
    BuildContext context, {
    List<T> items,
    String label,
    T selectedValue,
    List<T> multipleSelectedValues,
    bool showSearchBox,
    Future<List<T>> Function(String text) onFind,
    SelectOneItemBuilderType<T> itemBuilder,
    void Function(T) onChange,
    void Function(List<T>) onMultipleItemsChange,
    InputDecoration searchBoxDecoration,
    String searchHint,
    Color backgroundColor,
    TextStyle titleStyle,
    WidgetBuilder emptyBuilder,
    ButtonBuilderType okButtonBuilder,
    WidgetBuilder loadingBuilder,
    ErrorBuilderType errorBuilder,
    BoxConstraints constraints,
    bool autofocus = false,
    bool alwaysShowScrollBar = false,
    int searchBoxMaxLines = 1,
    int searchBoxMinLines = 1,
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
            multipleSelectedValues: multipleSelectedValues,
            itemsList: items,
            onChange: onChange,
            onMultipleItemsChange: onMultipleItemsChange,
            onFind: onFind,
            showSearchBox: showSearchBox,
            itemBuilder: itemBuilder,
            searchBoxDecoration: searchBoxDecoration,
            searchHint: searchHint,
            titleStyle: titleStyle,
            emptyBuilder: emptyBuilder,
            okButtonBuilder: okButtonBuilder,
            loadingBuilder: loadingBuilder,
            errorBuilder: errorBuilder,
            constraints: constraints,
            autofocus: autofocus,
            alwaysShowScrollBar: alwaysShowScrollBar,
            searchBoxMaxLines: searchBoxMaxLines,
            searchBoxMinLines: searchBoxMinLines,
          ),
        );
      },
    );
  }

  @override
  _SelectDialogState<T> createState() => _SelectDialogState<T>(
        itemsList,
        onChange,
        onMultipleItemsChange,
        multipleSelectedValues?.toList(),
        onFind,
      );
}

class _SelectDialogState<T> extends State<SelectDialog<T>> {
  SelectOneBloc<T> bloc;
  MultipleItemsBloc<T> multipleItemsBloc;
  void Function(T) onChange;

  _SelectDialogState(
    List<T> itemsList,
    this.onChange,
    void Function(List<T>) onMultipleItemsChange,
    List<T> multipleSelectedValues,
    Future<List<T>> Function(String text) onFind,
  ) {
    bloc = SelectOneBloc(itemsList, onFind);
    multipleItemsBloc = MultipleItemsBloc(
      multipleSelectedValues,
      onMultipleItemsChange,
    );
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

  bool get isWeb =>
      MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;

  bool get isMultipleItems => widget.onMultipleItemsChange != null;

  BoxConstraints get webDefaultConstraints =>
      BoxConstraints(maxWidth: 250, maxHeight: 500);

  BoxConstraints get mobileDefaultConstraints => BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.9,
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      );

  SelectOneItemBuilderType<T> get itemBuilder =>
      widget.itemBuilder ??
      (context, item, isSelected) => ListTile(
            title: Text(item.toString()),
            selected: isSelected,
          );

  ButtonBuilderType get okButtonBuilder =>
      widget.okButtonBuilder ??
      (context, onPressed) {
        return RaisedButton(
          child: Text("Ok"),
          onPressed: onPressed,
        );
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.7,
      constraints: widget.constraints ??
          (isWeb ? webDefaultConstraints : mobileDefaultConstraints),
      child: Column(
        children: <Widget>[
          if (widget.showSearchBox ?? true)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                focusNode: bloc.focusNode,
                onChanged: bloc.onTextChanged,
                maxLines: widget.searchBoxMaxLines,
                minLines: widget.searchBoxMinLines,
                decoration: widget.searchBoxDecoration ??
                    InputDecoration(
                      hintText: widget.searchHint,
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
                  return Scrollbar(
                    controller: bloc.scrollController,
                    isAlwaysShown: widget.alwaysShowScrollBar,
                    child: ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        var item = snapshot.data[index];
                        bool isSelected =
                            multipleItemsBloc.selectedItems?.contains(item) ??
                                false;
                        isSelected = isSelected || item == widget.selectedValue;
                        return InkWell(
                          child: itemBuilder(context, item, isSelected),
                          onTap: () {
                            if (isMultipleItems) {
                              setState(() {
                                if (isSelected) {
                                  multipleItemsBloc.unselectItem(item);
                                } else {
                                  multipleItemsBloc.selectItem(item);
                                }
                              });
                            } else {
                              onChange?.call(item);
                              Navigator.pop(context);
                            }
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          if (isMultipleItems)
            okButtonBuilder(context, () {
              multipleItemsBloc.onSelectButtonPressed();
              Navigator.pop(context);
            }),
        ],
      ),
    );
  }
}
