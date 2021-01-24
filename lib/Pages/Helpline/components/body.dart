import 'package:flutter/material.dart';
import 'package:fluttericon/web_symbols_icons.dart';
import 'package:my_consoler/Pages/Helpline/components/dialer_card.dart';
import 'package:my_consoler/themes.dart';
import 'package:url_launcher/url_launcher.dart';

class Body extends StatelessWidget {
  const Body({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Align(
            child: Image.asset('assets/images/helpline.png'),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: BackButton(),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Befrienders',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 40.0,
                width: 100.0,
                child: Divider(),
              ),
              Text(
                'Helpline 1',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              DialerCard(
                telephoneNumber: '(+603) - 7956 8144',
                telephoneLink: 'tel://+60379568144',
              ),
              Text(
                'Helpline 2',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              DialerCard(
                telephoneNumber: '(+603) - 7956 8145',
                telephoneLink: 'tel://+60379568145',
              ),
              GestureDetector(
                onTap: () {
                  launch(
                      ('http://www.suicide.org/hotlines/international/malaysia-suicide-hotlines.html'));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      WebSymbols.logout,
                      color: kPrimaryColor,
                      size: 12,
                    ),
                    Text(
                      '  Click for more helplines',
                      style: TextStyle(
                        color: kPrimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
