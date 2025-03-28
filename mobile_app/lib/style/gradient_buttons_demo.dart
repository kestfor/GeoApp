// Пример использования
import 'package:flutter/material.dart';
import 'package:mobile_app/oauth/sign_in_button/mobile.dart';

import 'colors.dart';
import 'gradient_button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget getButtonChild(String text) {
      return Center(
        child: Text(
          text,
          style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white.withOpacity(0.5), fontSize: 20),
        ),
      );
    }

    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image:
                      Image.network(
                        "https://gsmintro.net/user/images/wallpaper_images/2020/02/8/www.mobilesmspk.net_mountain_4514.jpg",
                      ).image,
                ),
              ),
            ),
            Center(
              child: SizedBox(
                height: 300,
                width: 350,
                child: GlassCardWidget(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GradientButton(gradient: purpleGradient, child: getButtonChild("Purple"), onPressed: () {}),
                          SizedBox(width: 16),
                          GradientButton(gradient: yellowGradient, child: getButtonChild("Yellow"), onPressed: () {}),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GradientButton(gradient: redGradient, child: getButtonChild("Red"), onPressed: () {}),
                          SizedBox(width: 16),
                          GradientButton(gradient: greenGradient, child: getButtonChild("Green"), onPressed: () {}),
                        ]
                      ),
                      SizedBox(height: 16),
                      GoogleSignInButton(backgroundColor: Colors.black.withOpacity(0.5),)
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
