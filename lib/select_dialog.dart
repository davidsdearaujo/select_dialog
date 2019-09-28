library select_dialog;

import 'package:flutter/material.dart';
import 'select_bloc.dart';

typedef Widget SelectOneItemBuilderType<T>(
    BuildContext context, T item, bool isSelected);

class SelectDialog<T> extends StatefulWidget {
  final T selectedValue;
  final List<T> itemsList;
  final bool showSearchBox;
  final void Function(T) onChange;
  final Future<List<T>> Function(String text) onFind;
  final SelectOneItemBuilderType<T> itemBuilder;
  final InputDecoration searchBoxDecoration;

  const SelectDialog({
    Key key,
    this.itemsList,
    this.showSearchBox,
    this.onChange,
    this.selectedValue,
    this.onFind,
    this.itemBuilder,
    this.searchBoxDecoration,
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
  }) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(label ?? ""),
          content: SelectDialog<T>(
            selectedValue: selectedValue,
            itemsList: items,
            onChange: onChange,
            onFind: onFind,
            showSearchBox: showSearchBox,
            itemBuilder: itemBuilder,
            searchBoxDecoration: searchBoxDecoration,
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
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * .9,
      height: MediaQuery.of(context).size.height * .7,
      child: Column(
        children: <Widget>[
          if (widget.showSearchBox ?? true)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: bloc.onTextChanged,
                decoration: widget.searchBoxDecoration ??
                    InputDecoration(
                      hintText: "Procurar",
                      contentPadding: const EdgeInsets.all(2.0),
                    ),
              ),
            ),
          Expanded(
            child: Scrollbar(
              child: StreamBuilder<List<T>>(
                stream: bloc.filteredListOut,
                builder: (context, snapshot) {
                  if (snapshot.hasError)
                    return Center(child: Text("Oops"));
                  else if (!snapshot.hasData)
                    return Center(child: CircularProgressIndicator());
                  else if (snapshot.data.isEmpty)
                    return Center(child: Text("No data found"));
                  return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      var item = snapshot.data[index];
                      if (widget.itemBuilder != null)
                        return InkWell(
                          child: widget.itemBuilder(
                              context, item, item == widget.selectedValue),
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
