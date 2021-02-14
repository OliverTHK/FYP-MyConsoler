import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_consoler/components/loading_widget.dart';
import 'package:my_consoler/components/rounded_container.dart';

class MyRecommendationCarousel extends StatefulWidget {
  final List<String> keyWordList;

  const MyRecommendationCarousel({Key key, @required this.keyWordList})
      : super(key: key);
  @override
  _MyRecommendationCarouselState createState() =>
      _MyRecommendationCarouselState();
}

class _MyRecommendationCarouselState extends State<MyRecommendationCarousel> {
  Stream<QuerySnapshot> getRecommendationsStreamSnapshots(
      BuildContext context) async* {
    yield* FirebaseFirestore.instance
        .collection('mysuggestions')
        .where('suggestion_tag', arrayContainsAny: this.widget.keyWordList)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: getRecommendationsStreamSnapshots(context),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LoadingWidget();
        return snapshot.data.docs.length == 0
            ? Center(
                child: AutoSizeText(
                  'No recommendation.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  minFontSize: 12,
                  maxFontSize: 18,
                ),
              )
            : CarouselSlider.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  return RoundedContainer(
                    title: (snapshot.data.docs[index])['suggestion_title'],
                    content: (snapshot.data.docs[index])['suggestion_content'],
                    marginValue: 0,
                    isFull: true,
                  );
                },
                options: CarouselOptions(
                  viewportFraction: 0.75,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  enableInfiniteScroll: false,
                  scrollPhysics: BouncingScrollPhysics(),
                ),
              );
      },
    );
  }
}
