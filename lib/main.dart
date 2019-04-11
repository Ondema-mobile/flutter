import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;


// entry point for a flutter app
void main() => runApp(MyApp());

// business as usual here
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Ondema Demo'),
    );
  }
}

// Home screen is a stateful widget - nothing special
class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

/// The state for the Home Page widget.
/// 
/// The app shows 3 images in a ListView, which are loaded from the assets folder.
/// 
/// Once an image is clicked, it is saved as a file locally, and then pushed to
///   the Ondema server using a MultipartRequest. Then, a StreamedResponse object 
///   is received, in it a URL to a store that was dynamically rendered based 
///   on the image file that was provided in the request.
class _MyHomePageState extends State<MyHomePage> {

  // these shoe a "loading" indicator after an image was clicked.
  Widget firstWidget = Container();
  Widget secondWidget = Container();
  Widget thirdWidget = Container();

  // these control the clickability of an image, to avoid having another 
  // http request sent while an existing one is still running.
  bool firstClickable = true;
  bool secondClickable = true;
  bool thirdClickable = true;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Center(
        child: ListView(
          children: <Widget>[

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Text('Click Images to Open Store:',
                style: TextStyle(fontSize: 30, color: Colors.blue),
                textAlign: TextAlign.center,
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),

              child: Column(
                children: <Widget>[

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text('The Card Players, by Paul Cézanne:',
                        style: TextStyle(fontSize: 22, color: Colors.blue)
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (firstClickable) {
                        firstClickable = false;
                        setState(() {
                          firstWidget = SizedBox(child: CircularProgressIndicator(), height: 100, width: 100);
                        });
                        _saveImageFile('assets/Paul_Cezanne_landscape.jpg');
                      }
                    },
                    child: AspectRatio(
                        aspectRatio: 1024/724,
                        child: Stack(
                          children: <Widget>[
                            Container(
                                decoration: const BoxDecoration(
                                    image: const DecorationImage(
                                        image: const AssetImage('assets/Paul_Cezanne_landscape.jpg'),
                                        fit: BoxFit.cover
                                    )
                                )
                            ),
                            Center(child: firstWidget)
                          ],
                        )
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text('Example of a landscape image',
                        style: TextStyle(fontSize: 16, color: Colors.blue)
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 24, bottom: 4),
                    child: Text('Nafea faa ipoipo, by Paul Gauguin:',
                        style: TextStyle(fontSize: 22, color: Colors.blue)
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (secondClickable) {
                        secondClickable = false;
                        setState(() {
                          secondWidget = SizedBox(child: CircularProgressIndicator(), height: 100, width: 100);
                        });
                        _saveImageFile('assets/Paul_Gauguin_portrait.jpg');
                      }
                    },
                    child: AspectRatio(
                        aspectRatio: 752/1000,
                        child: Stack(
                          children: <Widget>[
                            Container(
                                decoration: const BoxDecoration(
                                    image: const DecorationImage(
                                        image: const AssetImage('assets/Paul_Gauguin_portrait.jpg'),
                                        fit: BoxFit.cover
                                    )
                                )
                            ),
                            Center(child: secondWidget)
                          ],
                        )
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text('Example of a portrait image',
                        style: TextStyle(fontSize: 16, color: Colors.blue)
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 24, bottom: 4),
                    child: Text('Massacre of the Innocents, by Paul Rubens:',
                        style: TextStyle(fontSize: 22, color: Colors.blue)
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (thirdClickable) {
                        thirdClickable = false;
                        setState(() {
                          thirdWidget = SizedBox(child: CircularProgressIndicator(), height: 100, width: 100);
                        });
                        _saveImageFile('assets/Titian_Diana_and_Actaeon_square.jpg');
                      }
                    },
                    child: AspectRatio(
                        aspectRatio: 985/900,
                        child: Stack(
                          children: <Widget>[
                            Container(
                                decoration: const BoxDecoration(
                                    image: const DecorationImage(
                                        image: const AssetImage('assets/Titian_Diana_and_Actaeon_square.jpg'),
                                        fit: BoxFit.cover
                                    )
                                )
                            ),
                            Center(child: thirdWidget)
                          ],
                        )
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text('Example of a square image',
                        style: TextStyle(fontSize: 16, color: Colors.blue)
                    ),
                  ),

                ],
              ),
            )
          ],
        ),
      ),
    );
  }


  // this saves an image from the local "Assets" folder as a file in app's document directory.
  Future<Null> _saveImageFile(String imageUrl) async {

    var documentDirectory = await getApplicationDocumentsDirectory();

    ByteData bundlePath = await rootBundle.load(imageUrl);

    File file = File('${documentDirectory.path}/img1');
    file.writeAsBytes(bundlePath.buffer.asUint8List(bundlePath.offsetInBytes, bundlePath.lengthInBytes))
        .then((file) => _uploadFile(file));
  }


  // this sends the image file to Ondema's servers, and receives a URL back.
  _uploadFile(File file) async {

    var url = 'https://admin.ondema-m.com/api/get_shop_url';

    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.fields['campaign_code'] = '76_0E8E';
    request.fields['api_token'] = 'SdI9cWXSqT3js2JKtAUYng47DTUIHEdc4HeQ0vv0YFQHlvTwMgRmQUlSIR8e';
    request.files.add(await http.MultipartFile.fromPath('image', file.path));

    http.StreamedResponse response = await request.send()
        .catchError((err) {
      print(err.toString());
    });

    if (response == null) {
      _uploadFile(file);
    }
    else {
      String responseData = await response.stream.transform(utf8.decoder).join();
      Map responseBody = await jsonDecode(responseData);
      String shopUrl = responseBody['shop_url'];

      _launchURL(shopUrl);
    }
  }


  // this launches the URL in a browser on  the device
  _launchURL(String url) async {

    _stopLoadingIndicators();

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }


  // this resets the clickability  of the image and the Loading indicator.
  _stopLoadingIndicators() {

    setState(() {

      if (!firstClickable) {
        firstWidget = Container();
        firstClickable = true;
      }

      if (!secondClickable) {
        secondWidget = Container();
        secondClickable = true;
      }

      if (!thirdClickable) {
        thirdWidget = Container();
        thirdClickable = true;
      }
    });
  }
}
