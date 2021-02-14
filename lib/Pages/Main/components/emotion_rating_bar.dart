import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EmotionRatingBar extends StatefulWidget {
  final double value;

  const EmotionRatingBar({Key key, this.value}) : super(key: key);
  @override
  _EmotionRatingBarState createState() => _EmotionRatingBarState();
}

class _EmotionRatingBarState extends State<EmotionRatingBar> {
  String feedbackText;
  double sliderValue;
  IconData feedbackIcon;
  Color feedbackColor;

  @override
  Widget build(BuildContext context) {
    sliderValue = this.widget.value;
    if (sliderValue >= -10.0 && sliderValue < -2.0) {
      feedbackText = 'COULD BE BETTER';
      feedbackIcon = FontAwesomeIcons.sadTear;
      feedbackColor = Colors.red;
    }
    if (sliderValue >= -2.0 && sliderValue < 0.0) {
      feedbackText = 'SLIGHTLY NEGATIVE';
      feedbackIcon = FontAwesomeIcons.frown;
      feedbackColor = Colors.yellow;
    }
    if (sliderValue == 0.0) {
      feedbackText = 'NEUTRAL';
      feedbackIcon = FontAwesomeIcons.meh;
      feedbackColor = Colors.amber;
    }
    if (sliderValue > 0.0 && sliderValue <= 5.0) {
      feedbackText = 'GOOD';
      feedbackIcon = FontAwesomeIcons.smile;
      feedbackColor = Colors.green;
    }
    if (sliderValue > 5.0 && sliderValue <= 10.0) {
      feedbackText = 'EXCELLENT';
      feedbackIcon = FontAwesomeIcons.laugh;
      feedbackColor = Colors.green;
    }
    return Container(
      child: Row(
        children: [
          Container(
            child: Icon(
              feedbackIcon,
              color: feedbackColor,
              size: 50.0,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  child: Text(
                    feedbackText,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Container(
                    child: Text(
                      'SCORE : ' + sliderValue.toString(),
                    ),
                  ),
                ),
                Container(
                  child: Slider(
                    value: sliderValue,
                    min: -10.0,
                    max: 10.0,
                    divisions: 20,
                    onChanged: null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
