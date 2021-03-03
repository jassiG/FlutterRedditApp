import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(RedditApp());
}

// global variables
var imageUrl =
    "https://www.materialui.co/materialIcons/navigation/refresh_white_192x192.png";
var imageTitle = "Tap the Reload Icon for a Random Meme";
var imageAuthur = "me";
var _isLoading = false;

class RedditApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new RedditState();
  }
}

class RedditState extends State<RedditApp> {
  var urls = {
    0: "https://www.reddit.com/r/memes/hot.json?limit=56",
    1: "https://www.reddit.com/r/dankmemes/hot.json?limit=56"
  };
  _fetchData() async {
    Random rndm = new Random();
    print("Attempting to fetch the data from the network...");
    int subreddit = rndm.nextInt(2);
    var response = await http.get(urls[subreddit]);
    var map = json.decode(response.body);
    int memeNumber = rndm.nextInt(26);

    if (map['data']['children'][memeNumber]['data']['domain'] != 'i.redd.it') {
      subreddit = rndm.nextInt(2);
      memeNumber = rndm.nextInt(56);
      response = await http.get(urls[subreddit]);
      map = json.decode(response.body);
    } else if (map['data']['children'][memeNumber]['data']['domain'] ==
        'i.redd.it') {
      imageUrl = map['data']['children'][memeNumber]['data']['url'];
      imageTitle = map['data']['children'][memeNumber]['data']['title'];
      imageAuthur =
          map['data']['children'][memeNumber]['data']['author_fullname'];
    } else {
      imageUrl =
          "https://www.elegantthemes.com/blog/wp-content/uploads/2020/07/000-HTTP-Error-400.png";
      imageTitle = map['data']['children'][memeNumber]['data']['title'];
      imageAuthur =
          map['data']['children'][memeNumber]['data']['author_fullname'];
    }
    //print("Done");
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        backgroundColor: Color.fromARGB(255, 20, 20, 20),
        appBar: new AppBar(
          title: new Text("Random Reddit Memes"),
          actions: <Widget>[
            new IconButton(
              icon: new Icon(Icons.refresh),
              onPressed: () {
                print("Reloading...");
                _fetchData();
                //sleep(const Duration(seconds: 4));
                setState(() {
                  _isLoading = true;
                });
                //print(firstUrl);
              },
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(top: 10.0),
              child: SizedBox(
                width: double.infinity,
                child: RichText(
                  textAlign: TextAlign.left,
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: imageTitle + "\n",
                        style: TextStyle(
                          fontSize: 18,
                          color: Color.fromARGB(255, 230, 230, 230),
                        ),
                      ),
                      TextSpan(
                        text: "By u/" + imageAuthur,
                        style: TextStyle(
                          fontSize: 8,
                          color: Color.fromARGB(255, 240, 240, 240),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: _isLoading
                  ? new Center(
                      child: Column(
                        children: <Widget>[
                          CircularProgressIndicator(),
                          RichText(
                              text: TextSpan(
                            text:
                                "Loading...\nIf the image is taking too long, it means some einstein wanted to post a gif\ninsted of an image",
                            style: TextStyle(
                              fontSize: 10,
                              color: Color.fromARGB(255, 220, 220, 220),
                            ),
                          ))
                        ],
                      ),
                    )
                  : new Container(
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 20, 20, 20),
                      ),
                      margin: const EdgeInsets.all(6.0),
                      child: Image.network(imageUrl),
                    ),
            ),
          ],
        ),

        // These buttons are currently disabled, Will add functionality once I learn more about Reddit api.
        bottomNavigationBar: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00D0E1), Color(0xFF00B3FA)],
                begin: Alignment.topLeft,
                end: Alignment.topRight,
                stops: [0.0, 0.8],
                tileMode: TileMode.clamp,
              ),
            ),
            //backgroundColor: Color.fromARGB(255, 80, 80, 80),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              items: [
                new BottomNavigationBarItem(
                  icon: Icon(
                    Icons.arrow_upward,
                    color: Colors.white,
                  ),
                  label: "",
                ),
                new BottomNavigationBarItem(
                  icon: Icon(
                    Icons.arrow_downward,
                    color: Colors.white,
                  ),
                  label: "",
                ),
                new BottomNavigationBarItem(
                  icon: Icon(
                    Icons.download_outlined,
                    color: Colors.white,
                  ),
                  label: "",
                )
              ],
            )),
      ),
    );
  }
}
