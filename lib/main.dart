import 'package:flutter/material.dart';
import 'package:mobile_assign_3/DatabaseHelper.dart';
import 'package:mobile_assign_3/foodItem.dart';
import 'homePage.dart';
import 'calorieCalc.dart';
import 'calcDisplay.dart';

late DatabaseHelper db;

void main() {
  WidgetsFlutterBinding.ensureInitialized(); //ensure widget are started . Done to make sure the DB is loaded.
  db = DatabaseHelper.instance;

  runApp(calorieApp()); //running the app
}

class calorieApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp( //creating the material app and creating a route to the home page
      title: 'Calorie Calc App',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/home',
      routes: {
        '/home': (context) => const calcDisplayHomePage(), //routing to the calculator home page
      },
    );
  }


}


