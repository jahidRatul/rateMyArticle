import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:rating_app/Ui/loginScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

String emailValue;

class HomeScreen extends StatefulWidget {
  static String id = 'home';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void initState() {
    _getUserInfo();
    getArticles();

    super.initState();
  }

  _getUserInfo() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    String emailID = localStorage.getString('userEmail');
    emailValue = emailID;
  }

  List<ArticleWidget> articlesAll = [];

  Future<List<ArticleWidget>> getArticles() async {
    final url = 'https://iotait.tech/ArticleRating/public/articles';

    http.Response response = await http.get(
      url,
      headers: {
        'Content-type': 'application/json',
      },
    );
    setState(() {});
    var jsonData = json.decode(response.body);

    List<ArticleWidget> articlesAll = [];

    for (var i in jsonData) {
      ArticleWidget article = ArticleWidget(
        details: i['description'],
        name: i['name'],
        articleId: i['id'],
        ratedUsers: i['total_rated_users'],
        avgRating: i['avg_rating'],
      );

      articlesAll.add(article);
    }

    return articlesAll;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushReplacementNamed(context, LoginScreen.id);
        },
        label: Text('Logout'),
        icon: Icon(Icons.exit_to_app),
        backgroundColor: Colors.green,
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          FutureBuilder(
            future: getArticles(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.data == null) {
                return Container(
                  child: Center(child: Text('Loading...')),
                );
              } else
                return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ArticleWidget(
                        name: snapshot.data[index].name.toString(),
                        details: snapshot.data[index].details.toString(),
                        articleId: snapshot.data[index].articleId,
                        ratedUsers: snapshot.data[index].ratedUsers,
                        avgRating: snapshot.data[index].avgRating.toString(),
                      );
                    });
            },
          ),
          SizedBox(
            height: 80,
          ),
        ],
      ),
    );
  }
}

class ArticleWidget extends StatefulWidget {
  final _HomeScreenState homeScreenState;
  ArticleWidget({
    this.name,
    this.details,
    this.articleId,
    this.avgRating,
    this.ratedUsers,
    this.homeScreenState,
  });

  final String name;
  final String details;
  final int articleId;
  final String avgRating;
  final int ratedUsers;

  @override
  _ArticleWidgetState createState() => _ArticleWidgetState(homeScreenState);
}

class _ArticleWidgetState extends State<ArticleWidget> {
  double _rating;
  final _HomeScreenState homeScreenState;

  _ArticleWidgetState(this.homeScreenState);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 3.0, right: 3, top: 3),
      child: Container(
        child: Column(
          children: [
            Card(
              elevation: 3,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0C1A35),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          widget.details,
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF0C1A35),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text("Rating:"),
                                RatingBar(
                                  initialRating: double.parse(widget.avgRating),
                                  minRating: 1,
                                  direction: Axis.horizontal,
                                  allowHalfRating: true,
                                  itemSize: 25,
                                  itemCount: 5,
                                  itemPadding:
                                      EdgeInsets.symmetric(horizontal: 2.0),
                                  itemBuilder: (context, _) => Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  onRatingUpdate: (rating) {},
                                  ignoreGestures: true,
                                ),
                                Text(
                                  ('(${widget.ratedUsers})'),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                              width: 80,
                              child: RaisedButton(
                                // color: Colors.amber,
                                child: Text('Rate it'),
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (_) => new AlertDialog(
                                            title: new Text("Rate Now"),
                                            content: RatingBar(
                                              initialRating: 0,
                                              minRating: 1,
                                              direction: Axis.horizontal,
                                              allowHalfRating: true,
                                              itemSize: 40,
                                              itemCount: 5,
                                              itemPadding: EdgeInsets.symmetric(
                                                  horizontal: 2.0),
                                              itemBuilder: (context, _) => Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                              ),
                                              onRatingUpdate: (rating) {
                                                setState(() {
                                                  _rating = rating;
                                                });
                                              },
                                            ),
                                            actions: <Widget>[
                                              FlatButton(
                                                child: Text('Cancel'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              FlatButton(
                                                child: Text('Submit'),
                                                onPressed: () async {
                                                  final url =
                                                      'https://iotait.tech/ArticleRating/public/articles/${widget.articleId}/rate';

                                                  Map data = {
                                                    'email': emailValue,
                                                    'rating': _rating,
                                                  };
                                                  var bodyValue =
                                                      json.encode(data);
                                                  http.Response response =
                                                      await http.post(url,
                                                          headers: {
                                                            "Content-Type":
                                                                "application/json"
                                                          },
                                                          body: bodyValue);

                                                  Map<String, dynamic> user =
                                                      jsonDecode(response.body);
                                                  if (user['success'] == 3) {
                                                    showToast(
                                                        "Already submitted rating once",
                                                        duration: 3,
                                                        gravity: Toast.BOTTOM);
                                                    Navigator.pop(context);
                                                  }
                                                  if (user['success'] == 4) {
                                                    showToast("Provide Star",
                                                        duration: 3,
                                                        gravity: Toast.BOTTOM);
                                                  }
                                                  if ((user['success'] == 1)) {
                                                    showToast(
                                                        "Rating submitted successfully",
                                                        duration: 4,
                                                        gravity: Toast.BOTTOM);
                                                    Navigator.pop(context);

                                                    homeScreenState
                                                        ?.getArticles();
                                                  }
                                                },
                                              ),
                                            ],
                                          ));
                                },
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }
}
