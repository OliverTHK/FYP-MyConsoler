import 'dart:math';

import 'package:bubble/bubble.dart';
import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
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
  List<Map<String, dynamic>> messages = [];
  List<String> suggestionChipTexts = [];

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

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context);
    Size size = MediaQuery.of(context).size;
    bool isPrevUser;
    return Column(
      children: [
        Expanded(
          child: Scrollbar(
            child: ListView.separated(
              physics: BouncingScrollPhysics(),
              controller: _scrollController,
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                var obj = messages[messages.length - 1 - index];
                Message message = obj['message'];
                bool isUserMessage = obj['isUserMessage'] ?? false;
                bool isSameUser = isPrevUser == obj['isUserMessage'];
                isPrevUser = obj['isUserMessage'];
                return Row(
                  mainAxisAlignment: isUserMessage
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    isUserMessage
                        ? Container()
                        : Container(
                            height: 40.0,
                            width: 40.0,
                            child: !isSameUser
                                ? CircleAvatar(
                                    backgroundImage:
                                        AssetImage('assets/icons/Icon 1.png'),
                                  )
                                : null,
                          ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        constraints: BoxConstraints(maxWidth: size.width * 0.5),
                        child: LayoutBuilder(
                          builder: (context, constrains) {
                            return Bubble(
                              radius: Radius.circular(10),
                              color:
                                  isUserMessage ? kPrimaryColor : Colors.grey,
                              elevation: 1.0,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Theme(
                                  data: ThemeData(
                                    textSelectionColor: Colors.cyan,
                                  ),
                                  child: SelectableLinkify(
                                    onOpen: _onOpen,
                                    text: message?.text?.text[0] ?? '',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    linkStyle:
                                        TextStyle(color: Colors.lightBlue[100]),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
              separatorBuilder: (_, i) => Container(
                height: 10.0,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 20.0,
              ),
            ),
          ),
        ),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8.0,
          runSpacing: 0.0,
          children:
              List<Widget>.generate(suggestionChipTexts.length, (int index) {
            return ActionChip(
              label: Text(suggestionChipTexts[index]),
              onPressed: () {
                setState(() async {
                  await DatabaseService(uid: user.uid)
                      .addChatData(suggestionChipTexts[index], DateTime.now());
                  sendMessage(suggestionChipTexts[index]);
                  suggestionChipTexts.clear();
                });
              },
            );
          }),
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
                          hintText: 'Message...',
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
                                  tempText.trim().isEmpty) {
                                print('Empty message.');
                              } else {
                                await DatabaseService(uid: user.uid)
                                    .addChatData(_textEditingController.text,
                                        DateTime.now());
                                sendMessage(_textEditingController.text);
                                _textEditingController.clear();
                                suggestionChipTexts.clear();
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

  Future<void> _onOpen(LinkableElement link) async {
    if (await canLaunch(link.url)) {
      await launch(link.url);
    } else {
      throw 'Could not launch $link';
    }
  }

  void sendMessage(String text) async {
    if (text.isEmpty) return;
    _scrollController.animateTo(
      0.0,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    setState(() {
      addMessage(
        Message(text: DialogText(text: [text])),
        true,
      );
    });

    DetectIntentResponse response = await dialogFlowtter.detectIntent(
      queryInput: QueryInput(
        text: TextInput(
          text: text,
        ),
      ),
    );

    if (response.message == null) return;
    setState(() {
      print(response.queryResult.fulfillmentMessages);
      response.queryResult.fulfillmentMessages.forEach((element) {
        if (element.type == MessageType.text) addMessage(element);
        if (element.type == MessageType.payload) {
          for (int i = 0; i < element.payload['suggestions'].length; ++i) {
            print('Suggestion $i: ${element.payload['suggestions'][i]}');
            suggestionChipTexts.add(element.payload['suggestions'][i]);
          }
          print("All suggestions: ${element.payload['suggestions']}");
        }
      });
    });
  }

  void addMessage(Message message, [bool isUserMessage]) {
    messages.add({
      'message': message,
      'isUserMessage': isUserMessage ?? false,
    });
  }

  @override
  void dispose() {
    dialogFlowtter.dispose();
    super.dispose();
  }
}
