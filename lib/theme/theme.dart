

import 'package:flutter/material.dart';

class AppTheme{

  static const Map<int, Color> palette = {
    50 : Color(0xffeffaff),
    100: Color(0xffdff3ff),
    200: Color(0xffb7eaff),
    300: Color(0xff77dbff),
    400: Color(0xff2ecaff),
    500: Color(0xff03b4f4),
    550: Color(0xff3fe7b6),
    600: Color(0xff0090d1),
    700: Color(0xff0073a9),
    800: Color(0xff01618b),
    900: Color(0xff075073),
    950: Color(0xff032030),
    1000: Color(0xff003049)
  };

  static ThemeData light = ThemeData.light().copyWith(
    primaryColor: Colors.black87,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0.0,
      iconTheme: const IconThemeData(
        color: Colors.black87,
      ),
      titleTextStyle: ThemeData.light().textTheme.titleLarge,
      centerTitle: true
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: palette[550]!,
      unselectedItemColor: Colors.white,
      selectedIconTheme: IconThemeData(
        color: palette[550]!,
      ),
      elevation: 10.0,
      backgroundColor: palette[900],
      
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color:Color(0xff263959),
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w300,
        fontSize: 96,
        letterSpacing: -1.5,
      ),
      displayMedium: TextStyle(
        color:Color(0xff263959),
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w300,
        fontSize: 60,
        letterSpacing: -0.5,
      ),
      displaySmall: TextStyle(
        color:Color(0xff263959),
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w400,
        fontSize: 48,
        letterSpacing: 0,
      ),
      headlineMedium: TextStyle(
        color:Color(0xff263959),
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w400,
        fontSize: 34,
        letterSpacing: 0.25,
      ),
      headlineSmall: TextStyle(
        color:Color(0xff263959),
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w400,
        fontSize: 24,
        letterSpacing: 0,
      ),
      titleLarge: TextStyle(
        color:Color(0xff263959),
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w500,
        fontSize: 20,
        letterSpacing: 0.15,
      ),
      titleMedium: TextStyle(
        color:Color(0xff263959),
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w400,
        fontSize: 16,
        letterSpacing: 0.15,
      ),
      titleSmall: TextStyle(
        color:Color(0xff263959),
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w500,
        fontSize: 14,
        letterSpacing: 0.1,
      ),
      bodyLarge: TextStyle(
        color:Color(0xff263959),
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w400,
        fontSize: 16,
        letterSpacing: 0.5,
      ),
      bodyMedium: TextStyle(
        color:Color(0xff263959),
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w400,
        fontSize: 14,
        letterSpacing: 0.25,
      ),
      labelLarge: TextStyle(
        decorationColor: Colors.transparent,
        wordSpacing: 1.0,
        decorationThickness: 1.0,
        backgroundColor: Colors.transparent,
        color:Color(0xff263959),
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w500,
        fontSize: 14,
        letterSpacing: 1.25,
      ),
      bodySmall: TextStyle(
        color:Color(0xff263959),
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w400,
        fontSize: 12,
        letterSpacing: 0.4,
      ),
      labelSmall: TextStyle(
        color:Color(0xff263959),
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w400,
        fontSize: 10,
        letterSpacing: 0.4,
      ),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: palette[500],
      selectionColor: palette[500],
      selectionHandleColor: palette[300],
    ),
    inputDecorationTheme: InputDecorationTheme(
      prefixIconColor: palette[1000],
      suffixIconColor: palette[1000],
      floatingLabelStyle: ThemeData().textTheme.bodyMedium?.copyWith(color: const Color(0xff263959), fontWeight: FontWeight.w200, fontSize: 14),
      hintStyle: ThemeData().textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500, fontWeight: FontWeight.w200, fontSize: 14),
      labelStyle: ThemeData().textTheme.bodyMedium,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.0),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.0),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder( 
        borderRadius: BorderRadius.circular(5.0),
        borderSide: BorderSide(
          color: palette[1000]!,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: Colors.red
        ),
        borderRadius: BorderRadius.circular(5.0)
      ),
      errorStyle: const TextStyle(color: Colors.red),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: Colors.red
        ),
        borderRadius: BorderRadius.circular(5.0)
      ),
      isDense: true
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        overlayColor: WidgetStateColor.transparent,
        backgroundColor: WidgetStateColor.resolveWith((states){
          if (states.contains(WidgetState.disabled)){
            return Colors.grey.shade300;
          }
          return palette[1000]!;
        }),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0))),
        side: WidgetStatePropertyAll(BorderSide(color: AppTheme.palette[1000]!)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        overlayColor: WidgetStateColor.transparent,
        foregroundColor: WidgetStateProperty.all<Color>(palette[1000]!),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states){
        if (states.contains(WidgetState.selected)){
          return WidgetStateColor.resolveWith((states) => palette[1000]!);
        }
        return WidgetStateColor.resolveWith((states) => Colors.white);
      }),
      checkColor: WidgetStateProperty.all<Color>(Colors.white),
      side: BorderSide(
        color: Colors.grey.shade400,
        width: 2.0
      )
    ),
    dropdownMenuTheme: const DropdownMenuThemeData(
      inputDecorationTheme: InputDecorationTheme(
        constraints: BoxConstraints(
          minWidth: 20.0
        ),
      )
    ),
    listTileTheme: ListTileThemeData(
      style: ListTileStyle.list,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: Colors.grey,
          width: 1
        )
      ),
    ),
    tabBarTheme: TabBarTheme(
      labelStyle: TextStyle(
        overflow: TextOverflow.ellipsis,
        fontSize: 12,
        color: palette[900],
      ),
      tabAlignment: TabAlignment.start,
      splashFactory: NoSplash.splashFactory,
      dividerHeight: 1.0,
      unselectedLabelStyle: TextStyle(
        overflow: TextOverflow.ellipsis,
        color: Colors.grey.shade400,
        fontSize: 12
      ),
      indicatorSize: TabBarIndicatorSize.label,
      indicatorColor: palette[550]!
    ),
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      titleTextStyle: ThemeData().textTheme.titleMedium,
      backgroundColor: Colors.white,
      actionsPadding: const EdgeInsets.all(20.0),
      contentTextStyle: ThemeData().textTheme.bodyMedium,      
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states){
        if (states.contains(WidgetState.selected)){
          return palette[1000]!;
        }
        return Colors.grey.shade400;
      }),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: palette[550]!,
    ),
    bannerTheme: MaterialBannerThemeData(
      backgroundColor: palette[1000]!,
      contentTextStyle: ThemeData().textTheme.bodyMedium?.copyWith(color: Colors.white),
      padding: const EdgeInsets.all(20.0),
      leadingPadding: const EdgeInsets.all(20.0),
      
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white,
      labelStyle: ThemeData().textTheme.bodyMedium,
      padding: const EdgeInsets.all(10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
        side: BorderSide(
          color: Colors.grey.shade400,
          width: 1.0
        )
      ),
      secondaryLabelStyle: ThemeData().textTheme.bodyMedium,
      secondarySelectedColor: palette[1000]!,
      selectedColor: palette[1000]!,
      labelPadding: const EdgeInsets.only(right: 10.0, top: 10.0, bottom: 10.0),
      elevation: 1.0,
      color: WidgetStateColor.resolveWith((states){
        if (states.contains(WidgetState.selected)){
          return palette[1000]!;
        }
        return Colors.white;
      })
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: palette[1000]!,
      disabledColor: Colors.grey.shade300,
      splashColor: Colors.transparent,
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25.0),
      ),
    ),
    expansionTileTheme: ExpansionTileThemeData(
      iconColor: palette[1000]!,
      backgroundColor: Colors.white,
      textColor: palette[1000]!,
      collapsedBackgroundColor: Colors.white,
      collapsedIconColor: palette[1000]!,
      collapsedTextColor: palette[1000]!,
      // expandedBackgroundColor: Colors.white,
      // expandedIconColor: palette[1000]!,
      // expandedTextColor: palette[1000]!,
      tilePadding: EdgeInsets.zero,
      // iconTheme: const IconThemeData(
      //   size: 24.0
      // ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppTheme.palette[1000],
      splashColor: Colors.transparent
    ),
  );

  static ThemeData dark = ThemeData.dark().copyWith(

  );

}