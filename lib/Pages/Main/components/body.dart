import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttericon/elusive_icons.dart';
import 'package:my_consoler/Models/custom_user.dart';
import 'package:my_consoler/Pages/Main/components/emotion_rating_bar.dart';
import 'package:my_consoler/Pages/Main/components/extra_stop_word_list.dart';
import 'package:my_consoler/Pages/Main/components/my_recommendation_carousel.dart';
import 'package:my_consoler/Services/database.dart';
import 'package:my_consoler/components/loading_widget.dart';
import 'package:my_consoler/components/modified_text_input_formatter.dart';
import 'package:my_consoler/themes.dart';
import 'package:provider/provider.dart';
import 'package:sentiment_dart/sentiment_dart.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  double score;
  String thought;
  List<String> splittedName = new List<String>();
  List<String> allKeywords = new List<String>();
  List<String> inputKeywords = new List<String>();
  Map sentimentResult = Map<String, dynamic>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final sentiment = Sentiment();
    final myUsers = Provider.of<DocumentSnapshot>(context);
    final user = Provider.of<CustomUser>(context);
    Size size = MediaQuery.of(context).size;

    if (myUsers != null) {
      // *** FOR USER FIRST NAME EXTRACTION ***
      splittedName = myUsers.data()['name'].split(' ');
      print(myUsers.data());

      // *** FOR EMOTION RATING BAR LOGIC ***
      if (myUsers.data()['thought'] != null)
        sentimentResult = sentiment.analysis(myUsers.data()['thought']);
      else
        sentimentResult = sentiment.analysis('none');
      if (sentimentResult['good words'] != null) {
        for (var i = 0; i < sentimentResult['good words'].length; ++i) {
          if (!inputKeywords.contains((sentimentResult['good words'])[i].first))
            inputKeywords
                .add((sentimentResult['good words'])[i].first.toString());
        }
      }
      if (sentimentResult['badword'] != null) {
        for (var i = 0; i < sentimentResult['badword'].length; ++i) {
          if (!inputKeywords.contains((sentimentResult['badword'])[i].first))
            inputKeywords.add((sentimentResult['badword'])[i].first.toString());
        }
      }
      score = sentimentResult['score'].toDouble();
      // To limit the score obtained from the sentiment analysis so that the value doesn't go beyond Slider value limit
      if (score < -10.0) {
        score = -10.0;
      }
      if (score > 10.0) {
        score = 10.0;
      }

      // *** FOR REMOVING EXTRA STOP WORDS FROM inputKeyword LIST ***
      inputKeywords.removeWhere(
          (element) => extraStopWordList.contains(element.toLowerCase()));

      // Copy the keywords from inputKeywords to allKeywords
      allKeywords = List.from(inputKeywords);

      // *** EXTRA USER DATA EXTRACTION FOR RECOMMENDATION LOGIC ***
      if (myUsers.data()['age'] < 55)
        allKeywords.add('young');
      else
        allKeywords.add('old');
      if (myUsers.data()['financialStatus'] == 'Poor') allKeywords.add('poor');
      if (myUsers.data()['isPatient'] == 'Yes')
        allKeywords.add('covid_patient');
      if (myUsers.data()['occupation'] == 'a frontliner')
        allKeywords.add('frontliner');
      else if (myUsers.data()['occupation'] == 'a student')
        allKeywords.add('student');
      else if (myUsers.data()['occupation'] == 'a worker')
        allKeywords.add('worker');
      else if (myUsers.data()['occupation'] == 'retired')
        allKeywords.add('retired');
      else if (myUsers.data()['occupation'] == 'self-employed')
        allKeywords.add('self-employed');
      else if (myUsers.data()['occupation'] == 'unemployed')
        allKeywords.add('unemployed');
      if (allKeywords.length > 10) {
        // Remove any keyword(s) if the list size is more than 10 because Firestore query only allows up to 10 keywords search in array type field
        while (allKeywords.length > 10) {
          allKeywords.shuffle();
          allKeywords.removeLast();
        }
      }
      print(allKeywords);
      print(sentimentResult);
    }

    return myUsers != null
        ? StreamProvider<QuerySnapshot>.value(
            value: DatabaseService().mySuggestions,
            child: Stack(
              children: [
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    color: kAppBarColor,
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Tooltip(
                                message: 'Call Helpline',
                                child: FlatButton(
                                  shape: StadiumBorder(),
                                  color: kSecondaryLightColor,
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/helpline');
                                  },
                                  child: Text(
                                    'SOS',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: size.width * 0.03,
                              ),
                              CircleAvatar(
                                child: IconButton(
                                  icon: Icon(Icons.settings),
                                  tooltip: 'Settings',
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/settings');
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        myUsers != null
                            ? Text(
                                'Hi, ' + splittedName.first,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : Text(''),
                        SizedBox(
                          height: 5.0,
                        ),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                          shadowColor: Colors.black,
                          child: Column(
                            children: [
                              ListTile(
                                leading: Icon(Elusive.lightbulb),
                                title: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: AutoSizeText(
                                    'Current Thought/Feeling (Extracted Keywords)',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    minFontSize: 12,
                                    maxFontSize: 18,
                                    maxLines: 2,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      inputKeywords.isNotEmpty
                                          ? '\"' +
                                              inputKeywords.join(', ') +
                                              '\"'
                                          : '-- nothing --',
                                    ),
                                    Divider(),
                                    EmotionRatingBar(
                                      value: score ?? 0.0,
                                    ),
                                  ],
                                ),
                                dense: true,
                              ),
                              ButtonBar(
                                children: [
                                  FlatButton(
                                    onPressed: () {
                                      showModalBottomSheet(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20),
                                          ),
                                        ),
                                        isScrollControlled: true,
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Container(
                                            padding: EdgeInsets.only(
                                              bottom: MediaQuery.of(context)
                                                  .viewInsets
                                                  .bottom,
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  Row(
                                                    children: <Widget>[
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 8.0,
                                                        ),
                                                        child: Text(
                                                          'Edit Thought',
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      Spacer(),
                                                      CloseButton(),
                                                    ],
                                                  ),
                                                  SizedBox(height: 10),
                                                  Form(
                                                    key: _formKey,
                                                    child: Column(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            horizontal: 8.0,
                                                          ),
                                                          child: Container(
                                                            child:
                                                                TextFormField(
                                                              inputFormatters: [
                                                                new ModifiedLengthLimitingTextInputFormatter(
                                                                    50)
                                                              ],
                                                              decoration:
                                                                  InputDecoration(
                                                                focusedBorder:
                                                                    UnderlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                    width: 2.0,
                                                                    color:
                                                                        kPrimaryLightColor,
                                                                  ),
                                                                ),
                                                                hintText:
                                                                    'Input your thought here',
                                                              ),
                                                              autofocus: true,
                                                              initialValue:
                                                                  myUsers.data()[
                                                                      'thought'],
                                                              maxLength: 50,
                                                              keyboardType:
                                                                  TextInputType
                                                                      .text,
                                                              validator: (String
                                                                  value) {
                                                                if (!RegExp(
                                                                        '^[a-zA-Z]+(([ ])?[a-zA-Z,.]*)*\$')
                                                                    .hasMatch(
                                                                        value)) {
                                                                  return 'Only alphabets, \",\" and \".\" allowed.';
                                                                }
                                                                return null;
                                                              },
                                                              onSaved: (String
                                                                  value) {
                                                                if (value
                                                                    .isEmpty) {
                                                                  thought = myUsers
                                                                          .data()[
                                                                      'thought'];
                                                                } else {
                                                                  thought =
                                                                      value;
                                                                }
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(height: 10),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            horizontal: 8.0,
                                                          ),
                                                          child: SizedBox(
                                                            width:
                                                                double.infinity,
                                                            child: FlatButton(
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                              ),
                                                              color:
                                                                  kPrimaryColor,
                                                              onPressed:
                                                                  () async {
                                                                if (inputKeywords
                                                                    .isNotEmpty)
                                                                  inputKeywords
                                                                      .clear();
                                                                if (allKeywords
                                                                    .isNotEmpty)
                                                                  allKeywords
                                                                      .clear();
                                                                if (!_formKey
                                                                    .currentState
                                                                    .validate()) {
                                                                  return;
                                                                }
                                                                _formKey
                                                                    .currentState
                                                                    .save();
                                                                await DatabaseService(
                                                                        uid: user
                                                                            .uid)
                                                                    .updateThoughtData(
                                                                        thought ??
                                                                            myUsers.data()['thought']);
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: Text(
                                                                'Save',
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(height: 10),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Text('Edit'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ConstrainedBox(
                              constraints:
                                  BoxConstraints(maxWidth: size.width * 0.5),
                              child: AutoSizeText(
                                'Recommendations',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: size.width * 0.05 + 2,
                                  fontWeight: FontWeight.bold,
                                ),
                                minFontSize: 18,
                                maxFontSize: 26,
                                maxLines: 1,
                              ),
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    height: 26,
                                    child: VerticalDivider(),
                                  ),
                                  FlatButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, '/suggestions');
                                    },
                                    child: Text('View All'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Divider(),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8.0),
                            child: MyRecommendationCarousel(
                              keyWordList: allKeywords ?? [''],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        : LoadingWidget();
  }
}
