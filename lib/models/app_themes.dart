import 'dart:math';

import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  /// Light theme settings data.
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.primaries[Random().nextInt(Colors.primaries.length)],
    accentColor: Colors.primaries[Random().nextInt(Colors.primaries.length)],
    canvasColor: Colors.grey[700],
    splashColor: Colors.amberAccent[200],
    highlightColor: Colors.amberAccent[200],
    // textSelectionHandleColor: Colors.blue,
    // textSelectionColor: Colors.blueAccent,
    cardColor: Colors.grey,
    dialogBackgroundColor: Colors.grey[600],
    toggleableActiveColor: Colors.amber[400],
    toggleButtonsTheme: ToggleButtonsThemeData(
      fillColor: Colors.amberAccent,
      color: Colors.white,
      selectedColor: Colors.black,
      selectedBorderColor: Colors.amberAccent,
      borderColor: Colors.amberAccent,
    ),
    buttonTheme:
        // ThemeData.light().buttonTheme.copyWith(
        ButtonThemeData(
      buttonColor: Colors.amber[500],
      splashColor: Colors.amberAccent[200],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
      colorScheme: ColorScheme(
        primary: Colors.white,
        primaryVariant: Colors.grey,
        secondary: Colors.grey,
        secondaryVariant: Colors.grey,
        surface: Colors.grey,
        background: Colors.grey,
        error: Colors.grey,
        onPrimary: Colors.grey,
        onSecondary: Colors.grey,
        onSurface: Colors.grey,
        onBackground: Colors.grey,
        onError: Colors.grey,
        brightness: Brightness.light,
      ),
      textTheme: ButtonTextTheme.primary,
    ),
    // dialogTheme: ThemeData.light().dialogTheme.copyWith(
    //       backgroundColor: Colors.grey[700],
    //     ),
    // fontFamily: 'Quicksand',
    textTheme: ThemeData.light().textTheme.copyWith(
          headline6: TextStyle(
            // fontSize: 24,
            // color: Colors.amber,
          ),
          headline5: TextStyle(
            // fontSize: 18,
            // color: Colors.purple,
            fontWeight: FontWeight.bold,
          ),
          headline4: TextStyle(
            // color: Colors.amber,
          ),
          // headline3: TextStyle(
          //   // fontSize: 18,
          //   color: Colors.purple,
          //   // fontWeight: FontWeight.bold,
          // ),
          // headline2: TextStyle(
          //   // fontSize: 18,
          //   color: Colors.purple,
          //   // fontWeight: FontWeight.bold,
          // ),
          // headline1: TextStyle(
          //   // fontSize: 18,
          //   color: Colors.purple,
          //   // fontWeight: FontWeight.bold,
          // ),
          subtitle2: TextStyle(
            // fontSize: 12,
            // fontWeight: FontWeight.w400,
            // color: Colors.white,
          ),
          bodyText2: TextStyle(
            // fontWeight: FontWeight.w500,
            // color: Colors.white,
          ),
          bodyText1: TextStyle(
            // color: Colors.amber,
          ),
          subtitle1: TextStyle(
            // fontWeight: FontWeight.bold,
            // color: Colors.white,
          ),

          overline: TextStyle(
            color: Colors.white,
          ),
          button: TextStyle(
            color: Colors.black,
          ),
        ),
  );

  ///Dark theme settings data.
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.primaries[Random().nextInt(Colors.primaries.length)],
    accentColor: Colors.primaries[Random().nextInt(Colors.primaries.length)],
    canvasColor: Colors.grey[850],
    highlightColor: Colors.amberAccent[200],
    splashColor: Colors.amberAccent[200],
    // textSelectionHandleColor: Colors.blue[700],
    // textSelectionColor: Colors.blue[700],
    cardColor: Colors.grey[800],
    dialogBackgroundColor: Colors.grey[800],
    toggleableActiveColor: Colors.amber[400],
    toggleButtonsTheme: ToggleButtonsThemeData(
      fillColor: Colors.amberAccent,
      color: Colors.white,
      selectedColor: Colors.black,
      selectedBorderColor: Colors.amberAccent,
      borderColor: Colors.amberAccent,
    ),
    buttonTheme:
        // ThemeData.dark().buttonTheme.copyWith(
        ButtonThemeData(
      buttonColor: Colors.amber[500],
      splashColor: Colors.amberAccent[200],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
      // colorScheme: ColorScheme(
      //   primary: Colors.amber[900],
      //   primaryVariant: Colors.amber,
      //   secondary: Colors.amber[100],
      //   secondaryVariant: Colors.amber,
      //   surface: Colors.amber,
      //   background: Colors.amber,
      //   error: Colors.amber,
      //   onPrimary: Colors.amber,
      //   onSecondary: Colors.amber,
      //   onSurface: Colors.amber,
      //   onBackground: Colors.amber,
      //   onError: Colors.amber,
      //   brightness: Brightness.light,
      // ),
      textTheme: ButtonTextTheme.primary,
    ),
    // dialogTheme: ThemeData.dark().dialogTheme.copyWith(
    //       backgroundColor: Colors.grey[800],
    //     ),
    snackBarTheme: ThemeData.dark().snackBarTheme.copyWith(
        backgroundColor: Colors.black87,
        contentTextStyle: TextStyle(color: Colors.white)),
    // fontFamily: 'Quicksand',
    textTheme: ThemeData.dark().textTheme.copyWith(
          headline5: TextStyle(
            // fontSize: 18,
            // color: Colors.amber,
            fontWeight: FontWeight.bold,
          ),
        ),
  );
}
