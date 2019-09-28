import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:select_dialog/select_dialog.dart';

import 'user_model.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String ex1 = "Simple Example";
  String ex2 = "Model Example";
  UserModel ex3 = UserModel(name: "Item Builder Example");
  UserModel ex4 = UserModel(name: "Online Example");

  final modelItems = List.generate(
    50,
    (index) => UserModel(
      avatar: "https://i.imgur.com/lTy4hiN.jpg",
      name: "Deivão $index",
      id: "$index",
      createdAt: DateTime.now(),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Dialog Example"),
      ),
      body: Container(
        padding: EdgeInsets.all(25),
        width: double.infinity,
        child: Column(
          children: <Widget>[
            RaisedButton(
              child: Text(ex1),
              onPressed: () {
                SelectDialog.showModal<String>(
                  context,
                  label: "Simple Example",
                  showSearchBox: false,
                  selectedValue: ex1,
                  items: List.generate(50, (index) => "Item $index"),
                  onChange: (String selected) {
                    setState(() {
                      ex1 = selected;
                    });
                  },
                );
              },
            ),
            RaisedButton(
              child: Text(ex2),
              onPressed: () {
                SelectDialog.showModal<UserModel>(
                  context,
                  label: "Model Example",
                  items: modelItems,
                  onChange: (UserModel selected) {
                    setState(() {
                      ex2 = selected.name;
                    });
                  },
                );
              },
            ),
            RaisedButton(
              child: Text(ex3.name),
              onPressed: () {
                SelectDialog.showModal<UserModel>(
                  context,
                  label: "Item Builder Example",
                  items: modelItems,
                  selectedValue: ex3,
                  itemBuilder:
                      (BuildContext context, UserModel item, bool isSelected) {
                    return Container(
                      decoration: !isSelected
                          ? null
                          : BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.white,
                              border: Border.all(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(item.avatar),
                        ),
                        selected: isSelected,
                        title: Text(item.name),
                        subtitle: Text(item.createdAt.toString()),
                      ),
                    );
                  },
                  onChange: (selected) {
                    setState(() {
                      ex3 = selected;
                    });
                  },
                );
              },
            ),
            RaisedButton(
              child: Text(ex4.name),
              onPressed: () {
                SelectDialog.showModal<UserModel>(
                  context,
                  label: "Online Example",
                  selectedValue: ex4,
                  onFind: (String filter) => getData(filter),
                  onChange: (UserModel selected) {
                    setState(() {
                      ex4 = selected;
                    });
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<List<UserModel>> getData(filter) async {
    var response = await Dio().get(
      "http://5d85ccfb1e61af001471bf60.mockapi.io/user",
      queryParameters: {"filter": filter},
    );

    var models = UserModel.fromJsonList(response.data);
    return models;
  }
}
