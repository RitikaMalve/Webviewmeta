import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
    debugShowCheckedModeBanner: false,
      title: 'Guru Samruddhi',
     
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
     Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyWebsite()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
          child: Image.asset("asset/GuruSamruddhi_logo.png"),
        ),  // Replace with your splash screen image
      ),
    );
  }

  // void checkInternetConnection() async {
  //   // final isConnected = await InternetConnectionChecker().hasConnection;
  //   if (!isConnected) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Not connected to the internet'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => SplashScreen()),
  //     );
  //   } else {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => MyWebsite()),
  //     );
  //   }
  // }
}

class MyWebsite extends StatefulWidget {
  const MyWebsite({Key? key}) : super(key: key);

  @override
  State<MyWebsite> createState() => _MyWebsiteState();
}

class _MyWebsiteState extends State<MyWebsite> {
  double _progress = 0;
  late InAppWebViewController _webViewController;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        var canGoBack = await _webViewController.canGoBack();
        if (canGoBack) {
          _webViewController.goBack();
          return false;
        }
        return true;
      },
      child: SafeArea(
        child: Scaffold(
          body: Stack(
            children: [
              InAppWebView(
                initialUrlRequest: URLRequest(
                  url: WebUri("https://app.gssocietysoft.com/"),
                ),
                onWebViewCreated: (controller) {
                  _webViewController = controller;
                },
                onProgressChanged: (controller, progress) {
                  setState(() {
                    _progress = progress / 100;
                  });
                },
                shouldOverrideUrlLoading: (controller, request) async {
                  final uri = request.request.url!;
                  // Handling specific schemes for payment apps
                  if (uri.scheme == "whatsapp" || 
                      uri.scheme == "file" || 
                      uri.scheme == "payment" || 
                      uri.scheme == "tel" || 
                      uri.scheme == "mailto" ||
                      uri.scheme == "upi") {
                    await _launchUrl(uri.toString());
                    return NavigationActionPolicy.CANCEL;
                  }
                  return NavigationActionPolicy.ALLOW;
                },
              ),
             if (_progress < 1) 
      Container(
        color: Colors.white,      // optional: background behind loader
        child: logoLoader(),
      ),
                  // : SizedBox()
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _launchUPIApp() async {
    const upiUrl = 'upi://pay?pa=payee@upi&pn=Payee Name&tr=T12345&tn=Payment for XYZ&am=100.00&cu=INR';
    if (await canLaunch(upiUrl)) {
      await launch(upiUrl);
    } else {
      throw 'Could not launch UPI app';
    }
  }
}
Widget logoLoader() {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo
        SizedBox(
          height: 80,
          width: 80,
          child: Image.asset("asset/GuruSamruddhi_logo.png"), // your logo
        ),

        const SizedBox(height: 20),
      ],
    ),
  );
}
