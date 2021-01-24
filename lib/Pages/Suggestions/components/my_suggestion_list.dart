import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:my_consoler/components/loading_widget.dart';
import 'package:my_consoler/components/rounded_container.dart';
import 'package:provider/provider.dart';

class MySuggestionList extends StatefulWidget {
  @override
  _MySuggestionListState createState() => _MySuggestionListState();
}

class _MySuggestionListState extends State<MySuggestionList> {
  final _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    final mySuggestions = Provider.of<QuerySnapshot>(context);
    return mySuggestions != null
        ? FadingEdgeScrollView.fromScrollView(
            child: GridView.builder(
              controller: _scrollController,
              physics: BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: .85,
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 20,
              ),
              itemCount: mySuggestions.docs.length ?? 0,
              itemBuilder: (context, index) {
                return RoundedContainer(
                  title:
                      (mySuggestions.docs[index])['suggestion_title'] ?? 'N/A',
                  content: (mySuggestions.docs[index])['suggestion_content'] ??
                      '-- empty --',
                  marginValue: 10,
                );
              },
            ),
          )
        : LoadingWidget();
  }
}
