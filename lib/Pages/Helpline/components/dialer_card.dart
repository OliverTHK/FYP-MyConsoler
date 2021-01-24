import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DialerCard extends StatelessWidget {
  final String telephoneNumber;
  final String telephoneLink;

  const DialerCard({
    Key key,
    this.telephoneNumber,
    this.telephoneLink,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: StadiumBorder(),
      margin: EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 25.0,
      ),
      child: ListTile(
        shape: StadiumBorder(),
        leading: Icon(
          Icons.phone,
        ),
        title: Text(
          telephoneNumber,
        ),
        onTap: () {
          launch((telephoneLink));
        },
      ),
    );
  }
}
