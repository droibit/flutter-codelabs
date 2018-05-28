import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BabyVotesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baby Names',
      home: VotesPage(title: 'Baby Name Votes'),
    );
  }
}

class VotesPage extends StatelessWidget {
  final String title;

  VotesPage({
    Key key,
    this.title,
  })  : assert(title != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('baby').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Text('Loading...');

          return ListView.builder(
            itemCount: snapshot.data.documents.length,
            padding: EdgeInsets.only(top: 10.0),
            itemExtent: 55.0,
            itemBuilder: (context, index) {
              final document = snapshot.data.documents[index];
              return _buildListItem(context, document);
            },
          );
        },
      ),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return ListTile(
      key: ValueKey(document.documentID),
      title: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Color(0x80000000)),
          borderRadius: BorderRadius.circular(5.0),
        ),
        padding: EdgeInsets.all(10.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(document.data['name'].toString()),
            ),
            Text(document.data['votes'].toString()),
          ],
        ),
      ),
      onTap: () {
        Firestore.instance.runTransaction((transaction) async {
          final fleshSnap = await transaction.get(document.reference);
          await transaction.update(fleshSnap.reference, {
            'votes': fleshSnap['votes'] + 1,
          });
        });
      },
    );
  }
}
