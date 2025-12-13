// search_widget.dart
import 'package:flutter/material.dart';

class SearchWidget extends StatelessWidget {
  final Function(String) onItemSelected;
  final List<String> itemList;

  const SearchWidget({
    Key? key,
    required this.onItemSelected,
    required this.itemList,
  }) : super(key: key);

  List<String> filterItems(String query) {
    return itemList.where(
      (itemList) => itemList.toLowerCase().contains(query.toLowerCase()),
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: SearchAnchor(
        builder: (BuildContext context, SearchController controller) {
          return SearchBar(
            controller: controller,
            hintText: "Search for a point of interest...",
            padding: const WidgetStatePropertyAll<EdgeInsets>(
              EdgeInsets.symmetric(horizontal: 16.0),
            ),
            onTap: () {
              controller.openView();
            },
            onChanged: (_) {
              controller.openView();
            },
            leading: const Icon(Icons.search),
          );
        },
        suggestionsBuilder: (BuildContext context, SearchController controller) {
          final query = controller.text.toLowerCase();

          final searchResults = itemList.where(
            (item) => item.toLowerCase().contains(query),
          );

          return searchResults.map (
            (item) => ListTile(
              title: Text(item),
              onTap: () {
                controller.closeView(item);
                onItemSelected(item);
              },
            ),
          );
        },
      ),
    );
  }
}