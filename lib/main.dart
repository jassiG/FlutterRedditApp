import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// global variables
var appTitle = 'Random Reddit Memes';
var imageUrl =
    "https://www.materialui.co/materialIcons/navigation/refresh_white_192x192.png";
var imageTitle =
    "Tap the Floating Reload button for a Random Meme\n\nTap the top right reload button to refresh Dataset\n\nThere is also a r/all mode toggle in the drawer";
var imageAuthur = "me";
var subreddit = "none";
var _isLoading = false;
bool allMode = false;

var urls = {
  0: "https://www.reddit.com/r/memes/hot.json?limit=56",
  1: "https://www.reddit.com/r/dankmemes/hot.json?limit=56",
  2: "https://www.reddit.com/r/all.json?limit=100",
  '0lim': 56,
  '1lim': 56,
  '2lim': 100,
};
var responses = new List(3);

_refreshData() async {
  print("App is Resetting Data....");
  responses[0] = await http.get(urls[0]);
  responses[1] = await http.get(urls[1]);
  responses[2] = await http.get(urls[2]);
  print("Data Reset Complete!");
}

void main() {
  _refreshData();
  runApp(RedditApp());
}

class RedditApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new RedditState();
  }
}

class RedditState extends State<RedditApp> {
  _fetchData() async {
    Random rndm = new Random();
    print("refreshing post");
    int subredditNumber = 0;
    if (!allMode) {
      appTitle = 'Random Reddit Memes';
      subredditNumber = rndm.nextInt(2);
    } else {
      appTitle = 'Random Reddit Posts';
      subredditNumber = 2;
    }
    var map = json.decode(responses[subredditNumber].body);
    int postNumber = rndm.nextInt(urls[subredditNumber.toString() + 'lim']);

    if (map['data']['children'][postNumber]['data']['domain'] != 'i.redd.it') {
      if (!allMode) {
        subredditNumber = rndm.nextInt(2);
      } else {
        subredditNumber = 2;
      }
      map = json.decode(responses[subredditNumber].body);
      postNumber = rndm.nextInt(urls[subredditNumber.toString() + 'lim']);
    } else if (map['data']['children'][postNumber]['data']['domain'] ==
        'i.redd.it') {
      imageUrl = map['data']['children'][postNumber]['data']['url'];
      imageTitle = map['data']['children'][postNumber]['data']['title'];
      subreddit = map['data']['children'][postNumber]['data']
          ['subreddit_name_prefixed'];
      imageAuthur =
          map['data']['children'][postNumber]['data']['author_fullname'];
    } else {
      imageUrl =
          "https://www.elegantthemes.com/blog/wp-content/uploads/2020/07/000-HTTP-Error-400.png";
      imageTitle = map['data']['children'][postNumber]['data']['title'];
      imageAuthur = 'oops';
      subreddit = 'oops';
    }
    //print("Done");
    setState(() {
      _isLoading = false;
    });
  }

  void _changeAllMode(bool anything) {
    allMode = allMode ^ true;
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        backgroundColor: Color.fromARGB(255, 20, 20, 20),
        appBar: new AppBar(
          title: new Text(appTitle),
          actions: <Widget>[
            new IconButton(
              icon: new Icon(Icons.refresh),
              onPressed: () {
                _refreshData();
              },
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(child: Text("Temp Drawer"),
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                ),
              ),
              ListTile(
                title: Text("option 1"),
                onTap: (){
                  //
                },
              ),
              ListTile(
                title: Text("option 2"),
                onTap: (){
                  //
                },
              ),
              Row(
                children: <Widget>[
                  Checkbox(value: allMode, onChanged: _changeAllMode),
                  Text("r/all"),
                ],
              )
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.refresh_outlined),
          onPressed: () {
            //sleep(const Duration(seconds: 4));
            setState(() {
              _isLoading = true;
            });
            _fetchData();
            //print(firstUrl);
          },
        ),
        body: ListView(
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
                        text: "By: u/" + imageAuthur + '\n',
                        style: TextStyle(
                          fontSize: 8,
                          color: Color.fromARGB(255, 240, 240, 240),
                        ),
                      ),
                      TextSpan(
                        text: "Posted in: " + subreddit + '\n',
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
