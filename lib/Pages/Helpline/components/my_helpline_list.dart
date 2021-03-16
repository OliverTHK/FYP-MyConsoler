import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:my_consoler/components/loading_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class MyHelplineList extends StatefulWidget {
  @override
  _MyHelplineListState createState() => _MyHelplineListState();
}

class _MyHelplineListState extends State<MyHelplineList> {
  final SlidableController slidableController = SlidableController();

  Stream<QuerySnapshot> getHelplinesStreamSnapshots(
      BuildContext context) async* {
    yield* FirebaseFirestore.instance
        .collection('myhelplines')
        .orderBy('helpline_name')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: getHelplinesStreamSnapshots(context),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LoadingWidget();
        return ListView.builder(
          itemCount: snapshot.data.docs.length ?? 0,
          itemBuilder: (context, index) {
            return Slidable(
              controller: slidableController,
              child: ListTile(
                title:
                    Text((snapshot.data.docs[index])['helpline_name'] ?? 'N/A'),
                subtitle:
                    Text((snapshot.data.docs[index])['helpline_number'] ?? '-'),
              ),
              actionPane: SlidableDrawerActionPane(),
              actions: <Widget>[
                IconSlideAction(
                  caption: 'Dial',
                  color: Colors.indigo,
                  icon: Icons.call_outlined,
                  onTap: () async => launch(('tel:' +
                      (snapshot.data.docs[index])['helpline_number'])),
                ),
                IconSlideAction(
                  caption: 'Visit URL',
                  color: Colors.blue,
                  icon: Icons.web_outlined,
                  onTap: () async =>
                      launch(((snapshot.data.docs[index])['helpline_website'])),
                ),
                IconSlideAction(
                  caption: 'Close',
                  color: Colors.red,
                  icon: Icons.close_outlined,
                  onTap: () => Slidable.of(context)?.close(),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
