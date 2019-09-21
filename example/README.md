# select_dialog Package Examples

## Simple Example
```dart
RaisedButton(
  child: Text(ex1),
  onPressed: () {
    SelectDialog.showModal<String>(
      context,
      label: "Simple Example",
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
```

## Model Example
```dart
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
```

## Item Builder Example
```dart
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
```

## Model Example
```dart
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
```


## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
