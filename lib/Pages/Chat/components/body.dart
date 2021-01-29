import 'dart:math';

import 'package:bubble/bubble.dart';
import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:intl/intl.dart';
import 'package:my_consoler/Models/custom_user.dart';
import 'package:my_consoler/Services/database.dart';
import 'package:my_consoler/themes.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:url_launcher/url_launcher.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final DialogFlowtter dialogFlowtter = DialogFlowtter();
  final _textEditingController = new TextEditingController();
  final _scrollController = new ScrollController();
  String resultText = '';
  String lastError = '';
  String lastStatus = '';
  final SpeechToText speech = SpeechToText();
  // ignore: unused_field
  List<LocaleName> _localNames = [];
  bool isSpeechEnabled = false;
  String _currentlocaleId = 'en_US';
  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;

  @override
  void initState() {
    super.initState();
    if (!isSpeechEnabled) initSpeechState();
  }

  Future<void> initSpeechState() async {
    bool hasSpeech = await speech.initialize(
      onError: errorListener,
      onStatus: statusListener,
    );
    if (isSpeechEnabled) {
      _localNames = await speech.locales();
      var systemLocale = await speech.systemLocale();
      _currentlocaleId = systemLocale.localeId;
    }
    if (!mounted) return;
    setState(() {
      isSpeechEnabled = hasSpeech;
    });
  }

  void response(query) async {
    DetectIntentResponse response = await dialogFlowtter.detectIntent(
      queryInput: QueryInput(
        text: TextInput(
          text: query,
          languageCode: 'en',
        ),
      ),
    );
    setState(() {
      messages.insert(0, {'data': 0, 'message': response.text});
    });
    print(response.text);
  }

  List<Map> messages = List();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context);
    return Container(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              vertical: 10,
            ),
            child: Text(
              'Today, ${DateFormat('h:mm a').format(DateTime.now())}',
            ),
          ),
          Flexible(
            child: Scrollbar(
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                controller: _scrollController,
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (context, index) => chat(
                    messages[index]['message'].toString(),
                    messages[index]['data']),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Divider(
            height: 5.0,
            color: kPrimaryLightColor,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18.0),
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  if (details.delta.dy > 0) FocusScope.of(context).unfocus();
                },
                child: Container(
                  child: ListTile(
                    leading: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              blurRadius: .26,
                              spreadRadius: level * 1.5,
                              color: Colors.black.withOpacity(.1)),
                        ],
                      ),
                      child: Tooltip(
                        preferBelow: false,
                        message: 'Speech-to-text',
                        child: FloatingActionButton(
                          backgroundColor: kPrimaryColor,
                          child: Icon(
                            Icons.mic,
                            color: speech.isListening ? Colors.red : null,
                          ),
                          onPressed: () {
                            !isSpeechEnabled || speech.isListening
                                // ignore: unnecessary_statements
                                ? null
                                : startListening();
                          },
                        ),
                      ),
                    ),
                    title: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        color: kAppBarColor,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Scrollbar(
                        child: TextFormField(
                          controller: _textEditingController,
                          decoration: InputDecoration(
                            hintText: 'Enter a message',
                            hintStyle: TextStyle(color: Colors.black54),
                            border: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          keyboardType: TextInputType.multiline,
                          minLines: 1,
                          maxLines: 3,
                          style: TextStyle(fontSize: 16, color: Colors.black),
                          // onChanged: (value) {},
                        ),
                      ),
                    ),
                    trailing: speech.isListening
                        ? Tooltip(
                            preferBelow: false,
                            message: 'Cancel',
                            child: IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () {
                                cancelListening();
                              },
                            ),
                          )
                        : Tooltip(
                            preferBelow: false,
                            message: 'Send',
                            child: IconButton(
                              icon: Icon(
                                Icons.send,
                              ),
                              onPressed: () async {
                                String tempText;
                                tempText = _textEditingController.text;
                                if (_textEditingController.text.isEmpty ||
                                    tempText.replaceAll(' ', '').isEmpty) {
                                  print('Empty message.');
                                } else {
                                  await DatabaseService(uid: user.uid)
                                      .addChatData(_textEditingController.text,
                                          DateTime.now());
                                  setState(() {
                                    messages.insert(0, {
                                      'data': 1,
                                      'message': _textEditingController.text
                                    });
                                  });
                                  response(_textEditingController.text);
                                  _textEditingController.clear();
                                  _scrollController.animateTo(
                                    0.0,
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                  );
                                }
                              },
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void startListening() {
    resultText = '';
    lastError = '';
    speech.listen(
      onResult: resultListener,
      listenFor: Duration(seconds: 10),
      localeId: _currentlocaleId,
      onSoundLevelChange: soundLevelListener,
      cancelOnError: true,
      listenMode: ListenMode.confirmation,
    );
    setState(() {});
  }

  void stopListening() {
    speech.stop();
    setState(() {
      level = 0.0;
    });
  }

  void cancelListening() {
    speech.cancel();
    setState(() {
      level = 0.0;
    });
  }

  void resultListener(SpeechRecognitionResult result) {
    setState(() {
      level = 0.0;
      resultText = '${result.recognizedWords}';
      _textEditingController.value = TextEditingValue(
        text: resultText,
        selection: TextSelection.collapsed(offset: resultText.length),
      );
    });
  }

  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);
    setState(() {
      this.level = level;
    });
  }

  void errorListener(SpeechRecognitionError error) {
    setState(() {
      lastError = '${error.errorMsg} - ${error.permanent}';
    });
  }

  void statusListener(String status) {
    setState(() {
      lastStatus = '$status';
    });
  }

  Widget chat(String msg, int dt) {
    Size size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Row(
        mainAxisAlignment:
            dt == 0 ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          dt == 0
              ? Container(
                  height: 60,
                  width: 60,
                  child: CircleAvatar(
                    backgroundImage: AssetImage('assets/icons/Icon 1.png'),
                  ),
                )
              : Container(),
          Padding(
            padding: EdgeInsets.all(10),
            child: Bubble(
              radius: Radius.circular(10),
              color: dt == 0 ? Colors.grey : kPrimaryColor,
              elevation: 1,
              child: Padding(
                padding: EdgeInsets.all(0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    Flexible(
                      child: Container(
                        constraints:
                            BoxConstraints(maxWidth: size.width * 0.45),
                        child: SelectableLinkify(
                          onOpen: _onOpen,
                          options: LinkifyOptions(humanize: false),
                          text: msg,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          linkStyle: TextStyle(color: Colors.lightBlue[100]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onOpen(LinkableElement link) async {
    if (await canLaunch(link.url)) {
      await launch(link.url);
    } else {
      throw 'Could not launch $link';
    }
  }
}
