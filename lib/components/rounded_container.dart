import 'package:auto_size_text/auto_size_text.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:random_color/random_color.dart';

class RoundedContainer extends StatelessWidget {
  final String title;
  final String content;
  final double marginValue;
  final bool isFull;

  RoundedContainer({
    Key key,
    this.title,
    this.content,
    this.marginValue = 20.0,
    this.isFull = false,
  }) : super(key: key);

  final _scrollController = ScrollController();
  final Color _color = RandomColor().randomColor(
    colorHue: ColorHue.blue,
    colorBrightness: ColorBrightness.dark,
  );

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.only(right: marginValue),
      width: isFull ? size.width : size.width * 0.40,
      height: isFull ? null : size.height * 0.30,
      decoration: BoxDecoration(
        color: _color,
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AutoSizeText(
              title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              minFontSize: 16,
              maxFontSize: 20,
              maxLines: 1,
            ),
            SizedBox(
              height: 15,
            ),
            Expanded(
              child: Scrollbar(
                child: FadingEdgeScrollView.fromSingleChildScrollView(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Text(
                      content,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
